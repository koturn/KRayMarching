Shader "koturn/KRayMarching/CrossBeads"
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

        _MinRayLength ("Minimum length of the ray", Float) = 0.001

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

        _OverRelaxFactor ("Coeeficient of Over Relaxation Sphere Tracing", Range(1.0, 2.0)) = 1.2

        _AccelarationFactor ("Coeeficient of Accelarating Sphere Tracing", Range(0.0, 1.0)) = 0.8

        _AutoRelaxFactor ("Coeeficient of Automatic Step Size Relaxation", Range(0.0, 1.0)) = 0.8

        [Toggle(_USE_FAST_INVTRIFUNC_ON)]
        _UseFastInvTriFunc ("Use Fast Inverse Trigonometric Functions", Int) = 1

        [KeywordEnum(None, Step, Ray Length)]
        _DebugView ("Debug view mode", Int) = 0

        [IntRange]
        _DebugStepDiv ("Divisor of number of ray steps for debug view", Range(1, 1024)) = 24

        _DebugRayLengthDiv ("Divisor of number of ray length for debug view", Range(0.01, 1000.0)) = 5.0


        // ---------------------------------------------------------------------
        [Header(SDF Parameters)]
        [Space(8)]
        _BeadsBaseColor ("Base color of torus", Color) = (0.8, 0.4, 0.4, 1.0)

        _BeadsNumber ("Number of beads", Int) = 12
        _TorusThickness ("Thickness of torus", Float) = 0.005
        _TorusRadius ("Radius of torus", Float) = 0.4
        _AnimSpeed ("Animation speed", Float) = 0.5
        _BeadsSize ("Size of beads", Float) = 0.05


        // ---------------------------------------------------------------------
        [Header(Lighting Parameters)]
        [Space(8)]
        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Unlit)]
        _Lighting ("Lighting method", Int) = 2

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0

        [KeywordEnum(Off, On, Additive Only)]
        _VRCLightVolumes ("VRC Light Volumes", Int) = 1

        [KeywordEnum(Off, On, Dominant Dir)]
        _VRCLightVolumesSpecular ("VRC Light Volumes Specular", Int) = 0

        [Toggle(_LTCGI_ON)]
        _LTCGI ("LTCGI", Int) = 0


        // ---------------------------------------------------------------------
        [Header(Rendering Parameters)]
        [Space(8)]
        [KeywordEnum(Off, On, LessEqual, GreaterEqual)]
        _SvDepth ("Depth output", Int) = 3

        [ToggleOff(_FORWARDADD_OFF)]
        _ForwardAdd ("Enable ForwardAdd path", Int) = 1

        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

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
            "LTCGI" = "_LTCGI"
        }

        Cull [_Cull]
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
        #pragma shader_feature_local_fragment _ _USE_FAST_INVTRIFUNC_ON

        #define RAYMARCHING_SDF map
        #define RAYMARCHING_GET_BASE_COLOR getBaseColor

        float map(float3 p);
        float map(float3 p, out float hueOffset);
        half4 getBaseColor(float3 p, float3 normal, float rayLength);

        #include "RayMarchingCore.cginc"

        #if defined(_USE_FAST_INVTRIFUNC_ON)
        #    define atan2(x, y)  atan2Fast(x, y)
        #endif  // defined(_USE_FAST_INVTRIFUNC_ON)


        UNITY_INSTANCING_BUFFER_START(Props)
        //! Base color of torus.
        UNITY_DEFINE_INSTANCED_PROP(float3, _BeadsBaseColor)
        //! Number of divisions.
        UNITY_DEFINE_INSTANCED_PROP(float, _BeadsNumber)
        //! Thickness of torus.
        UNITY_DEFINE_INSTANCED_PROP(float, _TorusThickness)
        //! Radius of torus.
        UNITY_DEFINE_INSTANCED_PROP(float, _TorusRadius)
        //! Animation speed.
        UNITY_DEFINE_INSTANCED_PROP(float, _AnimSpeed)
        //! Animation speed.
        UNITY_DEFINE_INSTANCED_PROP(float, _BeadsSize)
        UNITY_INSTANCING_BUFFER_END(Props)


        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p)
        {
            float _;
            return map(p, /* out */ _);
        }

        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @param [out] hueOffset  Offset of hue.
         * @return Signed Distance to the objects.
         */
        float map(float3 p, out float hueOffset)
        {
            hueOffset = 1000.0;

            const float torusRadius = UNITY_ACCESS_INSTANCED_PROP(Props, _TorusRadius);
            const float torusThickness = UNITY_ACCESS_INSTANCED_PROP(Props, _TorusThickness);
            float minDist = sdTorus(p.xzy, torusRadius, torusThickness);
            // 0.5 * cos(UNITY_TWO_PI * t / UNITY_ACCESS_INSTANCED_PROP(Props, _BeadsNumber)) + 0.5;
            // 0.5 * cos(UNITY_HALF_PI * t / UNITY_ACCESS_INSTANCED_PROP(Props, _BeadsNumber)) + 0.5;

            /// _Time.y = 0.0;

            const float beadsNumber = UNITY_ACCESS_INSTANCED_PROP(Props, _BeadsNumber);
            const float rotUnit = UNITY_HALF_PI - UNITY_HALF_PI / beadsNumber;
            const float t = _Time.y * UNITY_ACCESS_INSTANCED_PROP(Props, _AnimSpeed);
            const float beadsSize = UNITY_ACCESS_INSTANCED_PROP(Props, _BeadsSize);
            for (uint i = 0; i < 2; i++) {
                const float s = i % 2 == 0 ? 1.0 : -1.0;
                const float rotInvertOffset = (UNITY_PI * i) / beadsNumber;

                float3 p1 = p;
                p1.xy = rotate2D(p1.xy, s * t + rotInvertOffset - rotUnit);

                float pIndex;
                p1.xy = pmod(p1.xy, atan2Fast(p1.y, p1.x), beadsNumber, /* out */ pIndex);

                const float c = 0.5 * sin(beadsNumber * t + (UNITY_PI * i)) + 0.5;

                const float beadsSize1 = beadsSize * 0.9;
                const float beadsSize2 = beadsSize;

                const float d1 = sdSphere(p1 - float3(torusRadius, 0.0, 0.0), beadsSize1);
                const float d2 = sdTorus(p1.zyx - float3(0.0, 0.0, torusRadius), beadsSize2, torusThickness);

                // float c2 = 0.5 * sin(beadsNumber * t + (UNITY_PI * i)) + 0.5;
                // c2 = 0.5 * c2 + 0.5;
                // const float d1 = sdSphere(p1 - float3(torusRadius, 0.0, 0.0), lerp(beadsSize2, beadsSize1, c2));
                // const float d2 = sdTorus(p1.zyx - float3(0.0, 0.0, torusRadius), lerp(beadsSize1, beadsSize2, c2), torusThickness);

                const float d = lerp(d1, d2, c);

                UNITY_FLATTEN
                if (d < minDist) {
                    minDist = d;
                    hueOffset = frac((pIndex + beadsNumber + i / 2.0) / beadsNumber);
                }
            }

            return minDist;
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
            float hueOffset;
            map(p, /* out */ hueOffset);
            return half4(hueOffset == 1000.0
                ? float3(0.8, 0.8, 0.8)
                : rgbAddHue(UNITY_ACCESS_INSTANCED_PROP(Props, _BeadsBaseColor), hueOffset), 1.0);
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
            #pragma vertex vertRayMarching
            #pragma fragment fragRayMarchingForward

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma shader_feature_local_fragment _ _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT
            #pragma shader_feature_local_fragment _VRCLIGHTVOLUMES_OFF _VRCLIGHTVOLUMES_ON _VRCLIGHTVOLUMES_ADDITIVE_ONLY
            #pragma shader_feature_local_fragment _VRCLIGHTVOLUMESSPECULAR_OFF _VRCLIGHTVOLUMESSPECULAR_ON _VRCLIGHTVOLUMESSPECULAR_DOMINANT_DIR
            #pragma shader_feature_local_fragment _ _LTCGI_ON
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
            #pragma vertex vertRayMarching
            #pragma fragment fragRayMarchingForward

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _FORWARDADD_OFF
            #pragma shader_feature_local_fragment _ _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT
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

            CGPROGRAM
            #pragma vertex vertRayMarchingShadowCaster
            #pragma fragment fragRayMarchingShadowCaster

            #pragma multi_compile_shadowcaster
            ENDCG
        }
    }

    CustomEditor "Koturn.KRayMarching.Inspectors.BeadsGUI"
}
