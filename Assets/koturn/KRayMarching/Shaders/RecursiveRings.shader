Shader "koturn/KRayMarching/RecursiveRings"
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
        _TorusBaseColor ("Base color of torus", Color) = (0.8, 0.4, 0.4, 1.0)

        [IntRange]
        _TorusRecursion ("Number of recursion", Range(0.0, 4.0)) = 3
        _TorusNumber ("Number of divisions", Int) = 6
        _TorusThickness ("Thickness of torus", Float) = 0.0025
        _TorusRadius ("Radius of torus", Float) = 0.5
        _TorusAnimSpeed ("Animation speed", Float) = 0.5
        _TorusRadiusDecay ("Decay rate of radius per one recursion", Float) = 0.33
        _TorusThicknessDecay ("Decay rate of thickness per one recursion", Float) = 0.75
        _TorusAnimDecay ("Decay rate of animation speed per one recursion", Float) = 2.0


        // ---------------------------------------------------------------------
        [Header(Lighting Parameters)]
        [Space(8)]
        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Unlit)]
        _Lighting ("Lighting method", Int) = 2

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0

        [Toggle(_USE_FAST_INVTRIFUNC_ON)]
        _UseFastInvTriFunc ("Use Fast Inverse Trigonometric Functions", Int) = 1


        // ---------------------------------------------------------------------
        [Header(Rendering Parameters)]
        [Space(8)]
        [ToggleOff(_SVDEPTH_OFF)]
        _SvDepth ("Enable depth output", Int) = 1

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
        #pragma target 3.0
        #pragma shader_feature_local _ _CALCSPACE_WORLD
        #pragma shader_feature_local _ _MAXRAYLENGTHMODE_FAR_CLIP _MAXRAYLENGTHMODE_DEPTH_TEXTURE
        #pragma shader_feature_local _ _ASSUMEINSIDE_SIMPLE _ASSUMEINSIDE_MAX_LENGTH
        #pragma shader_feature_local_fragment _ _STEPMETHOD_OVER_RELAX _STEPMETHOD_ACCELARATION _STEPMETHOD_AUTO_RELAX
        #pragma shader_feature_local_fragment _ _SVDEPTH_OFF
        #pragma shader_feature_local_fragment _ _USE_FAST_INVTRIFUNC_ON

        #define RAYMARCHING_SDF map
        #define RAYMARCHING_GET_BASE_COLOR getBaseColor

        float map(float3 p);
        float map(float3 p, out float hueOffset);
        half4 getBaseColor(float3 p, float3 normal, float rayLength);

        #include "RayMarchingCore.cginc"

        #ifdef _USE_FAST_INVTRIFUNC_ON
        #    define atan2(x, y)  atan2Fast(x, y)
        #endif  // _USE_FAST_INVTRIFUNC_ON


        //! Base color of torus.
        uniform float3 _TorusBaseColor;
        //! Number of recursion.
        uniform int _TorusRecursion;
        //! Number of divisions.
        uniform float _TorusNumber;
        //! Thickness of torus.
        uniform float _TorusThickness;
        //! Radius of torus.
        uniform float _TorusRadius;
        //! Animation speed.
        uniform float _TorusAnimSpeed;
        //! Decay rate of radius per one recursion.
        uniform float _TorusRadiusDecay;
        //! Decay rate of thickness per one recursion.
        uniform float _TorusThicknessDecay;
        //! Decay rate of animation speed per one recursion.
        uniform float _TorusAnimDecay;


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
         * @param [in] hueOffset  Hue offset ob the object color.
         * @return Signed Distance to the objects.
         */
        float map(float3 p, out float hueOffset)
        {
            float2 rt = float2(_TorusRadius, _TorusThickness);
            float2 rtDecay = float2(_TorusRadiusDecay, _TorusThicknessDecay);
            float rotAngle = _Time.y * _TorusAnimSpeed;

            float minDist = sdTorus(p.xzy, rt.x, rt.y);
            hueOffset = 1000.0;

            float s = 1.0;
            for (int i = 0; i < _TorusRecursion; i++) {
                p.xy = rotate2D(p.xy, rotAngle * s);

                float angle = atan2(p.y, p.x);
                float pIndex;
                p.xy = float2(pmod(p.xy, angle, _TorusNumber, /* out */ pIndex) - float2(rt.x, 0.0));
                s = (uint(pIndex + _TorusNumber + 1.0) & 1) == 0 ? 1.0 : -1.0;
                // s = fmodglsl(pIndex, 2.0) < 0.5 ? 1.0 : -1.0;

                rt *= rtDecay;

                float d = min(minDist, sdTorus(p, rt.x, rt.y));
                UNITY_FLATTEN
                if (d < minDist) {
                    minDist = d;
                    hueOffset = angle / UNITY_TWO_PI;
                }

                p.xyz = p.zxy;
                rotAngle *= _TorusAnimDecay;
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
            float hueOffset = 1000.0;
            map(p, /* out */ hueOffset);
            return half4(hueOffset == 1000.0 ? float3(0.8, 0.8, 0.8) : rgbAddHue(_TorusBaseColor, hueOffset), 1.0);
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

    CustomEditor "Koturn.KRayMarching.Inspectors.RecursiveRingsGUI"
}
