#ifndef PRIMITIVE_TEMPLATE_INCLUDED
#define PRIMITIVE_TEMPLATE_INCLUDED


#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"
#include "AutoLight.cginc"

#include "../include/Math.cginc"
#include "../include/Utils.cginc"
#include "../include/LightingUtils.cginc"
#include "../include/SDF.cginc"
#include "../include/VertCommon.cginc"


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


fout fragRayMarchingForward(v2f_raymarching_forward fi);
fout fragRayMarchingShadowCaster(v2f_raymarching_shadowcaster fi);
rmout rayMarch(float3 rayOrigin, float3 rayDir);
float map(float3 p);
half4 calcLighting(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
float3 getNormal(float3 p);
fixed getLightAttenuation(v2f_raymarching_forward fi, float3 worldPos);


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

//! Color of the object.
uniform float4 _Color;


/*!
 * @brief Fragment shader function.
 * @param [in] fi  Input data from vertex shader
 * @return Output of each texels (fout).
 */
fout fragRayMarchingForward(v2f_raymarching_forward fi)
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
    fo.color = applyFog(projPos.z, color);
    fo.depth = getDepth(projPos);

    return fo;
}


/*!
 * @brief Fragment shader function for ShadowCaster Pass.
 * @param [in] fi  Input data from vertex shader.
 * @return Output of each texels (fout).
 */
fout fragRayMarchingShadowCaster(v2f_raymarching_shadowcaster fi)
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

    // Loop of Ray Marching.
    for (int i = 0; i < maxLoop; i = (ro.isHit || ro.rayLength > _MaxRayLength) ? 0x7fffffff : i + 1) {
        const float d = map(rayOrigin + rayDir * ro.rayLength);
        ro.rayLength += d * _MarchingFactor;
        ro.isHit = d < _MinRayLength;
    }

    return ro;
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
    return calcLightingCustom(color, worldPos, worldNormal, atten, lmap);
#endif  // defined(_LIGHTINGMETHOD_LAMBERT)
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
    half3 _ = half3(0.0, 0.0, 0.0);

    for (int i = 0; i < 4; i++) {
        normal += ks[i] * map(p + ks[i] * h);
    }

    return normalize(normal);
}


/*!
 * @brief Get light attenuation.
 *
 * @param [in] fi  Input data of fragment shader function.
 * @param [in] worldPos  Coordinate of the world.
 * @return light attenuation.
 */
fixed getLightAttenuation(v2f_raymarching_forward fi, float3 worldPos)
{
    UNITY_LIGHT_ATTENUATION(atten, fi, worldPos);
    return atten;
}


#endif  // PRIMITIVE_TEMPLATE_INCLUDED
