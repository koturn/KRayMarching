Shader "koturn/KRayMarching/ColorHexagram"
{
    Properties
    {
        // Common Ray Marching Parameters.
        _MaxLoop ("Maximum loop count", Int) = 256
        _MinRayLength ("Minimum length of the ray", Float) = 0.001
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)
        _MarchingFactor ("Marching Factor", Float) = 0.5

        // Lighting Parameters.
        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Custom)]
        _LightingMethod ("Lighting method", Int) = 0

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Color of specular", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 1.0

        // SDF parameters.
        _TorusRadius ("Radius of Torus", Float) = 0.25
        _TorusRadiusAmp ("Radius Amplitude of Torus", Float) = 0.05
        _TorusWidth ("Width of Torus", Float) = 0.005
        _OctahedronSize ("Size of Octahedron", Float) = 0.05
        _LineColorMultiplier ("Multiplier of lines", Float) = 5.0

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
        #include "include/SDF.cginc"


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
            half4 color;
        };


        rmout rayMarch(float3 rayOrigin, float3 rayDir);
        float map(float3 p, out half4 color);
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
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

        //! Multiplier of lines.
        uniform float _LineColorMultiplier;
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
            o.localSpaceLightPos = normalizeEx(mul((float3x3)unity_WorldToObject, _WorldSpaceLightPos0.xyz) * _Scales.xyz);
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

            _SpecColor *= ro.color.a;
            const half4 color = calcLighting(
                half4(ro.color.xyz, 1.0),
                worldFinalPos,
                UnityObjectToWorldNormal(getNormal(localFinalPos)),
                getLightAttenuation(fi, worldFinalPos),
                lmap);

            const float4 projPos = UnityWorldToClipPos(worldFinalPos);

            fout fo;
            fo.color = applyFog(projPos.z, color);
            fo.depth = getDepth(projPos);

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
            ro.color = half4(0.0, 0.0, 0.0, 0.0);

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
        float map(float3 p, out half4 color)
        {
            static const half4 kColors[6] = {
                half4(0.8, 0.4, 0.4, 1.0),  // R
                half4(0.8, 0.8, 0.4, 1.0),  // Y
                half4(0.4, 0.8, 0.4, 1.0),  // G
                half4(0.4, 0.8, 0.8, 1.0),  // C
                half4(0.4, 0.4, 0.8, 1.0),  // B
                half4(0.8, 0.4, 0.8, 1.0)   // M
            };
            static const float kOneThirdPi = UNITY_PI / 3.0;
            static const float kTwoThirdPi = UNITY_PI * (2.0 / 3.0);
            static const float kOneSixthPi = UNITY_PI / 6.0;
            static const float kInvOneThirdPi = rcp(kOneThirdPi);
            static const float kInvTwoThirdPi = rcp(kTwoThirdPi);

            const float radius = _TorusRadius + _SinTime.w * _TorusRadiusAmp;

            float minDist = sdTorus(p.xzy, float2(radius, _TorusWidth));

            p.xy = invRotate2D(p.xy, _Time.y);

            const float xyAngle = atan2(p.y, p.x);
            color = half4(
                rgbAddHue(half3(1.0, 0.75, 0.25), xyAngle / UNITY_TWO_PI + rcp(UNITY_PI / 12.0)) * _LineColorMultiplier,
                0.0);

            const float rotUnit = floor(xyAngle * kInvOneThirdPi);
            float3 rayPos1 = p;
            rayPos1.xy = invRotate2D(rayPos1.xy, kOneThirdPi * rotUnit + kOneSixthPi);

            const float dist = sdOctahedron(rayPos1 - float3(radius, 0.0, 0.0), _OctahedronSize, float3(2.0, 2.0, 0.5));
            if (minDist > dist) {
                minDist = dist;
                const int idx = ((int)rotUnit);
                color = idx == 0 ? kColors[0]
                    : idx == 1 ? kColors[1]
                    : idx == 2 ? kColors[2]
                    : idx == -3 ? kColors[3]
                    : idx == -2 ? kColors[4]
                    : kColors[5];
            }

            const float2 posXY1 = invRotate2D(float2(radius, 0.0), kTwoThirdPi);
            const float2 posXY2 = invRotate2D(float2(radius, 0.0), -kTwoThirdPi);
            const float2 posCenterXY = (posXY1 + posXY2) * 0.5;
            const float length12 = length(posXY2 - posXY1) * 0.5;

            for (int i = 0; i < 2; i++) {
                const float rotUnit2 = floor((xyAngle + kOneSixthPi - kOneThirdPi * i) * kInvTwoThirdPi);

                float3 rayPos2 = p;
                rayPos2.xy = invRotate2D(rayPos2.xy, kTwoThirdPi * rotUnit2 + kOneThirdPi * (i + 3) + kOneSixthPi);
                rayPos2.xy -= invRotate2D(posCenterXY, posCenterXY, kTwoThirdPi * rotUnit2 + kOneSixthPi);

                const float dist2 = sdCappedCylinder(rayPos2, 0.0025, length12 * 5);
                if (minDist > dist2) {
                    minDist = dist2;
                    const int idx = int(rotUnit2);
                    const half3 albedo = idx == 0 ? kColors[0 + i]
                        : idx == -1 ? kColors[4 + i]
                        : kColors[2 + i];
                    color = half4(albedo * _LineColorMultiplier, 0.0);
                }
            }

            return minDist;
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
            static const float h = 0.0001;
            static const float3 ks[4] = {k.xyy, k.yxy, k.yyx, k.xxx};

            float3 normal = float3(0.0, 0.0, 0.0);
            half4 _ = half4(0.0, 0.0, 0.0, 0.0);

            UNITY_LOOP
            for (int i = 0; i < 4; i++) {
                normal += ks[i] * map(p + ks[i] * h, /* out */ _);
            }

            return normalize(normal);
        }

        /*!
         * @brief Get Light Attenuation.
         *
         * @param [in] fi  Input data for fragment shader.
         * @param [in] worldPos  World coordinate.
         * @return Light Attenuation Value.
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

        Pass
        {
            Name "SHADOW_CASTER"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            Cull Back
            ZWrite On

            CGPROGRAM
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #pragma multi_compile_shadowcaster

            /*!
             * @brief Output of vertex shader and input of fragment shader.
             */
            struct v2f_shadowcaster
            {
                //! Clip space position of the vertex.
                V2F_SHADOW_CASTER;
                //! World position at the pixel.
                float3 localPos : TEXCOORD1;
                //! Local space position of the camera.
                nointerpolation float3 localSpaceCameraPos : TEXCOORD2;
                //! Projected position.
                float4 projPos : TEXCOORD3;
            };


            /*!
             * @brief Vertex shader function.
             * @param [in] v  Input data
             * @return Output for fragment shader (v2f_shadowcaster).
             */
            v2f_shadowcaster vertShadowCaster(appdata v)
            {
                v2f_shadowcaster o;
                UNITY_INITIALIZE_OUTPUT(v2f_shadowcaster, o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex.xyz;
                o.localSpaceCameraPos = worldToObjectPos(_WorldSpaceCameraPos);
                o.projPos = ComputeNonStereoScreenPos(o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                TRANSFER_SHADOW_CASTER(o)

                return o;
            }

            /*!
             * @brief Fragment shader function for ShadowCaster Pass.
             *
             * @param [in] fi  Input data from vertex shader.
             * @return Output of each texels (fout).
             */
            fout fragShadowCaster(v2f_shadowcaster fi)
            {
#if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                float3 localRayDir = UnityWorldToObjectDir(getCameraDirection(fi.projPos));
#else
                float3 localRayDir;
                if (!any(UNITY_MATRIX_P[3].xyz)) {
                    localRayDir = UnityWorldToObjectDir(-UNITY_MATRIX_V[2].xyz);
                } else if (abs(unity_LightShadowBias.x) < 1e-5) {
                    localRayDir = normalize(fi.localPos - fi.localSpaceCameraPos);
                } else {
                    localRayDir = UnityWorldToObjectDir(getCameraDirection(fi.projPos));
                }
#endif

                const rmout ro = rayMarch(fi.localPos, localRayDir);
                if (!ro.isHit) {
                    discard;
                }

                const float3 localFinalPos = fi.localPos + localRayDir * ro.rayLength;
                const float3 worldFinalPos = objectToWorldPos(localFinalPos);

#if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                i.vec = ray.endPos - _LightPositionRange.xyz;
                SHADOW_CASTER_FRAGMENT(i);
#else
                const float4 projPos = UnityWorldToClipPos(worldFinalPos);

                fout fo;
                fo.color = fo.depth = getDepth(projPos);

                return fo;
#endif
            }
            ENDCG
        }  // ShadowCaster
    }

    CustomEditor "Koturn.KRayMarching.ColorHexagramGUI"
}
