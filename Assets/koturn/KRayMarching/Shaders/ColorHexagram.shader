Shader "koturn/KRayMarching/ColorHexagram"
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

        [Toggle(_USE_FAST_INVTRIFUNC_ON)]
        _UseFastInvTriFunc ("Use Fast Inverse Trigonometric Functions", Int) = 1

        [KeywordEnum(None, Step, Ray Length)]
        _DebugView ("Debug view mode", Int) = 0

        [IntRange]
        _DebugStepDiv ("Divisor of number of ray steps for debug view", Range(1, 1024)) = 24

        _DebugRayLengthDiv ("Divisor of ray length for debug view", Range(0.01, 1000.0)) = 5.0


        // ---------------------------------------------------------------------
        [Header(SDF Parameters)]
        [Space(8)]
        _TorusRadius ("Radius of Torus", Float) = 0.25
        _TorusRadiusAmp ("Radius Amplitude of Torus", Float) = 0.05
        _TorusWidth ("Width of Torus", Float) = 0.005
        _OctahedronSize ("Size of Octahedron", Float) = 0.05
        _LineColorMultiplier ("Multiplier of lines", Float) = 5.0


        // ---------------------------------------------------------------------
        [Header(Lighting Parameters)]
        [Space(8)]
        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Unlit)]
        _Lighting ("Lighting method", Int) = 2

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 1.0


        // ---------------------------------------------------------------------
        [Header(Rendering Parameters)]
        [Space(8)]
        [Toggle(_NODEPTH_ON)]
        _NoDepth ("Disable depth ouput", Int) = 0

        [Toggle(_NOFORWARDADD_ON)]
        _NoForwardAdd ("Disable ForwardAdd", Int) = 0

        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

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
        #pragma shader_feature_local _CALCSPACE_OBJECT _CALCSPACE_WORLD
        #pragma shader_feature_local _MAXRAYLENGTHMODE_USE_PROPERTY_VALUE _MAXRAYLENGTHMODE_FAR_CLIP _MAXRAYLENGTHMODE_DEPTH_TEXTURE
        #pragma shader_feature_local _ASSUMEINSIDE_NONE _ASSUMEINSIDE_SIMPLE _ASSUMEINSIDE_MAX_LENGTH
        #pragma shader_feature_local_fragment _STEPMETHOD_NORMAL _STEPMETHOD_OVER_RELAX _STEPMETHOD_ACCELARATION _STEPMETHOD_AUTO_RELAX
        #pragma shader_feature_local_fragment _ _NODEPTH_ON
        #pragma shader_feature_local_fragment _ _USE_FAST_INVTRIFUNC_ON

        #define RAYMARCHING_SDF map
        #define RAYMARCHING_GET_BASE_COLOR getBaseColor

        float map(float3 p);
        float map(float3 p, out half4 color);
        half4 getBaseColor(float3 rayOrigin, float3 rayDir, float rayLength);

        #include "RayMarchingCore.cginc"

        #ifdef _USE_FAST_INVTRIFUNC_ON
        #    define atan2(x, y)  atan2Fast(x, y)
        #endif  // _USE_FAST_INVTRIFUNC_ON


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
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p)
        {
            half4 _;
            return map(p, /* out */ _);
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
         * @brief Get color of the object.
         * @param [in] rayOrigin  Object/World space ray origin.
         * @param [in] rayDir  Object/World space ray direction.
         * @param [in] rayLength  Object/World space Ray length.
         * @return Base color of the object.
         */
        half4 getBaseColor(float3 rayOrigin, float3 rayDir, float rayLength)
        {
            const float3 p = rayOrigin + rayDir * rayLength;
            half4 color;
            map(p, /* out */ color);
            _SpecColor *= color.a;
            return color;
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
            #pragma shader_feature_local_fragment _DEBUGVIEW_NONE _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
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
            #pragma shader_feature_local_fragment _DEBUGVIEW_NONE _DEBUGVIEW_STEP _DEBUGVIEW_RAY_LENGTH
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

    CustomEditor "Koturn.KRayMarching.Inspectors.ColorHexagramGUI"
}
