Shader "koturn/KRayMarching/Primitive/RoundBox"
{
    Properties
    {
        // Common Ray Marching Parameters.
        [IntRange]
        _MaxLoop ("Maximum loop count for ForwardBase", Range(8, 1024)) = 128

        [IntRange]
        _MaxLoopForwardAdd ("Maximum loop count for ForwardAdd", Range(8, 1024)) = 64

        [IntRange]
        _MaxLoopShadowCaster ("Maximum loop count for ShadowCaster", Range(8, 1024)) = 32

        _MinRayLength ("Minimum length of the ray", Float) = 0.001
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 0.65

        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Custom)]
        _LightingMethod ("Lighting method", Int) = 2

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0


        _Color ("Color of the sphere", Color) = (0.5, 0.5, 0.5, 1.0)

        [Vector3]
        _Size ("Size of the Box", Vector) = (0.5, 0.5, 0.5, 0.0)

        _Round ("Round of the Box", Float) = 0.1


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
        #pragma multi_compile_fog
        #pragma shader_feature_local_fragment _LIGHTINGMETHOD_UNITY_LAMBERT _LIGHTINGMETHOD_UNITY_BLINN_PHONG _LIGHTINGMETHOD_UNITY_STANDARD _LIGHTINGMETHOD_UNITY_STANDARD_SPECULAR _LIGHTINGMETHOD_CUSTOM

        #include "PrimitiveTemplate.cginc"

        //! Size of the box.
        uniform float3 _Size;
        //! Round of the box.
        uniform float _Round;


        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p)
        {
            return sdRoundBox(p, _Size, _Round);
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
            #pragma fragment fragRayMarchingForward

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

            Blend [_SrcBlend] One, [_SrcBlendAlpha] One
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vertRayMarchingForward
            #pragma fragment fragRayMarchingForward

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
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vertRayMarchingShadowCaster
            #pragma fragment fragRayMarchingShadowCaster

            #pragma multi_compile_shadowcaster
            ENDCG
        }  // ShadowCaster
    }

    CustomEditor "Koturn.KRayMarching.Primitive.BoxGUI"
}
