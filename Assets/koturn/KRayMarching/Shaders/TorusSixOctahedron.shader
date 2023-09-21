Shader "koturn/KRayMarching/TorusSixOctahedron"
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

        _MarchingFactor ("Marching Factor", Range(0.5, 1.0)) = 1.0

        [KeywordEnum(Unity Lambert, Unity Blinn Phong, Unity Standard, Unity Standard Specular, Custom)]
        _Lighting ("Lighting method", Int) = 0

        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1.0)
        _SpecPower ("Specular Power", Range(0.0, 128.0)) = 5.0

        // SDF parameters.
        _TorusRadius ("Radius of Torus", Float) = 0.25
        _TorusRadiusAmp ("Radius Amplitude of Torus", Float) = 0.05
        _TorusWidth ("Width of Torus", Float) = 0.005
        _OctahedronSize ("Size of Octahedron", Float) = 0.05

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
        float map(float3 p, out float colorIndex);
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

#if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
            const float4 lmap = fi.lmap;
#else
            const float4 lmap = float4(0.0, 0.0, 0.0, 0.0);
#endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)

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
#endif
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
            static const half3 kColors[6] = {
                half3(0.8, 0.4, 0.4),  // R
                half3(0.8, 0.8, 0.4),  // Y
                half3(0.4, 0.8, 0.4),  // G
                half3(0.4, 0.8, 0.8),  // C
                half3(0.4, 0.4, 0.8),  // B
                half3(0.8, 0.4, 0.8)   // M
            };

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

            float colorIndex;

            // Loop of Ray Marching.
            for (int i = 0; i < maxLoop; i = (ro.isHit || ro.rayLength > _MaxRayLength) ? 0x7fffffff : i + 1) {
                const float d = map(rayOrigin + rayDir * ro.rayLength, /* out */ colorIndex);
                ro.rayLength += d * _MarchingFactor;
                ro.isHit = d < _MinRayLength;
            }

            int idx = (int)colorIndex;
            ro.color = idx == 3 ? half3(0.8, 0.8, 0.8)
                : idx == 0 ? kColors[0]
                : idx == 1 ? kColors[1]
                : idx == 2 ? kColors[2]
                : idx == -3 ? kColors[3]
                : idx == -2 ? kColors[4]
                : kColors[5];

            return ro;
        }

        /*!
         * @brief SDF (Signed Distance Function) of objects.
         * @param [in] p  Position of the tip of the ray.
         * @param [out] colorIndex  Color index, [-3, 3].
         * @return Signed Distance to the objects.
         */
        float map(float3 p, out float colorIndex)
        {
            static const float kOneThirdPi = UNITY_PI / 3.0;
            static const float kInvOneThirdPi = 1.0 / kOneThirdPi;

#ifdef UNITY_PASS_SHADOWCASTER
            p *= _Scales;
#endif  // UNITY_PASS_SHADOWCASTER

            const float radius = _TorusRadius + _SinTime.w * _TorusRadiusAmp;

            float minDist = sdTorus(p.xzy, float2(radius, _TorusWidth));
            colorIndex = 3.0;

            p.xy = rotate2D(p.xy, _Time.y);
            const float rotUnit = floor(-atan2(p.y, p.x) * kInvOneThirdPi);
            p.xy = rotate2D(p.xy, kOneThirdPi * rotUnit + kOneThirdPi / 2.0);

            const float d = sdOctahedron(p - float3(radius, 0.0, 0.0), _OctahedronSize, float3(0.5, 2.0, 2.0));
            if (minDist > d) {
                minDist = d;
                colorIndex = rotUnit;
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

    CustomEditor "Koturn.KRayMarching.Inspectors.TorusOctahedronGUI"
}
