Shader "koturn/KRayMarching/RecursiveRings"
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
        _MaxLoopShadowCaster ("Maximum loop count for ShadowCaster", Range(8, 1024)) = 32

        _MinRayLength ("Minimum length of the ray", Float) = 0.001
        _MaxRayLength ("Maximum length of the ray", Float) = 1000.0

        [Vector3]
        _Scales ("Scale vector", Vector) = (1.0, 1.0, 1.0, 1.0)

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0

        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Custom)]
        _Lighting ("Lighting method", Int) = 2

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0

        // SDF parameters.
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


        [Toggle(_USE_FAST_INVTRIFUNC_ON)]
        _UseFastInvTriFunc ("Use Fast Inverse Trigonometric Functions", Int) = 1


        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Culling Mode", Int) = 1  // Default: Front

        [HideInInspector]
        _Mode ("Rendering Mode", Int) = 0

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
        #pragma shader_feature_local_fragment _ _USE_FAST_INVTRIFUNC_ON
        #pragma shader_feature_local_fragment _LIGHTING_UNITY_LAMBERT _LIGHTING_UNITY_BLINN_PHONG _LIGHTING_UNITY_STANDARD _LIGHTING_UNITY_STANDARD_SPECULAR _LIGHTING_CUSTOM

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
            half3 color;
        };


        rmout rayMarch(float3 rayOrigin, float3 rayDir);
        float map(float3 p, out float hueOffset);
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
        //! Marching Factor.
        uniform float _MarchingFactor;

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
        fout frag(v2f_raymarching_forward fi)
        {
#if defined(_NOFORWARDADD_ON) && defined(UNITY_PASS_FORWARDADD)
            fout fo;
            UNITY_INITIALIZE_OUTPUT(fout, fo);
            return fo;
#else
            UNITY_SETUP_INSTANCE_ID(fi);
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

            const float3 localRayDir = normalize(fi.localRayDirVector);

            const rmout ro = rayMarch(fi.localRayOrigin, localRayDir);
            if (!ro.isHit) {
                discard;
            }

            const float3 localFinalPos = fi.localRayOrigin + localRayDir * ro.rayLength;
            const float3 worldFinalPos = objectToWorldPos(localFinalPos);

#    if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
            const float4 lmap = fi.lmap;
#    else
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
#    endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)

            const half4 color = calcLighting(
                half4(ro.color, 1.0),
                worldFinalPos,
                UnityObjectToWorldNormal(getNormal(localFinalPos)),
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

            rmout ro;
            ro.rayLength = 0.0;
            ro.isHit = false;

            float hueOffset;

            // Loop of Ray Marching.
            for (int i = 0; i < maxLoop; i = (ro.isHit || ro.rayLength > _MaxRayLength) ? 0x7fffffff : i + 1) {
                const float d = map(rayOrigin + rayDir * ro.rayLength, /* out */ hueOffset);
                ro.rayLength += d * _MarchingFactor;
                ro.isHit = d < _MinRayLength;
            }

            ro.color = hueOffset == 1000.0 ? float3(0.8, 0.8, 0.8) : rgbAddHue(_TorusBaseColor, hueOffset);

            return ro;
        }

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
            float rotAngle = _Time.y * _TorusAnimSpeed;

            float minDist = sdTorus(p.xzy, rt.x, rt.y);
            hueOffset = 1000.0;

            for (int i = 0; i < _TorusRecursion; i++) {
                p.xy = rotate2D(p.xy, rotAngle);

                float angle = atan2Fast(p.y, p.x);
                float pIndex;
                p = float3(pmod(p.xy, angle, _TorusNumber) - float2(rt.x, 0.0), p.z);

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
            static const float3 ks[] = {k.xyy, k.yxy, k.yyx, k.xxx};
            static const float h = 0.0001;

            float3 normal = float3(0.0, 0.0, 0.0);
            float _;

            for (int i = 0; i < 4; i++) {
                normal += ks[i] * map(p + ks[i] * h, /* out */ _);
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

    CustomEditor "Koturn.KRayMarching.Inspectors.RecursiveRingsGUI"
}
