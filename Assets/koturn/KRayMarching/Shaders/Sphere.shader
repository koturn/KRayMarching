Shader "koturn/KRayMarching/Sphere"
{
    Properties
    {
        // ---------------------------------------------------------------------
        [Header(Ray Marching Parameters)]
        [Space(8)]
        [IntRange]
        _MaxLoop ("Maximum loop count for ForwardBase", Range(8, 1024)) = 128

        [IntRange]
        _MaxLoopForwardAdd ("Maximum loop count for ForwardAdd", Range(8, 1024)) = 64

        [IntRange]
        _MaxLoopShadowCaster ("Maximum loop count for ShadowCaster", Range(8, 1024)) = 32

        _MinRayLength ("Minimum length of the ray", Float) = 0.01

        [KeywordEnum(Use Property Value, Far Clip, Depth Texture)]
        _MaxRayLengthMode ("Maximum ray length mode", Int) = 1

        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        [KeywordEnum(Object, World)]
        _CalcSpace ("Calculation space", Int) = 0

        [KeywordEnum(None, Simple, Max Length)]
        _AssumeInside ("Assume render target is inside object", Int) = 0

        _MaxInsideLength ("Maximum length inside an object", Float) = 1.7321

        [KeywordEnum(Normal, Over Relax, Accelaration, Auto Relax)]
        _StepMethod ("Marching step method", Int) = 0

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0

        _OverRelaxFactor ("Coefficient of Over Relaxation Sphere Tracing", Range(1.0, 2.0)) = 1.2

        _AccelarationFactor ("Coefficient of Accelarating Sphere Tracing", Range(0.0, 1.0)) = 0.8

        _AutoRelaxFactor ("Coefficient of Automatic Step Size Relaxation", Range(0.0, 1.0)) = 0.8

        [KeywordEnum(None, Step, Ray Length)]
        _DebugView ("Debug view mode", Int) = 0

        [IntRange]
        _DebugStepDiv ("Divisor of number of ray steps for debug view", Range(1, 1024)) = 24

        _DebugRayLengthDiv ("Divisor of ray length for debug view", Range(0.01, 1000.0)) = 5.0


        // ---------------------------------------------------------------------
        [Header(SDF Parameters)]
        [Space(8)]
        _Color ("Color of the objects", Color) = (1.0, 1.0, 1.0, 1.0)


        // ---------------------------------------------------------------------
        [Header(Lighting Parameters)]
        [Space(8)]
        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Unlit, Custom)]
        _Lighting ("Lighting method", Int) = 2

        [Toggle(_ENABLE_REFLECTION_PROBE)]
        _EnableReflectionProbe ("Enable Reflection Probe", Int) = 1

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0

        [KeywordEnum(None, Lambert, Half Lambert, Squared Half Lambert)]
        _DiffuseMode ("Reflection Mode", Int) = 3

        [KeywordEnum(None, Original, Half Vector)]
        _SpecularMode ("Specular Mode", Int) = 2

        [KeywordEnum(None, Legacy, SH)]
        _AmbientMode ("Ambient Mode", Int) = 2

        [KeywordEnum(Central Difference, Forward Differece, Tetrahedron)]
        _NormalCalcMethod ("Normal Calculation Mode", Int) = 2

        [KeywordEnum(Unroll, Loop, Loop Without LUT)]
        _NormalCalcOptimize ("Normal Calculation Optimization", Int) = 1

        [KeywordEnum(Off, On, Additive Only)]
        _VRCLightVolumes ("VRC Light Volumes", Int) = 1

        [KeywordEnum(Off, On, Dominant Dir)]
        _VRCLightVolumesSpecular ("VRC Light Volumes Specular", Int) = 0


        // ---------------------------------------------------------------------
        [Header(Rendering Parameters)]
        [Space(8)]
        [KeywordEnum(Off, On, LessEqual, GreaterEqual)]
        _SvDepth ("Depth output", Int) = 3

        [ToggleOff(_FORWARDADD_OFF)]
        _ForwardAdd ("Enable ForwardAdd path", Int) = 1

        // [Enum(UnityEngine.Rendering.CullMode)]
        [KeywordEnum(Off, Front, Back)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

        [HideInInspector]
        _Mode ("Rendering Mode", Int) = 1

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

        [Enum(False, 0, True, 1)]
        _ZClip ("ZClip", Int) = 1  // Default: True

        _OffsetFactor ("Offset Factor", Range(-1.0, 1.0)) = 0
        _OffsetUnit ("Offset Units", Range(-1.0, 1.0)) = 0

        [ColorMask]
        _ColorMask ("Color Mask", Int) = 15

        [Enum(Off, 0, On, 1)]
        _AlphaToMask ("Alpha To Mask", Int) = 0  // Default: Off


        // ---------------------------------------------------------------------
        [Header(Stencil Parameters)]
        [Space(8)]
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
            // "RenderType" = "Transparent"
            "DisableBatching" = "True"
            "IgnoreProjector" = "True"
            "VRCFallback" = "Hidden"
        }

        Cull [_Cull]
        BlendOp [_BlendOp], [_BlendOpAlpha]
        ZClip [_ZClip]
        Offset [_OffsetFactor], [_OffsetUnit]
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
        #pragma target 5.0
        #pragma multi_compile_instancing
        #pragma shader_feature_local _ _CALCSPACE_WORLD
        #pragma shader_feature_local _ _MAXRAYLENGTHMODE_FAR_CLIP _MAXRAYLENGTHMODE_DEPTH_TEXTURE
        #pragma shader_feature_local _ _ASSUMEINSIDE_SIMPLE _ASSUMEINSIDE_MAX_LENGTH
        #pragma shader_feature_local_fragment _ _STEPMETHOD_OVER_RELAX _STEPMETHOD_ACCELARATION _STEPMETHOD_AUTO_RELAX
        #pragma shader_feature_local_fragment _SVDEPTH_OFF _SVDEPTH_ON _SVDEPTH_LESSEQUAL _SVDEPTH_GREATEREQUAL
        #pragma shader_feature_local_fragment _ _CULL_FRONT _CULL_BACK
        #pragma shader_feature_local_fragment _NORMALCALCMETHOD_CENTRAL_DIFFERENCE _NORMALCALCMETHOD_FOREARD_DIFFERENCE _NORMALCALCMETHOD_TETRAHEDRON
        #pragma shader_feature_local_fragment _NORMALCALCOPTIMIZE_UNROLL _NORMALCALCOPTIMIZE_LOOP _NORMALCALCOPTIMIZE_LOOP_WITHOUT_LUT

        #define RAYMARCHING_SDF map
        #if defined(_NORMALCALCMETHOD_CENTRAL_DIFFERENCE)
        #    define RAYMARCHING_CALC_NORMAL calcNormalCentralDiffRayMarching
        #elif defined(_NORMALCALCMETHOD_FOREARD_DIFFERENCE)
        #    define RAYMARCHING_CALC_NORMAL calcNormalForwardDiffRayMarching
        #else
        #    define RAYMARCHING_CALC_NORMAL calcNormalRayMarching
        #endif  // defined(_NORMALCALCMETHOD_CENTRAL_DIFFERENCE)
        #if defined(_NORMALCALCOPTIMIZE_UNROLL)
        #    define RAYMARCHING_PREFER_UNROLL
        #elif defined(_NORMALCALCOPTIMIZE_LOOP)
        #    define RAYMARCHING_UNROLL UNITY_LOOP
        #else
        #    define RAYMARCHING_UNROLL UNITY_LOOP
        #    define RAYMARCHING_CALC_NORMAL_WITHOUT_LUT
        #endif  // defined(_NORMALCALCOPTIMIZE_UNROLL)
        #define RAYMARCHING_GET_BASE_COLOR getBaseColor
        #define RAYMARCHING_CALC_LIGHTING calcLighting

        float map(float3 p);
        half4 getBaseColor(float3 p, float3 normal, float rayLength);
        half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
        half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);

        #if defined(UNITY_COMPILER_HLSL) \
            || defined(SHADER_API_GLCORE) \
            || defined(SHADER_API_GLES3) \
            || defined(SHADER_API_METAL) \
            || defined(SHADER_API_VULKAN) \
            || defined(SHADER_API_GLES) \
            || defined(SHADER_API_D3D11)
        #    pragma warning (default : 3200 3201 3202 3203 3204 3205 3206 3207 3208 3209)
        #    pragma warning (default : 3550 3551 3552 3553 3554 3555 3556 3557 3558 3559)
        #    pragma warning (default : 3560 3561 3562 3563 3564 3565 3566 3567 3568 3569)
        #    pragma warning (default : 3570 3571 3572 3573 3574 3575 3576 3577 3578 3579)
        #    pragma warning (default : 3580 3581 3582 3583 3584 3585 3586 3587 3588)
        #    pragma warning (default : 4700 4701 4702 4703 4704 4705 4706 4707 4708 4710)
        #    pragma warning (default : 4711 4712 4713 4714 4715 4716 4717)
        #endif

        #include "RayMarchingCore.cginc"
        #include "include/RefProbe.cginc"


        UNITY_INSTANCING_BUFFER_START(Props)
        //! Color of the objects.
        UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
        UNITY_INSTANCING_BUFFER_END(Props)


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
        #if defined(_LIGHTING_CUSTOM)
            return calcLightingCustom(color, worldPos, worldNormal, atten, lmap);
        #else
            return calcLightingUnity(color, worldPos, worldNormal, atten, lmap);
        #endif  // defined(_LIGHTING_CUSTOM)
        }

        /*!
         * Calculate lighting using custom method.
         * @param [in] color  Base color.
         * @param [in] worldPos  World coordinate.
         * @param [in] worldNormal  Normal in world space.
         * @param [in] atten  Light attenuation.
         * @param [in] lmap  Light map parameters.
         * @return Color with lighting applied.
         */
        half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap)
        {
            const float3 worldViewDir = normalize(_WorldSpaceCameraPos - worldPos);
            const float3 worldLightDir = normalizedWorldSpaceLightDir(worldPos);
            const fixed3 lightCol = _LightColor0.rgb * atten;

            // Lambertian reflectance.
            const float nDotL = dot(worldNormal, worldLightDir);
        #if defined(_DIFFUSEMODE_SQUARED_HALF_LAMBERT)
            const half3 diffuse = lightCol * sq(nDotL * 0.5 + 0.5);
        #elif defined(_DIFFUSEMODE_HALF_LAMBERT)
            const half3 diffuse = lightCol * (nDotL * 0.5 + 0.5);
        #elif defined(_DIFFUSEMODE_LAMBERT)
            const half3 diffuse = lightCol * max(0.0, nDotL);
        #else
            const half3 diffuse = half3(1.0, 1.0, 1.0);
        #endif  // defined(_DIFFUSEMODE_SQUARED_HALF_LAMBERT)

            // Specular reflection.
        #if defined(_SPECULARMODE_HALF_VECTOR)
            const float3 halfDir = normalize(worldLightDir + worldViewDir);
            const half3 specular = pow(max(0.0, dot(halfDir, worldNormal)), _SpecPower) * _SpecColor.xyz * lightCol;
        #elif defined(_SPECULARMODE_ORIGINAL)
            const float3 refDir = reflect(-worldLightDir, worldNormal);
            const half3 specular = pow(max(0.0, dot(refDir, worldViewDir)), _SpecPower) * _SpecColor.xyz * lightCol;
        #else
            const half3 specular = half3(0.0, 0.0, 0.0);
        #endif  // defined(_SPECULARMODE_HALF_VECTOR)

            // Ambient color.
        #if defined(_AMBIENTMODE_SH)
            const half3 ambient = ShadeSHPerPixel(
                worldNormal,
        #   if defined(VERTEXLIGHT_ON)
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
        #   else
                half3(0.0, 0.0, 0.0),
        #   endif  // defined(VERTEXLIGHT_ON)
                worldPos);
        #elif defined(_AMBIENTMODE_LEGACY)
            const half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
        #else
            const half3 ambient = half3(0.0, 0.0, 0.0);
        #endif  // defined(_AMBIENTMODE_SH)

        #if defined(_ENABLE_REFLECTION_PROBE)
            const half3 refColor = getRefProbeColor(
                UnityObjectToWorldNormal(reflect(-worldViewDir, worldNormal)),
                worldPos).rgb;
            const half3 baseColor = lerp(color.rgb, refColor.rgb, _Glossiness);
        #else
            const half3 baseColor = color.rgb;
        #endif  // defined(_ENABLE_REFLECTION_PROBE)
            return half4((diffuse + ambient) * baseColor + specular, color.a);
        }

        /*!
         * @brief Get color of the object.
         * @param [in] p  Object/World space position.
         * @param [in] normal  Object/World space normal.
         * @param [in] rayLength  Ray length.
         * @return Base color of the object.
         */
        half4 getBaseColor(float3 p, float3 normal, float rayLength)
        {
            return UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
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
            #pragma vertex vertRayMarching
            #pragma fragment fragRayMarchingForward

            // keywords:
            //   DIRECTIONAL
            //   LIGHTMAP_ON
            //   DIRLIGHTMAP_COMBINED
            //   DYNAMICLIGHTMAP_ON
            //   LIGHTMAP_SHADOW_MIXING
            //   VERTEXLIGHT_ON
            //   LIGHTPROBE_SH
            #pragma multi_compile_fwdbase
            // keywords:
            //   FOG_LINEAR
            //   FOG_EXP
            //   FOG_EXP2
            #pragma multi_compile_fog
            #pragma shader_feature_local_fragment _ _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT _LIGHTING_CUSTOM
            #pragma shader_feature_local_fragment _ _DIFFUSEMODE_LAMBERT _DIFFUSEMODE_HALF_LAMBERT _DIFFUSEMODE_SQUARED_HALF_LAMBERT
            #pragma shader_feature_local_fragment _ _SPECULARMODE_ORIGINAL _SPECULARMODE_HALF_VECTOR
            #pragma shader_feature_local_fragment _ _AMBIENTMODE_LEGACY _AMBIENTMODE_SH
            #pragma shader_feature_local_fragment _ _ENABLE_REFLECTION_PROBE
            #pragma shader_feature_local_fragment _VRCLIGHTVOLUMES_OFF _VRCLIGHTVOLUMES_ON _VRCLIGHTVOLUMES_ADDITIVE_ONLY
            #pragma shader_feature_local_fragment _VRCLIGHTVOLUMESSPECULAR_OFF _VRCLIGHTVOLUMESSPECULAR_ON _VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR
            ENDCG
        }

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
            #pragma vertex vertRayMarching
            #pragma fragment fragRayMarchingForward

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
            // keywords:
            //   FOG_LINEAR
            //   FOG_EXP
            //   FOG_EXP2
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _FORWARDADD_OFF
            #pragma shader_feature_local_fragment _DEBUGVIEW_NONE _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT _LIGHTING_CUSTOM
            #pragma shader_feature_local_fragment _DIFFUSEMODE_NONE _DIFFUSEMODE_LAMBERT _DIFFUSEMODE_HALF_LAMBERT _DIFFUSEMODE_SQUARED_HALF_LAMBERT
            #pragma shader_feature_local_fragment _SPECULARMODE_NONE _SPECULARMODE_ORIGINAL _SPECULARMODE_HALF_VECTOR
            #pragma shader_feature_local_fragment _AMBIENTMODE_NONE _AMBIENTMODE_LEGACY _AMBIENTMODE_SH
            #pragma shader_feature_local_fragment _ _ENABLE_REFLECTION_PROBE
            ENDCG
        }

        Pass
        {
            Name "DEFERRED"
            Tags
            {
                "LightMode" = "Deferred"
            }

            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            CGPROGRAM
            #pragma vertex vertRayMarching
            #pragma fragment fragRayMarchingDeferred

            #pragma exclude_renderers nomrt

            // keywords:
            //   LIGHTMAP_ON
            //   DIRLIGHTMAP_COMBINED
            //   DYNAMICLIGHTMAP_ON
            //   UNITY_HDR_ON
            //   SHADOWS_SHADOWMASK
            //   LIGHTPROBE_SH
            #pragma multi_compile_prepassfinal
            #pragma shader_feature_local_fragment _ _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT _LIGHTING_CUSTOM
            #pragma shader_feature_local_fragment _ _DIFFUSEMODE_LAMBERT _DIFFUSEMODE_HALF_LAMBERT _DIFFUSEMODE_SQUARED_HALF_LAMBERT
            #pragma shader_feature_local_fragment _ _SPECULARMODE_ORIGINAL _SPECULARMODE_HALF_VECTOR
            #pragma shader_feature_local_fragment _ _AMBIENTMODE_LEGACY _AMBIENTMODE_SH
            #pragma shader_feature_local_fragment _ _ENABLE_REFLECTION_PROBE
            ENDCG
        }

        Pass
        {
            Name "SHADOW_CASTER"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vertRayMarchingShadowCaster
            #pragma fragment fragRayMarchingShadowCaster

            // Keywords:
            //   SHADOWS_DEPTH
            //   SHADOWS_CUBE
            #pragma multi_compile_shadowcaster
            ENDCG
        }
    }

    CustomEditor "Koturn.KRayMarching.Inspectors.KRayMarchingBaseGUI"
}
