Shader "koturn/RayMarching/TorusSixOctahedron"
{
    Properties
    {
        // Common Ray Marching Parameters.
        _MaxLoop ("Maximum loop count", Int) = 256
        _MinRayLength ("Minimum length of the ray", Float) = 0.001
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        _MarchingFactor ("Marching Factor", Range(0.0, 1.0)) = 0.5

        _SpecColor ("Color of specular", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 100.0)) = 5.0

        // SDF parameters.
        _TorusRadius ("Radius of Torus", Float) = 0.25
        _TorusRadiusAmp ("Radius Amplitude of Torus", Float) = 0.05
        _TorusWidth ("Width of Torus", Float) = 0.005
        _OctahedronSize ("Size of Octahedron", Float) = 0.05

        [Toggle(_USE_FAST_INV_TRI_FUNC_ON)]
        _UseFastInvTriFunc ("Use Fast Inverse Trigonometric Functions", Int) = 1

        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

        [ColorMask]
        _ColorMask ("Color Mask", Int) = 15

        [Enum(Off, 0, On, 1)]
        _AlphaToMask ("Alpha To Mask", Int) = 0  // Default: Off
    }

    SubShader
    {
        Tags
        {
            "Queue" = "AlphaTest"
            "RenderType" = "Transparent"
            "DisableBatching" = "True"
            "IgnoreProjector" = "True"
            "VRCFallback" = "Hidden"
        }

        Cull [_Cull]
        ColorMask [_ColorMask]
        AlphaToMask [_AlphaToMask]

        CGINCLUDE
        #pragma multi_compile_fog
        #pragma shader_feature_local_fragment _ _USE_FAST_INV_TRI_FUNC_ON

        #include "UnityCG.cginc"
        #include "UnityStandardUtils.cginc"
        #include "AutoLight.cginc"


        /*!
         * @brief Input of vertex shader.
         */
        struct appdata
        {
            //! Local position of the vertex.
            float4 vertex : POSITION;
            //! Texture coordinate 1.
            float2 uv2 : TEXCOORD1;
        };

        /*!
         * @brief Output of vertex shader and input of fragment shader.
         */
        struct v2f
        {
            //! Clip space position of the vertex.
            float4 pos : SV_POSITION;
            //! World position at the pixel.
            float3 localPos : TEXCOORD0;
            //! Local space position of the camera.
            nointerpolation float3 localSpaceCameraPos : TEXCOORD1;
            //! Local space light position.
            nointerpolation float3 localSpaceLightPos : TEXCOORD2;
            //! Lighting and shadowing parameters.
            UNITY_LIGHTING_COORDS(3, 4)
        };

        /*!
         * @brief Output of fragment shader.
         */
        struct fout
        {
            //! Output color of the pixel.
            half4 color : SV_Target;
            //! Depth of the pixel.
            float depth : SV_Depth;
        };

        /*!
         * @brief Output of rayMarch().
         */
        struct rmout
        {
            //! Length of the ray.
            float rayLength;
            //! A flag whether the ray collided with an object or not.
            bool isHit;
            //! Color of the object.
            half3 color;
        };


        rmout rayMarch(float3 rayOrigin, float3 rayDir);
        float map(float3 p, out half3 color);
        float sdTorus(float3 p, float2 t);
        float sdOctahedron(float3 p, float s);
        float3 getNormal(float3 p);
        half4 applyFog(float fogFactor, half4 color);
        float3 worldToObjectPos(float3 worldPos);
        float3 objectToWorldPos(float3 localPos);
        fixed getLightAttenuation(v2f fi, float3 worldPos);
        float sq(float x);
        float atanPos(float x);
        float atanFast(float x);
        float atan2Fast(float x, float y);
        float3 normalizeEx(float3 v);
        float2 getPmodParam(float2 p, float r);
        float2x2 rotate2DMat(float angle);
        float2 rotate2D(float2 v, float angle);
        float2 rotate2D(float2 v, float2 pivot, float angle);

#ifdef _USE_FAST_INV_TRI_FUNC_ON
        #define atan(x) atanFast(x)
        #define atan2(x, y) atan2Fast(x, y)
#endif  // _USE_FAST_INV_TRI_FUNC_ON


        //! Color of light.
        uniform fixed4 _LightColor0;

        //! Maximum loop count.
        uniform int _MaxLoop;
        //! Minimum length of the ray.
        uniform float _MinRayLength;
        //! Maximum length of the ray.
        uniform float _MaxRayLength;
        //! Scale vector.
        uniform float3 _Scales;
        //! Marching Factor.
        uniform float _MarchingFactor;

        //! Color of specular.
        uniform half4 _SpecColor;
        //! Power of specular.
        uniform half _SpecPower;

        //! Radius of Torus.
        uniform float _TorusRadius;
        //! Radius Amplitude of Torus.
        uniform float _TorusRadiusAmp;
        //! Width of Torus.
        uniform float _TorusWidth;
        //! Size of Octahedron.
        uniform float _OctahedronSize;


        /*!
         * @brief Vertex shader function.
         * @param [in] v  Input data
         * @return Output for fragment shader (v2f).
         */
        v2f vert(appdata v)
        {
            v2f o;
            UNITY_INITIALIZE_OUTPUT(v2f, o);

            o.localPos = v.vertex.xyz;
            o.localSpaceCameraPos = worldToObjectPos(_WorldSpaceCameraPos) * _Scales;
#ifdef USING_DIRECTIONAL_LIGHT
            o.localSpaceLightPos = normalizeEx(mul((float3x3)unity_WorldToObject, _WorldSpaceLightPos0.xyz) * _Scales);
#else
            o.localSpaceLightPos = worldToObjectPos(_WorldSpaceLightPos0) * _Scales;
#endif  // USING_DIRECTIONAL_LIGHT
            UNITY_TRANSFER_LIGHTING(o, v.uv2);

            v.vertex.xyz /= _Scales;
            o.pos = UnityObjectToClipPos(v.vertex);

            return o;
        }


        /*!
         * @brief Fragment shader function.
         * @param [in] fi  Input data from vertex shader
         * @return Output of each texels (fout).
         */
        fout frag(v2f fi)
        {
            // Define ray direction by finding the direction of the local coordinates
            // of the mesh from the local coordinates of the viewpoint.
            const float3 localRayDir = normalize(fi.localPos - fi.localSpaceCameraPos);

            const rmout ro = rayMarch(fi.localSpaceCameraPos, localRayDir);
            if (!ro.isHit) {
                discard;
            }

            const float3 localFinalPos = fi.localSpaceCameraPos + localRayDir * ro.rayLength;
            const float3 worldFinalPos = objectToWorldPos(localFinalPos);

            const float3 localNormal = getNormal(localFinalPos);
            const float3 localViewDir = normalize(fi.localSpaceCameraPos - localFinalPos);
#ifdef USING_DIRECTIONAL_LIGHT
            const float3 localLightDir = fi.localSpaceLightPos;
#else
            const float3 localLightDir = normalize(fi.localSpaceLightPos - localFinalPos);
#endif  // USING_DIRECTIONAL_LIGHT
            const fixed3 lightCol = _LightColor0.rgb * getLightAttenuation(fi, worldFinalPos);

            // Lambertian reflectance: Half-Lambert.
            const float nDotL = dot(localNormal, localLightDir);
            const half3 diffuse = lightCol * sq(nDotL * 0.5 + 0.5);

            // Specular reflection.
            const half3 specular = pow(max(0.0, dot(normalize(localLightDir + localViewDir), localNormal)), _SpecPower) * _SpecColor.xyz * lightCol;

            // Ambient color.
#if UNITY_SHOULD_SAMPLE_SH
            const half3 ambient = ShadeSHPerPixel(UnityObjectToWorldNormal(localNormal), half3(0.0, 0.0, 0.0), worldFinalPos);
#else
            const half3 ambient = half3(0.0, 0.0, 0.0);
#endif  // UNITY_SHOULD_SAMPLE_SH

            const float4 projPos = UnityWorldToClipPos(worldFinalPos);

            fout fo;
            fo.color = applyFog(projPos.z, half4((diffuse + ambient) * ro.color.rgb + specular, 1.0));
            fo.depth = projPos.z / projPos.w;

            return fo;
        }


        /*!
         * @brief Execute ray marching.
         *
         * @param [in] rayOrigin  Origin of the ray.
         * @param [in] rayDir  Direction of the ray.
         * @return Result of the ray marching.
         */
        rmout rayMarch(float3 rayOrigin, float3 rayDir)
        {
            rmout ro;
            ro.rayLength = 0.0;
            ro.isHit = false;
            ro.color = half3(0.0, 0.0, 0.0);

            // Loop of Ray Marching.
            for (int i = 0; i < _MaxLoop; i++) {
                // Position of the tip of the ray.
                const float d = map((rayOrigin + rayDir * ro.rayLength), ro.color);

                ro.rayLength += d * _MarchingFactor;
                ro.isHit = d < _MinRayLength;

                // Break this loop if the ray goes too far or collides.
                if (ro.isHit || ro.rayLength > _MaxRayLength) {
                    break;
                }
            }

            return ro;
        }

        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p, out half3 color)
        {
            static const half3 kColors[6] = {
                half3(0.8, 0.4, 0.4),  // R
                half3(0.8, 0.8, 0.4),  // Y
                half3(0.4, 0.8, 0.4),  // G
                half3(0.4, 0.8, 0.8),  // C
                half3(0.4, 0.4, 0.8),  // B
                half3(0.8, 0.4, 0.8)   // M
            };
            static const float kOneThirdPi = UNITY_PI / 3.0;
            static const float kInvOneThirdPi = 1.0 / kOneThirdPi;

            const float radius = _TorusRadius + _SinTime.w * _TorusRadiusAmp;

            float minDist = sdTorus(p, float2(radius, _TorusWidth));
            color = half3(1.0, 0.75, 0.25);

            p.xy = rotate2D(p.xy, _Time.y);
            const float xyAngle = atan2(p.y, p.x);
            const float rotUnit = floor(xyAngle * kInvOneThirdPi);
            p.xy = rotate2D(p.xy, kOneThirdPi * rotUnit + kOneThirdPi / 2.0);

            const float d = sdOctahedron(p - float3(radius, 0.0, 0.0), _OctahedronSize);
            if (minDist > d) {
                minDist = d;
                const int idx = (int)rotUnit;
                color = idx == 0 ? kColors[0]
                    : idx == 1 ? kColors[1]
                    : idx == 2 ? kColors[2]
                    : idx == -3 ? kColors[3]
                    : idx == -2 ? kColors[4]
                    : kColors[5];
            }

            return minDist;
        }

        /*!
         * @brief SDF of Torus.
         * @param [in] p  Position of the tip of the ray.
         * @param [in] t  (t.x, t.y) = (radius of torus, thickness of torus).
         * @return Signed Distance to the Sphere.
         */
        float sdTorus(float3 p, float2 t)
        {
            const float2 q = float2(length(p.xy) - t.x, p.z);
            return length(q) - t.y;
        }

        /*!
         * @brief SDF of Octahedron.
         * @param [in] p  Position of the tip of the ray.
         * @param [in] s  Size of Octahedron.
         * @return Signed Distance to the Octahedron.
         */
        float sdOctahedron(float3 p, float s)
        {
            return (dot(abs(p), float3(0.5, 2.0, 2.0)) - s) * 0.57735027;
        }

        /*!
         * @brief Calculate normal of the objects.
         * @param [in] p  Position of the tip of the ray.
         * @return Normal of the objects.
         * @see https://iquilezles.org/articles/normalsSDF/
         */
        float3 getNormal(float3 p)
        {
            static const float2 k = float2(1.0, -1.0);
            static const float3 ks[] = {k.xyy, k.yxy, k.yyx, k.xxx};
            static const float h = 0.0001;

            float3 normal = float3(0.0, 0.0, 0.0);
            half3 _ = half3(0.0, 0.0, 0.0);

            for (int i = 0; i < 4; i++) {
                normal += ks[i] * map(p + ks[i] * h, /* out */ _);
            }

            return normalize(normal);
        }

        /*!
         * @brief Apply fog.
         *
         * UNITY_APPLY_FOG includes some variable declaration.
         * This function can be used to localize those declarations.
         * If fog is disabled, this function returns color as is.
         *
         * @param [in] color  Target color.
         * @return Fog-applied color.
         */
        half4 applyFog(float fogFactor, half4 color)
        {
            UNITY_APPLY_FOG(fogFactor, color);
            return color;
        }

        /*!
         * @brief Convert from world coordinate to local coordinate.
         *
         * @param [in] worldPos  World coordinate.
         * @return World coordinate.
         */
        float3 worldToObjectPos(float3 worldPos)
        {
            return mul(unity_WorldToObject, float4(worldPos, 1.0)).xyz;
        }

        /*!
         * @brief Convert from local coordinate to world coordinate.
         *
         * @param [in] localPos  Local coordinate.
         * @return World coordinate.
         */
        float3 objectToWorldPos(float3 localPos)
        {
            return mul(unity_ObjectToWorld, float4(localPos, 1.0)).xyz;
        }

        /*!
         * @brief Get light attenuation.
         *
         * @param [in] fi  Input data of fragment shader function.
         * @param [in] worldPos  Coordinate of the world.
         * @return light attenuation.
         */
        fixed getLightAttenuation(v2f fi, float3 worldPos)
        {
            UNITY_LIGHT_ATTENUATION(atten, fi, worldPos);
            return atten;
        }

        /*!
         * @brief Calculate squared value.
         * @param [in] x  A value.
         * @return x * x
         */
        float sq(float x)
        {
            return x * x;
        }

        /*
         * @brief Calculate positive value of atan().
         * @param [in] x  The first argument of atan().
         * @return Approximate positive value of atan().
         */
        float atanPos(float x)
        {
            const float t0 = x < 1.0 ? x : rcp(x);
#if 1
            const float t1 = (-0.269408 * t0 + 1.05863) * t0;
            return x < 1.0 ? t1 : (UNITY_HALF_PI - t1);
#else
            const float t1 = t0 * t0;
            float poly = 0.0872929;
            poly = -0.301895 + poly * t1;
            poly = 1.0 + poly * t1;
            poly *= t0;
            return x < 1.0 ? poly : (UNITY_HALF_PI - poly);
#endif
        }

        /*
         * @brief Fast atan().
         * @param [in] x  The first argument of atan().
         * @return Approximate value of atan().
         * @see https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
         */
        float atanFast(float x)
        {
            const float t0 = atanPos(abs(x));
            return x < 0.0 ? -t0 : t0;
        }

        /*
         * @brief Fast atan2().
         * @param [in] x  The first argument of atan2().
         * @param [in] y  The second argument of atan2().
         * @return Approximate value of atan().
         * @see https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
         */
        float atan2Fast(float x, float y)
        {
            return atanFast(x / y) + UNITY_PI * (y < 0.0) * (x < 0.0 ? -1.0 : 1.0);
        }

        /*!
         * @brief Zero-Division avoided normalize.
         * @param [in] v  A vector.
         * @return normalized vector or zero vector.
         */
        float3 normalizeEx(float3 v)
        {
            const float vDotV = dot(v, v);
            return vDotV == 0.0 ? v : (rsqrt(vDotV) * v);
        }

        /*!
         * @brief Get unit angle and index of Polar Mod (Fold Rotate).
         *
         * @param [in] p  2D-coordinate.
         * @param [in] r  Number of divisions.
         * @return Unit angle (x) and index (y) of Polar Mod.
         */
        float2 getPmodParam(float2 p, float r)
        {
            const float a = atan2(p.y, p.x) + UNITY_PI / r;
            const float n = UNITY_TWO_PI / r;
            return float2(n, -floor(a / n));
        }

        /*!
         * @brief Get 2D-rotation matrix.
         *
         * @param [in] angle  Angle of rotation.
         * @return 2D-rotation matrix.
         */
        float2x2 rotate2DMat(float angle)
        {
            float s, c;
            sincos(angle, /* out */ s, /* out */ c);
            return float2x2(c, -s, s, c);
        }

        /*!
         * @brief Rotate on 2D plane
         *
         * @param [in] v  Target vector
         * @param [in] angle  Angle of rotation.
         * @return Rotated vector.
         */
        float2 rotate2D(float2 v, float angle)
        {
            return mul(rotate2DMat(angle), v);
        }

        /*!
         * @brief Rotate on 2D plane
         *
         * @param [in] v  Target vector
         * @param [in] pivot  Pivot of rotation.
         * @param [in] angle  Angle of rotation.
         * @return Rotated vector.
         */
        float2 rotate2D(float2 v, float2 pivot, float angle)
        {
            return rotate2D(v - pivot, angle) + pivot;
        }

        ENDCG


        Pass
        {
            Name "FORWARD_BASE"

            Tags
            {
                "LightMode" = "ForwardBase"
            }

            // Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase
            ENDCG
        }

        Pass
        {
            Name "FORWARD_ADD"

            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Blend One OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdadd
            ENDCG
        }
    }

    CustomEditor "Koturn.KRayMarching.TorusOctahedronGUI"
}

