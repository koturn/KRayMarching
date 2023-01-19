Shader "koturn/KRayMarching/Sphere"
{
    Properties
    {
        // Common Ray Marching Parameters.
        _MaxLoop ("Maximum loop count", Int) = 60
        _MinRayLength ("Minimum length of the ray", Float) = 0.01
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)
        _MarchingFactor ("Marching Factor", Float) = 1.0

        _Color ("Color of the objects", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 100.0)) = 5.0

        [KeywordEnum(Optimized, Optimized Loop, Conventional)]
        _NormalCalcMode ("Normal Calculation Mode", Int) = 0

        [KeywordEnum(Lembert, Half Lembert, Squred Half Lembert, Disable)]
        _DiffuseMode ("Reflection Mode", Int) = 2

        [KeywordEnum(Original, Half Vector, Disable)]
        _SpecularMode ("Specular Mode", Int) = 1

        [KeywordEnum(Legacy, SH, Disable)]
        _AmbientMode ("Ambient Mode", Int) = 1

        [Toggle(_ENABLE_REFLECTION_PROBE)]
        _EnableReflectionProbe ("Enable Reflection Probe", Int) = 1

        _RefProbeBlendCoeff ("Blend coefficient of reflection probe", Range(0.0, 1.0)) = 0.5

        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

        // [ColorMask]
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
        #pragma target 3.0

        // keywords:
        //   FOG_LINEAR
        //   FOG_EXP
        //   FOG_EXP2
        #pragma multi_compile_fog

        #pragma shader_feature_local_fragment _NORMALCALCMODE_OPTIMIZED _NORMALCALCMODE_OPTIMIZED_LOOP _NORMALCALCMODE_OPTIMIZED_CONVENTIONAL
        #pragma shader_feature_local_fragment _DIFFUSEMODE_LEMBERT _DIFFUSEMODE_HALF_LEMBERT _DIFFUSEMODE_SQURED_HALF_LEMBERT _DIFFUSEMODE_DISABLE
        #pragma shader_feature_local_fragment _SPECULARMODE_ORIGINAL _SPECULARMODE_HALF_VECTOR _SPECULARMODE_DISABLE
        #pragma shader_feature_local_fragment _AMBIENTMODE_LEGACY _AMBIENTMODE_SH _AMBIENTMODE_DISABLE
        #pragma shader_feature_local_fragment _ _ENABLE_REFLECTION_PROBE

        #include "UnityCG.cginc"
        #include "UnityStandardUtils.cginc"
        #include "AutoLight.cginc"
        #include "include/RefProbe.cginc"


        /*!
         * @brief Input of vertex shader.
         */
        struct appdata
        {
            //! Local position of the vertex.
            float4 vertex : POSITION;
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
        };


        rmout rayMarch(float3 rayOrigin, float3 rayDir);
        float map(float3 p);
        float sdSphere(float3 p, float r);
        float3 getNormal(float3 p);
        half4 applyFog(float fogFactor, half4 color);
        float3 worldToObjectPos(float3 worldPos);
        float3 worldToObjectPos(float4 worldPos);
        float3 objectToWorldPos(float3 localPos);
        fixed getLightAttenuation(v2f fi, float3 worldPos);
        float sq(float x);
        float3 normalizeEx(float3 v);


        //! Color of light.
        uniform fixed4 _LightColor0;

        //! Color of the objects.
        uniform half4 _Color;
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
        //! Specular color.
        uniform half4 _SpecColor;
        //! Specular power.
        uniform half _SpecPower;
        //! Blend coefficient of reflection probe.
        uniform float _RefProbeBlendCoeff;

        /*!
         * @brief Vertex shader function.
         *
         * @param [in] v  Input data
         * @return Output for fragment shader (v2f).
         */
        v2f vert(appdata v)
        {
            v2f o;
            UNITY_INITIALIZE_OUTPUT(v2f, o);

            o.localPos = v.vertex;
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
         *
         * @param [in] fi  Input data from vertex shader.
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

            // Lambertian reflectance.
            const float nDotL = dot(localNormal, localLightDir);
#if defined(_DIFFUSEMODE_SQURED_HALF_LEMBERT)
            const half3 diffuse = lightCol * sq(nDotL * 0.5 + 0.5);
#elif defined(_DIFFUSEMODE_HALF_LEMBERT)
            const half3 diffuse = lightCol * (nDotL * 0.5 + 0.5);
#elif defined(_DIFFUSEMODE_LEMBERT)
            const half3 diffuse = lightCol * max(0.0, nDotL);
#else
            const half3 diffuse = half3(1.0, 1.0, 1.0);
#endif  // defined(_DIFFUSEMODE_SQURED_HALF_LEMBERT)

            // Specular reflection.
#ifdef _SPECULARMODE_HALF_VECTOR
            const half3 specular = pow(max(0.0, dot(normalize(localLightDir + localViewDir), localNormal)), _SpecPower) * _SpecColor.xyz * lightCol;
#elif _SPECULARMODE_ORIGINAL
            const half3 specular = pow(max(0.0, dot(reflect(-localLightDir, localNormal), localViewDir)), _SpecPower) * _SpecColor.xyz * lightCol;
#else
            const half3 specular = half3(0.0, 0.0, 0.0);
#endif  // _SPECULARMODE_HALF_VECTOR

            // Ambient color.
#if defined(_AMBIENTMODE_SH)
            const float3 worldNormal = UnityObjectToWorldNormal(localNormal);
            const half3 ambient = ShadeSHPerPixel(
                worldNormal,
#   ifdef VERTEXLIGHT_ON
                Shade4PointLights(
                    unity_4LightPosX0,
                    unity_4LightPosY0,
                    unity_4LightPosZ0,
                    unity_LightColor[0].rgb,
                    unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb,
                    unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    worldFinalPos,
                    worldNormal),
#   else
                half3(0.0, 0.0, 0.0),
#   endif  // VERTEXLIGHT_ON
                worldFinalPos);
#elif defined(_AMBIENTMODE_LEGACY)
            const half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
#else
            const half3 ambient = half3(0.0, 0.0, 0.0);
#endif  // defined(_AMBIENTMODE_SH)

#ifdef _ENABLE_REFLECTION_PROBE
            const half4 refColor = getRefProbeColor(
                UnityObjectToWorldNormal(reflect(-localViewDir, localNormal)),
                worldFinalPos);
            const half4 col = half4((diffuse + ambient) * lerp(_Color.rgb, refColor.rgb, _RefProbeBlendCoeff) + specular, _Color.a);
#else
            // Output color.
            const half4 col = half4((diffuse + ambient) * _Color.rgb + specular, _Color.a);
#endif  // _ENABLE_REFLECTION_PROBE

            const float4 projPos = UnityWorldToClipPos(worldFinalPos);

            fout fo;
            UNITY_INITIALIZE_OUTPUT(fout, fo);
            fo.color = applyFog(projPos.z, col);
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

            // Marching Loop.
            for (int i = 0; i < _MaxLoop; i++) {
                // Position of the tip of the ray.
                const float d = map((rayOrigin + rayDir * ro.rayLength));

                ro.isHit = d < _MinRayLength;
                ro.rayLength += d * _MarchingFactor;

                // Break this loop if the ray goes too far or collides.
                if (ro.isHit || ro.rayLength > _MaxRayLength) {
                    break;
                }
            }

            return ro;
        }

        /*!
         * @brief SDF (Signed Distance Function) of objects.
         *
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p)
        {
            // <+CURSOR+>
            return sdSphere(p, 0.5);
        }

        /*!
         * @brief SDF of Sphere.
         *
         * @param [in] r  Radius of sphere.
         * @return Signed Distance to the Sphere.
         */
        float sdSphere(float3 p, float r)
        {
            return length(p) - r;
        }

        /*!
         * @brief Calculate normal of the objects.
         *
         * @param [in] p  Position of the tip of the ray.
         * @return Normal of the objects.
         * @see https://iquilezles.org/articles/normalsSDF/
         */
        float3 getNormal(float3 p)
        {
#if defined(_NORMALCALCMODE_OPTIMIZED)
            // Lightweight normal calculation.
            // SDF is called four times and each calling is inlined.
            static const float2 k = float2(1.0, -1.0);
            static const float2 kh = k * 0.0001;

            return normalize(
                k.xyy * map(p + kh.xyy)
                    + k.yxy * map(p + kh.yxy)
                    + k.yyx * map(p + kh.yyx)
                    + map(p + kh.xxx));
#elif defined(_NORMALCALCMODE_OPTIMIZED_LOOP)
            // SDF is called four times.
            // When the loop is not unrolled, there is only one SDF calling in the loop,
            // which helps reduce code size.
            static const float2 k = float2(1.0, -1.0);
            static const float h = 0.0001;
            static const float3 ks[4] = {k.xyy, k.yxy, k.yyx, k.xxx};

            float3 normal = float3(0.0, 0.0, 0.0);

            // UNITY_LOOP
            for (int i = 0; i < 4; i++) {
                normal += ks[i] * map(p + ks[i] * h);
            }
            return normalize(normal);
#else
            // Naive normal calculation.
            // SDF is called six times and each calling is inlined.
            static const float2 d = float2(0.0001, 0.0);

            return normalize(
                float3(
                    map(p + d.xyy) - map(p - d.xyy),
                    map(p + d.yxy) - map(p - d.yxy),
                    map(p + d.yyx) - map(p - d.yyx)));
#endif  // defined(_NORMALCALCMODE_OPTIMIZED)
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
            return worldToObjectPos(float4(worldPos, 1.0));
        }

        /*!
         * @brief Convert from world coordinate to local coordinate.
         *
         * @param [in] worldPos  World coordinate.
         * @return World coordinate.
         */
        float3 worldToObjectPos(float4 worldPos)
        {
            return mul(unity_WorldToObject, worldPos).xyz;
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
         * @brief Get Light Attenuation.
         *
         * @param [in] fi  Input data for fragment shader.
         * @param [in] worldPos  World coordinate.
         * @return Light Attenuation Value.
         */
        fixed getLightAttenuation(v2f fi, float3 worldPos)
        {
            // v must be declared in this scope.
            // v must include following.
            //   vertex : POSITION
            // a._ShadowCoord = mul( unity_WorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );
            // UNITY_TRANSFER_SHADOW(fi, texcoord2);

            // a._LightCoord = mul(unity_WorldToLight, mul(unity_ObjectToWorld, v.vertex)).xyz;
            // UNITY_TRANSFER_LIGHTING(fi, texcoord2);

            // v2f must include following.
            //   pos : SV_POSITION
            UNITY_LIGHT_ATTENUATION(atten, fi, worldPos);
            return atten;
        }

        /*!
         * @brief Calculate squared value.
         *
         * @param [in] x  A value.
         * @return x * x
         */
        float sq(float x)
        {
            return x * x;
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
        ENDCG

        Pass
        {
            Name "FORWARD_BASE"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // keywords:
            //   DIRECTIONAL
            //   LIGHTMAP_ON
            //   DIRLIGHTMAP_COMBINED
            //   DYNAMICLIGHTMAP_ON
            //   LIGHTMAP_SHADOW_MIXING
            //   VERTEXLIGHT_ON
            //   LIGHTPROBE_SH
            #pragma multi_compile_fwdbase
            ENDCG
        }  // ForwardBase

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
            #pragma vertex vert
            #pragma fragment frag

            // Keywords:
            //   POINT
            //   DIRECTIONAL
            //   SPOT
            //   POINT_COOKIE
            //   DIRECTIONAL_COOKIE
            #pragma multi_compile_fwdadd
            ENDCG
        }  // ForwardAdd

        Pass
        {
            Name "SHADOW_CASTER"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            AlphaToMask Off

            CGPROGRAM
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            // Keywords:
            //   SHADOWS_DEPTH
            //   SHADOWS_CUBE
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
            };


            /*!
            * @brief Vertex shader function.
            *
            * @param [in] v  Input data
            * @return Output for fragment shader (v2f_shadowcaster).
            */
            v2f_shadowcaster vertShadowCaster(appdata v)
            {
                v2f_shadowcaster o;
                // UNITY_INITIALIZE_OUTPUT(v2f_shadowcaster, o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex.xyz;
                o.localSpaceCameraPos = worldToObjectPos(_WorldSpaceCameraPos);
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
                // Define ray direction by finding the direction of the local coordinates
                // of the mesh from the local coordinates of the viewpoint.
                // const float3 localRayDir = normalize(fi.localPos - fi.localSpaceCameraPos);

                const float3 worldPos = objectToWorldPos(fi.localPos);
                const float3 localRayDir = UnityWorldToObjectDir(-UNITY_MATRIX_V[2].xyz);

                const rmout ro = rayMarch(fi.localPos, localRayDir);
                if (!ro.isHit) {
                    discard;
                }

                const float3 localFinalPos = fi.localPos + localRayDir * ro.rayLength;
                const float3 worldFinalPos = objectToWorldPos(localFinalPos);

                const float3 localNormal = getNormal(localFinalPos);
                const float3 worldNormal = UnityObjectToWorldNormal(localNormal);

                // const float4 projPos = UnityWorldToClipPos(worldFinalPos);

                // See SHADOW_CASTER_FRAGMENT()
                // fout fo;
                // fo.color = UnityEncodeCubeShadowDepth(
                //     (length(worldFinalPos - _LightPositionRange.xyz) + unity_LightShadowBias.x) * _LightPositionRange.w);
                // fo.depth = projPos.z / projPos.w;

                fout fo;

                float4 oops = UnityApplyLinearShadowBias(UnityClipSpaceShadowCasterPos(localFinalPos, localNormal));
                float4 projPos = mul(UNITY_MATRIX_VP, oops);
                fo.color = ro.isHit ? half4(1.0, 1.0, 1.0, 1.0) : half4(0.0, 0.0, 0.0, 0.0);
                fo.depth = oops.z / oops.w;

                return fo;
            }
            ENDCG
        }  // ShadowCaster
    }

    CustomEditor "Koturn.KRayMarching.KRayMarchingBaseGUI"
}
