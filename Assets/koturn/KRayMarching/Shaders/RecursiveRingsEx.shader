Shader "koturn/KRayMarching/RecursiveRingsEx"
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
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0

        [KeywordEnum(Object, World)]
        _CalcSpace ("Calculation space", Int) = 0

        [KeywordEnum(None, Simple, Max Length)]
        _AssumeInside ("Assume render target is inside object", Int) = 0

        _MaxInsideLength ("Maximum length inside an object", Float) = 1.7321

        [Toggle(_USE_FAST_INVTRIFUNC_ON)]
        _UseFastInvTriFunc ("Use Fast Inverse Trigonometric Functions", Int) = 1


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
        #pragma shader_feature_local _ _ASSUMEINSIDE_SIMPLE _ASSUMEINSIDE_MAX_LENGTH
        #pragma shader_feature_local_fragment _ _SVDEPTH_OFF
        #pragma shader_feature_local_fragment _ _USE_FAST_INVTRIFUNC_ON

        #include "include/alt/AltUnityCG.cginc"
        #include "include/alt/AltUnityStandardUtils.cginc"
        #include "AutoLight.cginc"

        #include "include/Math.cginc"
        #include "include/Utils.cginc"
        #include "include/LightingUtils.cginc"
        #include "include/SDF.cginc"
        #include "include/VertCommon.cginc"

        #ifdef _USE_FAST_INVTRIFUNC_ON
        #    define atan2(x, y)  atan2Fast(x, y)
        #endif  // _USE_FAST_INVTRIFUNC_ON


        /*!
         * @brief Output of fragment shader.
         */
        struct fout
        {
            //! Output color of the pixel.
            half4 color : SV_Target;
        #if (!defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)) && !defined(_SVDEPTH_OFF)
            //! Depth of the pixel.
            float depth : SV_Depth;
        #endif  // !defined(_SVDEPTH_OFF)
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
            half3 color;
        };


        rmout rayMarch(rayparam rp);
        float map(float3 p, out float hueOffset);
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
        //! Maximum length inside an object.
        uniform float _MaxInsideLength;

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
         * @brief Fragment shader function.
         * @param [in] fi  Input data from vertex shader
         * @return Output of each texels (fout).
         */
        fout frag(v2f_raymarching fi)
        {
            UNITY_SETUP_INSTANCE_ID(fi);
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

            const rayparam rp = calcRayParam(fi, _MaxRayLength, _MaxInsideLength);
            const rmout ro = rayMarch(rp);
            if (!ro.isHit) {
                discard;
            }

        #ifdef _CALCSPACE_WORLD
            const float3 worldFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
            const float3 worldNormal = getNormal(worldFinalPos);
        #else
            const float3 localFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
            const float3 worldFinalPos = objectToWorldPos(localFinalPos);
            const float3 worldNormal = UnityObjectToWorldNormal(getNormal(localFinalPos));
        #endif  // defined(_CALCSPACE_WORLD)

            const half4 color = calcLightingUnity(
                half4(ro.color, 1.0),
                worldFinalPos,
                worldNormal,
                getLightAttenRayMarching(fi, worldFinalPos),
                getLightMap(fi));

            const float4 clipPos = UnityWorldToClipPos(worldFinalPos);

            fout fo;
            fo.color = applyFog(clipPos.z, color);
        #ifndef _SVDEPTH_OFF
            fo.depth = getDepth(clipPos);
        #endif  // !defined(_SVDEPTH_OFF)

            return fo;
        }


        /*!
         * @brief Execute ray marching.
         *
         * @param [in] rp  Ray parameters.
         * @return Result of the ray marching.
         */
        rmout rayMarch(rayparam rp)
        {
        #if defined(UNITY_PASS_FORWARDBASE)
            const int maxLoop = _MaxLoop;
        #elif defined(UNITY_PASS_FORWARDADD)
            const int maxLoop = _MaxLoopForwardAdd;
        #elif defined(UNITY_PASS_SHADOWCASTER)
            const int maxLoop = _MaxLoopShadowCaster;
        #endif  // defined(UNITY_PASS_FORWARDBASE)

            const float3 rcpScales = rcp(_Scales);
            const float3 rayDirVec = rp.rayDir * rcpScales;
            const float marchingFactor = _MarchingFactor * rsqrt(dot(rayDirVec, rayDirVec));

            rmout ro;
            ro.rayLength = rp.initRayLength;
            ro.isHit = false;

            float hueOffset;

            // Loop of Ray Marching.
            for (int i = 0; i < maxLoop; i = (ro.isHit || ro.rayLength > rp.maxRayLength) ? 0x7fffffff : i + 1) {
                const float d = map((rp.rayOrigin + rp.rayDir * ro.rayLength) * rcpScales, /* out */ hueOffset);
                ro.rayLength += d * marchingFactor;
                ro.isHit = d < _MinRayLength;
            }

            ro.color = hueOffset == 1000.0 ? float3(0.8, 0.8, 0.8) : rgbAddHue(_TorusBaseColor, hueOffset);

            return ro;
        }

        static const float _TorusBaseRadiusDecay = 0.5;
        static const int _TorusNumberBase = 2;

        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @param [in] p  Position of the tip of the ray.
         * @return Signed Distance to the objects.
         */
        float map(float3 p, out float hueOffset)
        {
            float2 rt = float2(_TorusRadius, _TorusThickness);
            float2 rtDecay = float2(_TorusRadiusDecay, _TorusThicknessDecay);

            // hueOffset = 1000.0;
            float minDist = 1000.0;
            float d = 1000.0;
            float s = -1.0;
            for (int i = 0; i < _TorusNumberBase; i++) {
                d = sdTorus(p.xzy, rt.x, rt.y);
                UNITY_FLATTEN
                if (d < minDist) {
                    minDist = d;
                    hueOffset = 1000.0;
                }

                float2 rt2 = rt;
                float3 p2 = p;
                float rotAngle = _Time.y * _TorusAnimSpeed;
                s *= -1.0;
                for (int j = 0; j < _TorusRecursion; j++) {
                    p2.xy = rotate2D(p2.xy, s * rotAngle);

                    float angle = atan2(p2.y, p2.x);
                    float pIndex;
                    p2 = float3(pmod(p2.xy, angle, _TorusNumber) - float2(rt2.x, 0.0), p2.z);

                    rt2 *= rtDecay;

                    d = sdTorus(p2, rt2.x, rt2.y);
                    UNITY_FLATTEN
                    if (d < minDist) {
                        minDist = d;
                        hueOffset = angle / UNITY_TWO_PI + (i + j) * 0.5;
                    }

                    p2.xyz = p2.zxy;
                    rotAngle *= _TorusAnimDecay;
                }

                rt.x *= _TorusBaseRadiusDecay;
            }

            return minDist;
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
            static const float3 ks[] = {k.xyy, k.yxy, k.yyx, k.xxx};
            static const float h = 0.0001;

            const float3 rcpScales = rcp(_Scales);

            float3 normal = float3(0.0, 0.0, 0.0);
            float _;

            for (int i = 0; i < 4; i++) {
                normal += ks[i] * map((p + ks[i] * h) * rcpScales, /* out */ _);
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
            #pragma vertex vertRayMarching
            #pragma fragment frag

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
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
            #pragma fragment fragForwardAdd

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma shader_feature_local _ _FORWARDADD_OFF
            #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_UNLIT


            #if defined(_FORWARDADD_OFF) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH) || defined(_LIGHTING_UNLIT)
            /*!
             * @brief Fragment shader function.
             * @param [in] fi  Input data from vertex shader
             * @return Output of each texels (fout).
             */
            half4 fragForwardAdd() : SV_Target
            {
                return half4(0.0, 0.0, 0.0, 0.0);
            }
            #else
            /*!
             * @brief Fragment shader function.
             * @param [in] fi  Input data from vertex shader
             * @return Output of each texels (fout).
             */
            fout fragForwardAdd(v2f_raymarching fi)
            {
                return frag(fi);
            }
            #endif  // defined(_FORWARDADD_OFF) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH) || defined(_LIGHTING_UNLIT)
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
            #pragma fragment fragShadowCaster

            #pragma multi_compile_shadowcaster


            /*!
             * @brief Fragment shader function for ShadowCaster Pass.
             * @param [in] fi  Input data from vertex shader.
             * @return Depth of fragment.
             */
            fout fragShadowCaster(v2f_raymarching_shadowcaster fi)
            {
                UNITY_SETUP_INSTANCE_ID(fi);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

                const rayparam rp = calcRayParam(fi, _MaxRayLength, _MaxInsideLength);
                const rmout ro = rayMarch(rp);
                if (!ro.isHit) {
                    discard;
                }

            #ifdef _CALCSPACE_WORLD
                const float3 worldFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
            #else
                const float3 localFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
                const float3 worldFinalPos = objectToWorldPos(localFinalPos);
            #endif  // defined(_CALCSPACE_WORLD)

            #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
                //
                // TRANSFER_SHADOW_CASTER_NORMALOFFSET
                //
                const float3 vec = worldFinalPos - _LightPositionRange.xyz;
                //
                // SHADOW_CASTER_FRAGMENT
                //
                fout fo;
                fo.color = UnityEncodeCubeShadowDepth((length(vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
                return fo;
            #else
                //
                // SHADOW_CASTER_FRAGMENT
                //
                fout fo;
                fo.color = float4(0.0, 0.0, 0.0, 0.0);
            #    ifndef _SVDEPTH_OFF
                //
                // TRANSFER_SHADOW_CASTER_NORMALOFFSET
                //
            #        ifdef _CALCSPACE_WORLD
                const float3 worldNormal = getNormal(worldFinalPos);
            #        else
                const float3 worldNormal = UnityObjectToWorldNormal(getNormal(localFinalPos));
            #        endif  // defined(_CALCSPACE_WORLD)
                const float4 clipPos = UnityApplyLinearShadowBias(UnityWorldToClipPos(applyShadowBias(worldFinalPos, worldNormal)));
                fo.depth = getDepth(clipPos);
            #    endif  // !defined(_SVDEPTH_OFF)
                return fo;
            #endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
            }
            ENDCG
        }  // ShadowCaster
    }

    CustomEditor "Koturn.KRayMarching.Inspectors.RecursiveRingsGUI"
}

