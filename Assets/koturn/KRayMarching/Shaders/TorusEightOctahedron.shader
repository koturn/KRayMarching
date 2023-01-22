Shader "koturn/KRayMarching/TorusEightOctahedron"
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

        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Custom)]
        _LightingMethod ("Lighting method", Int) = 0

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Color of specular", Color) = (0.5, 0.5, 0.5, 0.5)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0

        // SDF parameters.
        _TorusRadius ("Radius of Torus", Float) = 0.25
        _TorusRadiusAmp ("Radius Amplitude of Torus", Float) = 0.05
        _TorusWidth ("Width of Torus", Float) = 0.005
        _OctahedronSize ("Size of Octahedron", Float) = 0.05

        [Toggle(_USE_FAST_INVTRIFUNC_ON)]
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
        #pragma shader_feature_local_fragment _ _USE_FAST_INVTRIFUNC_ON
        #pragma shader_feature_local_fragment _LIGHTINGMETHOD_UNITY_LAMBERT _LIGHTINGMETHOD_UNITY_BLINN_PHONG _LIGHTINGMETHOD_UNITY_STANDARD _LIGHTINGMETHOD_UNITY_STANDARD_SPECULAR _LIGHTINGMETHOD_CUSTOM

        #include "UnityCG.cginc"
        #include "UnityStandardUtils.cginc"
        #include "AutoLight.cginc"

#ifdef _USE_FAST_INVTRIFUNC_ON
        #define MATH_REPLACE_TO_FAST_INVTRIFUNC
#endif  // _USE_FAST_INVTRIFUNC_ON
        #include "include/Math.cginc"
        #include "include/Utils.cginc"
        #include "include/LightingUtils.cginc"


        /*!
         * @brief Input of vertex shader.
         */
        struct appdata
        {
            //! Local position of the vertex.
            float4 vertex : POSITION;
#ifdef LIGHTMAP_ON
            //! Lightmap coordinate.
            float2 texcoord1 : TEXCOORD1;
#endif  // LIGHTMAP_ON
#ifdef DYNAMICLIGHTMAP_ON
            //! Dynamic Lightmap coordinate.
            float2 texcoord2 : TEXCOORD2;
#endif  // DYNAMICLIGHTMAP_ON
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
#if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
            //! Light map UV coordinates.
            float4 lmap : TEXCOORD5;
#endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
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
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
        float sdTorus(float3 p, float2 t);
        float sdOctahedron(float3 p, float s);
        float3 getNormal(float3 p);
        fixed getLightAttenuation(v2f fi, float3 worldPos);


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

#ifdef LIGHTMAP_ON
            o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif  // LIGHTMAP_ON
#ifdef DYNAMICLIGHTMAP_ON
            o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif  // DYNAMICLIGHTMAP_ON

            UNITY_TRANSFER_LIGHTING(o, v.texcoord1);

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

#if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
            const float4 lmap = fi.lmap;
#else
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
#endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)

            const half4 color = calcLighting(
                half4(ro.color, 1.0),
                worldFinalPos,
                UnityObjectToWorldNormal(getNormal(localFinalPos)),
                getLightAttenuation(fi, worldFinalPos),
                lmap);

            const float4 projPos = UnityWorldToClipPos(worldFinalPos);

            fout fo;
            fo.color = applyFog(projPos.z, color);
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
                const float d = map((rayOrigin + rayDir * ro.rayLength), /* out */ ro.color);

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
            static const half3 kColors[8] = {
                half3(0.4, 0.8, 0.4),
                half3(0.8, 0.4, 0.4),
                half3(0.8, 0.8, 0.8),
                half3(0.8, 0.8, 0.4),
                half3(0.8, 0.4, 0.8),
                half3(0.4, 0.8, 0.8),
                half3(0.4, 0.4, 0.4),
                half3(0.4, 0.4, 0.8)
            };
            static const float kQuarterPi = UNITY_PI / 4.0;

            const float radius = _TorusRadius + _SinTime.w * _TorusRadiusAmp;

            float minDist = sdTorus(p, float2(radius, _TorusWidth));
            // color = half3(1.0, 1.0, 1.0);
            color = half3(1.0, 0.65, 0.30);

            p.xy = rotate2D(p.xy, _Time.y);
            const float rotUnit = floor(-atan2(p.y, p.x) / kQuarterPi);
            p.xy = rotate2D(p.xy, kQuarterPi * rotUnit + kQuarterPi / 2.0);

            const float d = sdOctahedron(p - float3(radius, 0.0, 0.0), _OctahedronSize);
            if (minDist > d) {
                minDist = d;
                const int idx = (int)rotUnit;
                color = idx == 0 ? kColors[0]
                    : idx == 1 ? kColors[1]
                    : idx == 2 ? kColors[2]
                    : idx == 3 ? kColors[3]
                    : idx == -4 ? kColors[4]
                    : idx == -3 ? kColors[5]
                    : idx == -2 ? kColors[6]
                    : kColors[7];
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
         * Calculate lighting.
         * @param [in] color  Base color.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] lmap  Light map parameters.
         * @return Color with lighting applied.
         */
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap)
        {
#if defined(_LIGHTINGMETHOD_LAMBERT)
            return calcLightingUnityLambert(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTINGMETHOD_UNITY_BLINN_PHONG)
            return calcLightingUnityBlinnPhong(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTINGMETHOD_UNITY_STANDARD)
            return calcLightingUnityStandard(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTINGMETHOD_UNITY_STANDARD_SPECULAR)
            return calcLightingUnityStandardSpecular(color, worldPos, worldNormal, atten, lmap);
#else
            return calcLightingCustom(color, worldPos, worldNormal, atten, lmap);
#endif  // defined(_LIGHTINGMETHOD_LAMBERT)
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
        ENDCG


        Pass
        {
            Name "FORWARD_BASE"

            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Blend Off
            ZWrite On

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

            Blend One One
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

