Shader "koturn/KRayMarching/Sphere"
{
    Properties
    {
        // Common Ray Marching Parameters.
        [IntRange]
        _MaxLoop ("Maximum loop count for ForwardBase", Range(8, 1024)) = 128

        [IntRange]
        _MaxLoopForwardAdd ("Maximum loop count for ForwardAdd", Range(8, 1024)) = 64

        [IntRange]
        _MaxLoopShadowCaster ("Maximum loop count for ShadowCaster", Range(8, 1024)) = 64

        _MinRayLength ("Minimum length of the ray", Float) = 0.01
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0

        _Color ("Color of the objects", Color) = (1.0, 1.0, 1.0, 1.0)

        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Custom)]
        _LightingMethod ("Lighting method", Int) = 0

        [Toggle(_ENABLE_REFLECTION_PROBE)]
        _EnableReflectionProbe ("Enable Reflection Probe", Int) = 1

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0

        [KeywordEnum(Lambert, Half Lambert, Squared Half Lembert, Disable)]
        _DiffuseMode ("Reflection Mode", Int) = 2

        [KeywordEnum(Original, Half Vector, Disable)]
        _SpecularMode ("Specular Mode", Int) = 1

        [KeywordEnum(Legacy, SH, Disable)]
        _AmbientMode ("Ambient Mode", Int) = 1

        [KeywordEnum(Central Difference, Forward Differece, Tetrahedron)]
        _NormalCalcMethod ("Normal Calculation Mode", Int) = 2

        [KeywordEnum(Unroll, Loop, Loop Without LUT)]
        _NormalCalcOptimize ("Normal Calculation Optimization", Int) = 1


        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

        [HideInInspector]
        __RenderingMode ("Rendering Mode", Int) = 1

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("Blend Source Factor", Int) = 1  // Default: One

        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Blend Destination Factor", Int) = 0  // Default: Zero

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlendAlpha ("Blend Source Factor", Int) = 1  // Default: One

        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlendAlpha ("Blend Destination Factor", Int) = 0  // Default: Zero

        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp ("BlendOp", Int) = 0  // Default: Add

        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOpAlpha ("BlendOpAlpha", Int) = 0  // Default: Add

        [Enum(Off, 0, On, 1)]
        _ZWrite ("ZWrite", Int) = 0  // Default: Off

        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTest ("ZTest", Int) = 4  // Default: LEqual

        [Enum(2D, 0, 3D, 1)]
        _OffsetFact ("Offset Factor", Int) = 0

        _OffsetUnit ("Offset Units", Range(-100, 100)) = 0

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
        _StencilCompFunc ("Stencil Compare Function", Int) = 8  // Default: Always

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
        BlendOp [_BlendOp], [_BlendOpAlpha]
        Offset [_OffsetFact], [_OffsetUnit]
        ColorMask [_ColorMask]
        AlphaToMask [_AlphaToMask]

        Stencil
        {
            Ref [_StencilRef]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            Comp [_StencilCompFunc]
            Pass [_StencilPass]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
        }


        CGINCLUDE
        #pragma target 3.0

        // keywords:
        //   FOG_LINEAR
        //   FOG_EXP
        //   FOG_EXP2
        #pragma multi_compile_fog

        #pragma shader_feature_local_fragment _DIFFUSEMODE_LAMBERT _DIFFUSEMODE_HALF_LAMBERT _DIFFUSEMODE_SQUARED_HALF_LAMBERT _DIFFUSEMODE_DISABLE
        #pragma shader_feature_local_fragment _SPECULARMODE_ORIGINAL _SPECULARMODE_HALF_VECTOR _SPECULARMODE_DISABLE
        #pragma shader_feature_local_fragment _AMBIENTMODE_LEGACY _AMBIENTMODE_SH _AMBIENTMODE_DISABLE
        #pragma shader_feature_local_fragment _LIGHTINGMETHOD_UNITY_LAMBERT _LIGHTINGMETHOD_UNITY_BLINN_PHONG _LIGHTINGMETHOD_UNITY_STANDARD _LIGHTINGMETHOD_UNITY_STANDARD_SPECULAR _LIGHTINGMETHOD_CUSTOM
        #pragma shader_feature_local_fragment _NORMALCALCMETHOD_CENTRAL_DIFFERENCE _NORMALCALCMETHOD_FOREARD_DIFFERENCE _NORMALCALCMETHOD_TETRAHEDRON
        #pragma shader_feature_local_fragment _NORMALCALCOPTIMIZE_UNROLL _NORMALCALCOPTIMIZE_LOOP _NORMALCALCOPTIMIZE_LOOP_WITHOUT_LUT
        #pragma shader_feature_local_fragment _ _ENABLE_REFLECTION_PROBE

        #include "UnityCG.cginc"
        #include "UnityStandardUtils.cginc"
        #include "AutoLight.cginc"
        #include "include/Math.cginc"
        #include "include/RefProbe.cginc"
        #include "include/Utils.cginc"
        #include "include/LightingUtils.cginc"
        #include "include/SDF.cginc"
        #include "include/VertCommon.cginc"

#if defined(UNITY_COMPILER_HLSL) \
    || defined(SHADER_API_GLCORE) \
    || defined(SHADER_API_GLES3) \
    || defined(SHADER_API_METAL) \
    || defined(SHADER_API_VULKAN) \
    || defined(SHADER_API_GLES) \
    || defined(SHADER_API_D3D11)
        #pragma warning (default : 3200 3201 3202 3203 3204 3205 3206 3207 3208 3209)
        #pragma warning (default : 3550 3551 3552 3553 3554 3555 3556 3557 3558 3559)
        #pragma warning (default : 3560 3561 3562 3563 3564 3565 3566 3567 3568 3569)
        #pragma warning (default : 3570 3571 3572 3573 3574 3575 3576 3577 3578 3579)
        #pragma warning (default : 3580 3581 3582 3583 3584 3585 3586 3587 3588)
        #pragma warning (default : 4700 4701 4702 4703 4704 4705 4706 4707 4708 4710)
        #pragma warning (default : 4711 4712 4713 4714 4715 4716 4717)
#endif

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
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
        float3 getNormal(float3 p);
        fixed getLightAttenuation(v2f_raymarching_forward fi, float3 worldPos);


        //! Color of the objects.
        uniform half4 _Color;
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
        //! Marching Factor.
        uniform float _MarchingFactor;


        /*!
         * @brief Fragment shader function.
         * @param [in] fi  Input data from vertex shader.
         * @return Output of each texels (fout).
         */
        fout frag(v2f_raymarching_forward fi)
        {
            const float3 localRayDir = normalize(fi.localRayDirVector);

            const rmout ro = rayMarch(fi.localRayOrigin, localRayDir);
            if (!ro.isHit) {
                discard;
            }

            const float3 localFinalPos = fi.localRayOrigin + localRayDir * ro.rayLength;
            const float3 worldFinalPos = objectToWorldPos(localFinalPos);

#if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
            const float4 lmap = fi.lmap;
#else
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
#endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)

            const half4 color = calcLighting(
                _Color,
                worldFinalPos,
                UnityObjectToWorldNormal(getNormal(localFinalPos)),
                getLightAttenuation(fi, worldFinalPos),
                lmap);

            const float4 projPos = UnityWorldToClipPos(worldFinalPos);

            fout fo;
            UNITY_INITIALIZE_OUTPUT(fout, fo);
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
#if defined(UNITY_PASS_FORWARDBASE)
            const int maxLoop = _MaxLoop;
#elif defined(UNITY_PASS_FORWARDADD)
            const int maxLoop = _MaxLoopForwardAdd;
#elif defined(UNITY_PASS_SHADOWCASTER)
            const int maxLoop = _MaxLoopShadowCaster;
#endif  // defined(UNITY_PASS_FORWARDBASE)

            rmout ro;
            ro.rayLength = 0.0;
            ro.isHit = false;

            // Marching Loop.
            for (int i = 0; i < maxLoop; i = (ro.isHit || ro.rayLength > _MaxRayLength) ? 0x7fffffff : i + 1) {
                const float d = map(rayOrigin + rayDir * ro.rayLength);
                ro.isHit = d < _MinRayLength;
                ro.rayLength += d * _MarchingFactor;
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
            return sdSphere(p, 0.5);
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
#if defined(_LIGHTINGMETHOD_UNITY_LAMBERT)
            return calcLightingUnityLambert(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTINGMETHOD_UNITY_BLINN_PHONG)
            return calcLightingUnityBlinnPhong(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTINGMETHOD_UNITY_STANDARD)
            return calcLightingUnityStandard(color, worldPos, worldNormal, atten, lmap);
#elif defined(_LIGHTINGMETHOD_UNITY_STANDARD_SPECULAR)
            return calcLightingUnityStandardSpecular(color, worldPos, worldNormal, atten, lmap);
#else
            const float3 worldViewDir = normalize(_WorldSpaceCameraPos - worldPos);
            const float3 worldLightDir = normalizedWorldSpaceLightDir(worldPos);
            const fixed3 lightCol = _LightColor0.rgb * atten;

            // Lambertian reflectance.
            const float nDotL = dot(worldNormal, worldLightDir);
#    if defined(_DIFFUSEMODE_SQUARED_HALF_LAMBERT)
            const half3 diffuse = lightCol * sq(nDotL * 0.5 + 0.5);
#    elif defined(_DIFFUSEMODE_HALF_LAMBERT)
            const half3 diffuse = lightCol * (nDotL * 0.5 + 0.5);
#    elif defined(_DIFFUSEMODE_LAMBERT)
            const half3 diffuse = lightCol * max(0.0, nDotL);
#    else
            const half3 diffuse = half3(1.0, 1.0, 1.0);
#    endif  // defined(_DIFFUSEMODE_SQUARED_HALF_LAMBERT)

            // Specular reflection.
#    ifdef _SPECULARMODE_HALF_VECTOR
            const half3 specular = pow(max(0.0, dot(normalize(worldLightDir + worldViewDir), worldNormal)), _SpecPower) * _SpecColor.xyz * lightCol;
#    elif _SPECULARMODE_ORIGINAL
            const half3 specular = pow(max(0.0, dot(reflect(-worldLightDir, worldNormal), worldViewDir)), _SpecPower) * _SpecColor.xyz * lightCol;
#    else
            const half3 specular = half3(0.0, 0.0, 0.0);
#    endif  // _SPECULARMODE_HALF_VECTOR

            // Ambient color.
#    if defined(_AMBIENTMODE_SH)
            const half3 ambient = ShadeSHPerPixel(
                worldNormal,
#       ifdef VERTEXLIGHT_ON
                Shade4PointLights(
                    unity_4LightPosX0,
                    unity_4LightPosY0,
                    unity_4LightPosZ0,
                    unity_LightColor[0].rgb,
                    unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb,
                    unity_LightColor[3].rgb,
                    unity_4LightAtten0,
                    worldPos,
                    worldNormal),
#       else
                half3(0.0, 0.0, 0.0),
#       endif  // VERTEXLIGHT_ON
                worldPos);
#    elif defined(_AMBIENTMODE_LEGACY)
            const half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
#    else
            const half3 ambient = half3(0.0, 0.0, 0.0);
#    endif  // defined(_AMBIENTMODE_SH)

#    ifdef _ENABLE_REFLECTION_PROBE
            const half4 refColor = getRefProbeColor(
                UnityObjectToWorldNormal(reflect(-worldViewDir, worldNormal)),
                worldPos);
            const half4 outColor = half4((diffuse + ambient) * lerp(_Color.rgb, refColor.rgb, _Glossiness) + specular, _Color.a);
#    else
            const half4 outColor = half4((diffuse + ambient) * _Color.rgb + specular, _Color.a);
#    endif  // _ENABLE_REFLECTION_PROBE
            return outColor;
#endif  // defined(_LIGHTINGMETHOD_LAMBERT)
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
            static const float h = 0.0001;
#if defined(_NORMALCALCMETHOD_CENTRAL_DIFFERENCE)
#    if defined(_NORMALCALCOPTIMIZE_UNROLL)
            static const float2 d = float2(h, 0.0);

            return normalize(
                float3(
                    map(p + d.xyy) - map(p - d.xyy),
                    map(p + d.yxy) - map(p - d.yxy),
                    map(p + d.yyx) - map(p - d.yyx)));
#    elif defined(_NORMALCALCOPTIMIZE_LOOP)
            static const float3 s = float3(1.0, -1.0, 0.0);  // used only for generating k.
            static const float3 k[6] = {s.xzz, s.yzz, s.zxz, s.zyz, s.zzx, s.zzy};

            float3 normal = float3(0.0, 0.0, 0.0);

            UNITY_LOOP
            for (int i = 0; i < 6; i++) {
                normal += k[i] * map(p + h * k[i]);
            }

            return normalize(normal);
#    else
            float3 normal = float3(0.0, 0.0, 0.0);

            UNITY_LOOP
            for (int i = 0; i < 6; i++) {
                const int j = i >> 1;
                const float4 v = float4(int4((int3(j + 3, i, j) >> 1), i) & 1);
                const float3 k = v.xyz * (v.w * 2.0 - 1.0);
                normal += k * map(p + h * k);
            }

            return normalize(normal);
#    endif  // defined(_NORMALCALCOPTIMIZE_UNROLL)
#elif defined(_NORMALCALCMETHOD_FORWARD_DIFFERENCE)
#    if defined(_NORMALCALCOPTIMIZE_UNROLL)
            static const float2 d = float2(h, 0.0);

            const float mp = map(p);

            return normalize(
                float3(
                    map(p + d.xyy) - mp,
                    map(p + d.yxy) - mp,
                    map(p + d.yyx) - mp));
#    elif defined(_NORMALCALCOPTIMIZE_LOOP)
            static const float3 s = float3(1.0, -1.0, 0.0);  // used only for generating k.
            static const float3 k[3] = {s.xzz, s.zxz, s.zzx};

            float3 normal = (-map(p)).xxx;

            UNITY_LOOP
            for (int i = 0; i < 3; i++) {
                normal += k[i] * map(p + h * k[i]);
            }

            return normalize(normal);
#    else
            float3 normal = (-map(p)).xxx;

            UNITY_LOOP
            for (int i = 0; i < 3; i++) {
                const float3 k = float3(int3((i + 3) >> 1, i, i >> 1) & 1);
                normal += k * map(p + h * k);
            }

            return normalize(normal);
#    endif  // defined(_NORMALCALCOPTIMIZE_UNROLL)
#else
#    if defined(_NORMALCALCOPTIMIZE_UNROLL)
            static const float2 s = float2(1.0, -1.0);
            static const float2 hs = h * s;

            return normalize(
                s.xyy * map(p + hs.xyy)
                    + s.yxy * map(p + hs.yxy)
                    + s.yyx * map(p + hs.yyx)
                    + map(p + hs.xxx).xxx);
#    elif defined(_NORMALCALCOPTIMIZE_LOOP)
            static const float2 s = float2(1.0, -1.0);  // used only for generating k.
            static const float3 k[4] = {s.xyy, s.yxy, s.yyx, s.xxx};

            float3 normal = float3(0.0, 0.0, 0.0);

            UNITY_LOOP
            for (int i = 0; i < 4; i++) {
                normal += k[i] * map(p + h * k[i]);
            }

            return normalize(normal);
#    else
            float3 normal = float3(0.0, 0.0, 0.0);

            UNITY_LOOP
            for (int i = 0; i < 4; i++) {
                const float3 k = float3(int3((i + 3) >> 1, i, i >> 1) & 1) * 2.0 - 1.0;
                normal += k * map(p + h * k);
            }

            return normalize(normal);
#    endif  // defined(_NORMALCALCOPTIMIZE_UNROLL)
#endif  // defined(_NORMALCALCMETHOD_CENTRAL_DIFFERENCE)
        }

        /*!
         * @brief Get Light Attenuation.
         *
         * @param [in] fi  Input data for fragment shader.
         * @param [in] worldPos  World coordinate.
         * @return Light Attenuation Value.
         */
        fixed getLightAttenuation(v2f_raymarching_forward fi, float3 worldPos)
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
        ENDCG

        Pass
        {
            Name "FORWARD_BASE"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            CGPROGRAM
            #pragma vertex vertRayMarchingForward
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

            Blend [_SrcBlend] One, [_SrcBlendAlpha] One
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vertRayMarchingForward
            #pragma fragment frag

            // Keywords:
            //   POINT
            //   DIRECTIONAL
            //   SPOT
            //   POINT_COOKIE
            //   DIRECTIONAL_COOKIE
            //   SHADOWS_DEPTH
            //   SHADOWS_SCREEN
            //   SHADOWS_CUBE
            //   SHADOWS_SOFT
            //   SHADOWS_SHADOWMASK
            //   LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fwdadd_fullshadows
            ENDCG
        }  // ForwardAdd

        Pass
        {
            Name "SHADOW_CASTER"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            Cull Back
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vertRayMarchingShadowCaster
            #pragma fragment fragShadowCaster

            // Keywords:
            //   SHADOWS_DEPTH
            //   SHADOWS_CUBE
            #pragma multi_compile_shadowcaster


            /*!
             * @brief Fragment shader function for ShadowCaster Pass.
             * @param [in] fi  Input data from vertex shader.
             * @return Output of each texels (fout).
             */
            fout fragShadowCaster(v2f_raymarching_shadowcaster fi)
            {
                const float3 localRayDir = normalize(fi.localRayDirVector);

                const rmout ro = rayMarch(fi.localRayOrigin, localRayDir);
                if (!ro.isHit) {
                    discard;
                }

                const float3 worldFinalPos = objectToWorldPos(fi.localRayOrigin + localRayDir * ro.rayLength);

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

    CustomEditor "Koturn.KRayMarching.KRayMarchingBaseGUI"
}
