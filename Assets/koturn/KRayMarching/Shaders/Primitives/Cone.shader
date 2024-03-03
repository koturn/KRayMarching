﻿Shader "koturn/KRayMarching/Primitives/Cone"
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
        _AssumeInside ("Assume render target is inside object", Int) = 2

        _MaxInsideLength ("Maximum length inside an object", Float) = 1.7321

        [KeywordEnum(Normal, Over Relax, Accelaration, Auto Relax)]
        _StepMethod ("Marching step method", Int) = 2

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0

        _OverRelaxFactor ("Coefficient of Over Relaxation Sphere Tracing", Range(1.0, 2.0)) = 1.2

        _AccelarationFactor ("Coefficient of Accelarating Sphere Tracing", Range(0.0, 1.0)) = 0.95

        _AutoRelaxFactor ("Coefficient of Automatic Step Size Relaxation", Range(0.0, 1.0)) = 0.95

        [KeywordEnum(None, Step, Ray Length)]
        _DebugView ("Debug view mode", Int) = 0

        [IntRange]
        _DebugStepDiv ("Divisor of number of ray steps for debug view", Range(1, 1024)) = 24

        _DebugRayLengthDiv ("Divisor of ray length for debug view", Range(0.01, 1000.0)) = 5.0


        // ---------------------------------------------------------------------
        [Header(SDF Parameters)]
        [Space(8)]
        _Angle ("Angle of the Cone (Radians)", Float) = 0.523599
        _Height ("Height of the Cone", Float) = 0.5

        [Toggle(_EXACT_ON)]
        _Exact ("Exact", Int) = 1


        // ---------------------------------------------------------------------
        [Header(Lighting Parameters)]
        [Space(8)]
        [NoScaleOffset]
        _MainTex ("Main texture", 2D) = "white" {}

        _Color ("Tint color for main texture", Color) = (1.0, 1.0, 1.0, 1.0)

        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Unlit)]
        _Lighting ("Lighting method", Int) = 2

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0


        // ---------------------------------------------------------------------
        [Header(Rendering Parameters)]
        [Space(8)]
        [Toggle(_NODEPTH_ON)]
        _NoDepth ("Disable depth ouput", Int) = 0

        [Toggle(_NOFORWARDADD_ON)]
        _NoForwardAdd ("Disable ForwardAdd", Int) = 0

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
        #pragma shader_feature_local_fragment _ _NODEPTH_ON
        #pragma shader_feature_local_fragment _ _EXACT_ON
        #include "Template.cginc"

        //! Angle of the Cone.
        uniform float _Angle;
        //! Height of the Cone.
        uniform float _Height;


        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p)
        {
        #ifdef _EXACT_ON
            return sdConeExact(p, _Angle, _Height);
        #else
            return sdCone(p, _Angle, _Height);
        #endif  // _NOT_EXACT_ON
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
            #pragma vertex vertRayMarchingForward
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
            #pragma vertex vertRayMarchingForward
            #pragma fragment fragRayMarchingForward

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _NOFORWARDADD_ON
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

    CustomEditor "Koturn.KRayMarching.Inspectors.Primitives.ConeGUI"
}
