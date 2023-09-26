Shader "koturn/KRayMarching/ColorHexagram"
{
    Properties
    {
        // Common Ray Marching Parameters.
        [Toggle(_NOFORWARDADD_ON)]
        _NoForwardAdd ("Disable ForwardAdd", Int) = 0

        [IntRange]
        _MaxLoop ("Maximum loop count for ForwardBase", Range(8, 1024)) = 128

        [IntRange]
        _MaxLoopForwardAdd ("Maximum loop count for ForwardAdd", Range(8, 1024)) = 64

        [IntRange]
        _MaxLoopShadowCaster ("Maximum loop count for ShadowCaster", Range(8, 1024)) = 64

        _MinRayLength ("Minimum length of the ray", Float) = 0.001
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 0.65

        [KeywordEnum(Object, World)]
        _CalcSpace ("Calculation space", Int) = 0

        // Lighting Parameters.
        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Unlit, Custom)]
        _Lighting ("Lighting method", Int) = 0

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
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


        [IntRange]
        _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0

        [IntRange]
        _StencilReadMask ("Stencil ReadMask Value", Range(0, 255)) = 255

        [IntRange]
        _StencilWriteMask ("Stencil WriteMask Value", Range(0, 255)) = 255

        [Enum(UnityEngine.Rendering.CompareFunction)]
        _StencilComp ("Stencil Compare Function", Int) = 8  // Default: Always

        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilPass ("Stencil Pass", Int) = 0  // Default: Keep

        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilFail ("Stencil Fail", Int) = 0  // Default: Keep

        [Enum(UnityEngine.Rendering.StencilOp)]
        _StencilZFail ("Stencil ZFail", Int) = 0  // Default: Keep
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

        Stencil
        {
            Ref [_StencilRef]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            Comp [_StencilComp]
            Pass [_StencilPass]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
        }


        CGINCLUDE
        #pragma multi_compile_fog
        #pragma shader_feature_local _ _NOFORWARDADD_ON
        #pragma shader_feature_local _CALCSPACE_OBJECT _CALCSPACE_WORLD
        #pragma shader_feature_local_fragment _ _USE_FAST_INVTRIFUNC_ON
        #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT _LIGHTING_CUSTOM

        #include "include/alt/AltUnityCG.cginc"
        #include "include/alt/AltUnityStandardUtils.cginc"
        #include "AutoLight.cginc"

#ifdef _USE_FAST_INVTRIFUNC_ON
        #define MATH_REPLACE_TO_FAST_INVTRIFUNC
#endif  // _USE_FAST_INVTRIFUNC_ON
        #include "include/Math.cginc"
        #include "include/Utils.cginc"
        #include "include/LightingUtils.cginc"
        #include "include/SDF.cginc"
        #include "include/VertCommon.cginc"


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


        //! Maximum loop count for ForwardBase.
        uniform int _MaxLoop;
        //! Maximum loop count for ForwardAdd.
        uniform int _MaxLoopForwardAdd;
        //! Maximum loop count for ShadowCaster.
        uniform int _MaxLoopShadowCaster;
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
         * @brief Fragment shader function.
         * @param [in] fi  Input data from vertex shader
         * @return Output of each texels (fout).
         */
        fout frag(v2f_raymarching_forward fi)
        {
#if (defined(_NOFORWARDADD_ON) || defined(_LIGHTING_UNLIT)) && defined(UNITY_PASS_FORWARDADD)
            fout fo;
            UNITY_INITIALIZE_OUTPUT(fout, fo);
            return fo;
#else
            UNITY_SETUP_INSTANCE_ID(fi);
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

            const float3 rayOrigin = fi.rayOrigin;
            const float3 rayDir = normalize(fi.rayDirVec);

            const rmout ro = rayMarch(rayOrigin, rayDir);
            if (!ro.isHit) {
                discard;
            }

#    ifdef _CALCSPACE_WORLD
            const float3 worldFinalPos = rayOrigin + rayDir * ro.rayLength;
            const float3 worldNormal = getNormal(worldFinalPos);
#    else
            const float3 localFinalPos = rayOrigin + rayDir * ro.rayLength;
            const float3 worldFinalPos = objectToWorldPos(localFinalPos);
            const float3 worldNormal = UnityObjectToWorldNormal(getNormal(localFinalPos));
#    endif  // defined(_CALCSPACE_WORLD)

#    if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
            const float4 lmap = fi.lmap;
#    else
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
#    endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)

            _SpecColor *= ro.color.a;
            const half4 color = calcLighting(
                half4(ro.color.xyz, 1.0),
                worldFinalPos,
                worldNormal,
                getLightAttenRayMarching(fi, worldFinalPos),
                lmap);

            const float4 projPos = UnityWorldToClipPos(worldFinalPos);

            fout fo;
            fo.color = applyFog(projPos.z, color);
            fo.depth = getDepth(projPos);

            return fo;
#endif  // defined(_NOFORWARDADD_ON) && defined(UNITY_PASS_FORWARDADD)
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
#if defined(UNITY_PASS_FORWARDBASE)
            const int maxLoop = _MaxLoop;
#elif defined(UNITY_PASS_FORWARDADD)
            const int maxLoop = _MaxLoopForwardAdd;
#elif defined(UNITY_PASS_SHADOWCASTER)
            const int maxLoop = _MaxLoopShadowCaster;
#endif  // defined(UNITY_PASS_FORWARDBASE)

            const float3 rayDirVec = rayDir * _Scales;
            const float marchingFactor = _MarchingFactor * rsqrt(dot(rayDirVec, rayDirVec));

            rmout ro;
            ro.rayLength = 0.0;
            ro.isHit = false;
            ro.color = half4(0.0, 0.0, 0.0, 0.0);

            // Loop of Ray Marching.
            for (int i = 0; i < maxLoop; i = (ro.isHit || ro.rayLength > _MaxRayLength) ? 0x7fffffff : i + 1) {
                const float d = map((rayOrigin + rayDir * ro.rayLength) * _Scales, ro.color);
                ro.rayLength += d * marchingFactor;
                ro.isHit = d < _MinRayLength;
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
#if defined(_LIGHTING_UNITY_LAMBERT)
            return calcLightingUnityLambert(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTING_UNITY_BLINN_PHONG)
            return calcLightingUnityBlinnPhong(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTING_UNITY_STANDARD)
            return calcLightingUnityStandard(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTING_UNITY_STANDARD_SPECULAR)
            return calcLightingUnityStandardSpecular(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTING_UNLIT)
            return color;
#else
            return calcLightingCustom(color, worldPos, worldNormal, atten, lmap);
#endif  // defined(_LIGHTING_LAMBERT)
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
                normal += ks[i] * map((p + ks[i] * h) * _Scales, /* out */ _);
            }

            return normalize(normal);
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
            #pragma vertex vertRayMarchingForward
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
            #pragma vertex vertRayMarchingForward
            #pragma fragment frag

            #pragma multi_compile_fwdadd_fullshadows
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
            #pragma vertex vertRayMarchingShadowCaster
            #pragma fragment fragShadowCaster

            #pragma multi_compile_shadowcaster


            /*!
             * @brief Fragment shader function for ShadowCaster Pass.
             * @param [in] fi  Input data from vertex shader.
             * @return Output of each texels (fout).
             */
            fout fragShadowCaster(v2f_raymarching_shadowcaster fi)
            {
                UNITY_SETUP_INSTANCE_ID(fi);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

                const float3 rayOrigin = fi.rayOrigin;
                const float3 rayDir = normalize(fi.rayDirVec);

                const rmout ro = rayMarch(rayOrigin, rayDir);
                if (!ro.isHit) {
                    discard;
                }

#ifdef _CALCSPACE_WORLD
                const float3 worldFinalPos = rayOrigin + rayDir * ro.rayLength;
#else
                const float3 localFinalPos = rayOrigin + rayDir * ro.rayLength;
                const float3 worldFinalPos = objectToWorldPos(localFinalPos);
#endif  // defined(_CALCSPACE_WORLD)

#if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                i.vec = worldFinalPos - _LightPositionRange.xyz;
                SHADOW_CASTER_FRAGMENT(i);
#else
                fout fo;
                fo.color = fo.depth = getDepth(UnityWorldToClipPos(worldFinalPos));

                return fo;
#endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
            }
            ENDCG
        }  // ShadowCaster
    }

    CustomEditor "Koturn.KRayMarching.Inspectors.ColorHexagramGUI"
}
