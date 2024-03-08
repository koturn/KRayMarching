#ifndef RAYMARCHING_CORE_INCLUDED
#define RAYMARCHING_CORE_INCLUDED

#include "include/alt/AltUnityCG.cginc"
#include "include/alt/AltUnityStandardUtils.cginc"
#include "AutoLight.cginc"

#include "include/Math.cginc"
#include "include/Utils.cginc"
#include "include/LightingUtils.cginc"
#include "include/SDF.cginc"
#include "include/VertCommon.cginc"


#if !defined(RAYMARCHING_SDF)
#    define RAYMARCHING_SDF sdfDefaultRaymarching
#endif  // !defined(RAYMARCHING_SDF)
#if !defined(RAYMARCHING_GET_BASE_COLOR)
#    define RAYMARCHING_GET_BASE_COLOR getBaseColorDefaultRaymarching
#endif  // !defined(RAYMARCHING_GET_BASE_COLOR)
#if !defined(RAYMARCHING_CALC_NORMAL)
#    define RAYMARCHING_CALC_NORMAL calcNormalRayMarching
#endif  // !defined(RAYMARCHING_CALC_NORMAL)
#if !defined(RAYMARCHING_CALC_NORMAL_DELTA)
#    define RAYMARCHING_CALC_NORMAL_DELTA 0.001
#endif  // !defined(RAYMARCHING_CALC_NORMAL_DELTA)
#if !defined(RAYMARCHING_CALC_LIGHTING)
#    define RAYMARCHING_CALC_LIGHTING calcLightingUnity
#endif  // !defined(RAYMARCHING_CALC_LIGHTING)
#if !defined(RAYMARCHING_UNROLL_LIMIT)
#    define RAYMARCHING_UNROLL_LIMIT 128
#endif  // !defined(RAYMARCHING_UNROLL_LIMIT)
#if defined(RAYMARCHING_PREFER_UNROLL) && defined(UNITY_COMPILER_HLSL)
#    if !defined(RAYMARCHING_UNROLL)
#        define RAYMARCHING_UNROLL [unroll]
#    endif  // !defined(RAYMARCHING_UNROLL)
#    if !defined(RAYMARCHING_UNROLL_N)
#        define RAYMARCHING_UNROLL_N(n) [unroll(n)]
#    endif  // !defined(RAYMARCHING_UNROLL_N)
#else
#    if !defined(RAYMARCHING_UNROLL)
#        define RAYMARCHING_UNROLL
#    endif  // !defined(RAYMARCHING_UNROLL)
#    if !defined(RAYMARCHING_UNROLL_N)
#        define RAYMARCHING_UNROLL_N
#    endif  // !defined(RAYMARCHING_UNROLL_N)
#endif  // defined(RAYMARCHING_PREFER_UNROLL) && defined(UNITY_COMPILER_HLSL)


/*!
 * @brief Output of fragment shader.
 */
struct fout_raymarching
{
    //! Output color of the pixel.
    half4 color : SV_Target;
#if (!defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)) && !defined(_NODEPTH_ON)
    //! Depth of the pixel.
    float depth : SV_Depth;
#endif  // !defined(_NODEPTH_ON)
};

/*!
 * @brief Output of rayMarchDefault().
 */
struct result_raymarching
{
    //! Length of the ray.
    float rayLength;
    //! Number of ray steps.
    int rayStep;
    //! A flag whether the ray collided with an object or not.
    bool isHit;
};


fout_raymarching fragRayMarchingForward(v2f_raymarching_forward fi);
fout_raymarching fragRayMarchingShadowCaster(v2f_raymarching_shadowcaster fi);
result_raymarching rayMarchDefault(rayparam rp);
float3 calcNormalRayMarching(float3 p);
float3 calcNormalCentralDiffRayMarching(float3 p);
float3 calcNormalForwardDiffRayMarching(float3 p);
float3 sdfDefaultRaymarching(float3 p);
half4 getBaseColorDefaultRaymarching(float3 rayOrigin, float3 rayDir, float rayLength);


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
//! Maximum length inside an object.
uniform float _MaxInsideLength;
//! Marching Factor.
uniform float _MarchingFactor;
//! Coefficient of Over Relaxation Sphere Tracing.
uniform float _OverRelaxFactor;
//! Coefficient of Accelarating Sphere Tracing.
uniform float _AccelarationFactor;
//! Coefficient of Automatic Step Size Relaxation.
uniform float _AutoRelaxFactor;
//! Divisor of number of ray steps for debug view.
uniform float _DebugStepDiv;
//! Divisor of ray length for debug view.
uniform float _DebugRayLengthDiv;


#if defined(UNITY_PASS_FORWARDADD) && (defined(_NOFORWARDADD_ON) || defined(_LIGHTING_UNLIT) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH))
/*!
 * @brief Fragment shader function.
 * @param [in] fi  Input data from vertex shader
 * @return Output of each texels (fout_raymarching).
 */
half4 fragRayMarchingForward() : SV_Target
{
    return half4(0.0, 0.0, 0.0, 0.0);
}
#else
/*!
 * @brief Fragment shader function.
 * @param [in] fi  Input data from vertex shader
 * @return Output of each texels (fout_raymarching).
 */
fout_raymarching fragRayMarchingForward(v2f_raymarching_forward fi)
{
    UNITY_SETUP_INSTANCE_ID(fi);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

    const rayparam rp = calcRayParam(fi, _MaxRayLength, _MaxInsideLength);
    const result_raymarching ro = rayMarchDefault(rp);
#    if !defined(_DEBUGVIEW_STEP) && !defined(_DEBUGVIEW_RAY_LENGTH)
    if (!ro.isHit) {
        discard;
    }
#    endif  // !defined(_DEBUGVIEW_STEP) && !defined(_DEBUGVIEW_RAY_LENGTH)

#    if defined(_CALCSPACE_WORLD)
    const float3 worldFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
    const float3 worldNormal = RAYMARCHING_CALC_NORMAL(worldFinalPos);
#    else
    const float3 localFinalPos = rp.rayOrigin + rp.rayDir * ro.rayLength;
    const float3 worldFinalPos = objectToWorldPos(localFinalPos);
    const float3 localNormal = RAYMARCHING_CALC_NORMAL(localFinalPos);
    const float3 worldNormal = UnityObjectToWorldNormal(localNormal);
#    endif  // defined(_CALCSPACE_WORLD)

    const float4 clipPos = UnityWorldToClipPos(worldFinalPos);

    fout_raymarching fo;
#    if defined(_DEBUGVIEW_STEP)
    fo.color = float4((ro.rayStep / _DebugStepDiv).xxx, 1.0);
#    elif defined(_DEBUGVIEW_RAY_LENGTH)
    fo.color = float4((ro.rayLength / _DebugRayLengthDiv).xxx, 1.0);
#    else
    const half4 color = RAYMARCHING_CALC_LIGHTING(
        RAYMARCHING_GET_BASE_COLOR(rp.rayOrigin, rp.rayDir, ro.rayLength),
        worldFinalPos,
        worldNormal,
        getLightAttenRayMarching(fi, worldFinalPos),
        getLightMap(fi));
    fo.color = applyFog(clipPos.z, color);
#    endif
#    if !defined(_NODEPTH_ON)
    fo.depth = getDepth(clipPos);
#    endif  // !defined(_NODEPTH_ON)

    return fo;
}
#endif  // defined(UNITY_PASS_FORWARDADD) && (defined(_NOFORWARDADD_ON) || defined(_LIGHTING_UNLIT) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH))


/*!
 * @brief Fragment shader function for ShadowCaster Pass.
 * @param [in] fi  Input data from vertex shader.
 * @return Depth of fragment.
 */
fout_raymarching fragRayMarchingShadowCaster(v2f_raymarching_shadowcaster fi)
{
    UNITY_SETUP_INSTANCE_ID(fi);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(fi);

    const rayparam rp = calcRayParam(fi, _MaxRayLength, _MaxInsideLength);
    const result_raymarching ro = rayMarchDefault(rp);
    if (!ro.isHit) {
        discard;
    }

#if defined(_CALCSPACE_WORLD)
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
    fout_raymarching fo;
    fo.color = UnityEncodeCubeShadowDepth((length(vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
    return fo;
#else
    //
    // SHADOW_CASTER_FRAGMENT
    //
    fout_raymarching fo;
    fo.color = float4(0.0, 0.0, 0.0, 0.0);
#    if !defined(_NODEPTH_ON)
    //
    // TRANSFER_SHADOW_CASTER_NORMALOFFSET
    //
#        if defined(_CALCSPACE_WORLD)
    const float3 worldNormal = RAYMARCHING_CALC_NORMAL(worldFinalPos);
#        else
    const float3 localNormal = RAYMARCHING_CALC_NORMAL(localFinalPos);
    const float3 worldNormal = UnityObjectToWorldNormal(localNormal);
#        endif  // defined(_CALCSPACE_WORLD)
    const float4 clipPos = UnityApplyLinearShadowBias(UnityWorldToClipPos(applyShadowBias(worldFinalPos, worldNormal)));
    fo.depth = getDepth(clipPos);
#    endif  // !defined(_NODEPTH_ON)
    return fo;
#endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
}


/*!
 * @brief Execute ray marching.
 *
 * @param [in] rp  Ray parameters.
 * @return Result of the ray marching.
 */
result_raymarching rayMarchDefault(rayparam rp)
{
#if defined(UNITY_PASS_FORWARDBASE)
    const int maxLoop = _MaxLoop;
#elif defined(UNITY_PASS_FORWARDADD)
    const int maxLoop = _MaxLoopForwardAdd;
#elif defined(UNITY_PASS_SHADOWCASTER)
    const int maxLoop = _MaxLoopShadowCaster;
#endif  // defined(UNITY_PASS_FORWARDBASE)

    const float3 rcpScales = rcp(_Scales);
    const float3 rayOrigin = rp.rayOrigin * rcpScales;
    const float3 rayDirVec = rp.rayDir * rcpScales;

    result_raymarching ro;
    ro.rayLength = rp.initRayLength;
    ro.isHit = false;

#if defined(_STEPMETHOD_OVER_RELAX)
    const float marchingFactor = rsqrt(dot(rayDirVec, rayDirVec));
    float r = asfloat(0x7f800000);  // +inf
    float d = 0.0;

    // RAYMARCHING_UNROLL_N(RAYMARCHING_UNROLL_LIMIT)
    for (ro.rayStep = 0; abs(r) >= _MinRayLength && ro.rayLength < rp.maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
        const float nextRayLength = ro.rayLength + d * marchingFactor;
        const float nextR = RAYMARCHING_SDF(rayOrigin + rayDirVec * nextRayLength);
        if (d <= r + abs(nextR)) {
            d = _OverRelaxFactor * nextR;
            ro.rayLength = nextRayLength;
            r = nextR;
        } else {
            d = r;
        }
    }
    ro.isHit = abs(r) < _MinRayLength;
#elif defined(_STEPMETHOD_ACCELARATION)
    const float marchingFactor = rsqrt(dot(rayDirVec, rayDirVec));
    float r = RAYMARCHING_SDF(rayOrigin + rayDirVec * ro.rayLength);
    float d = r;

    // RAYMARCHING_UNROLL_N(RAYMARCHING_UNROLL_LIMIT)
    for (ro.rayStep = 1; r > _MinRayLength && (ro.rayLength + r) < rp.maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
        const float nextRayLength = ro.rayLength + d * marchingFactor;
        const float nextR = RAYMARCHING_SDF(rayOrigin + rayDirVec * nextRayLength);
        if (d <= r + abs(nextR)) {
            const float deltaR = nextR - r;
            d = nextR + _AccelarationFactor * nextR * ((d + deltaR) / (d - deltaR));
            ro.rayLength = nextRayLength;
            r = nextR;
        } else {
            d = r;
        }
    }
    ro.isHit = abs(r) < _MinRayLength;
#elif defined(_STEPMETHOD_AUTO_RELAX)
    const float marchingFactor = rsqrt(dot(rayDirVec, rayDirVec));
    float r = RAYMARCHING_SDF(rayOrigin + rayDirVec * ro.rayLength);
    float d = r;
    float m = -1.0;

    // RAYMARCHING_UNROLL_N(RAYMARCHING_UNROLL_LIMIT)
    for (ro.rayStep = 1; r > _MinRayLength && (ro.rayLength + r) < rp.maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
        const float nextRayLength = ro.rayLength + d * marchingFactor;
        const float nextR = RAYMARCHING_SDF(rayOrigin + rayDirVec * nextRayLength);
        if (d <= r + abs(nextR)) {
            m = lerp(m, (nextR - r) / d, _AutoRelaxFactor);
            ro.rayLength = nextRayLength;
            r = nextR;
        } else {
            m = -1.0;
        }
        d = 2.0 * r / (1.0 - m);
    }
    ro.isHit = r < _MinRayLength;
#else  // Assume: _STEPMETHOD_NORMAL
    const float marchingFactor = _MarchingFactor * rsqrt(dot(rayDirVec, rayDirVec));
    float d = asfloat(0x7f800000);  // +inf

    // RAYMARCHING_UNROLL_N(RAYMARCHING_UNROLL_LIMIT)
    for (ro.rayStep = 0; d >= _MinRayLength && ro.rayLength < rp.maxRayLength && ro.rayStep < maxLoop; ro.rayStep++) {
        d = RAYMARCHING_SDF(rayOrigin + rayDirVec * ro.rayLength);
        ro.rayLength += d * marchingFactor;
    }
    ro.isHit = d < _MinRayLength;
#endif

    return ro;
}


/*!
 * @brief Calculate normal of the objects at p using tetrahedron tequnique.
 * @param [in] p  Position.
 * @return Normal of the objects.
 * @see https://iquilezles.org/articles/normalsSDF/
 */
float3 calcNormalRayMarching(float3 p)
{
    static const float2 s = float2(1.0, -1.0);  // used only for generating k.
    static const float3 k[4] = {s.xyy, s.yxy, s.yyx, s.xxx};

    const float3 rcpScales = rcp(_Scales);

    float3 normal = float3(0.0, 0.0, 0.0);

    RAYMARCHING_UNROLL
    for (int i = 0; i < 4; i++) {
#if defined(RAYMARCHING_CALC_NORMAL_WITHOUT_LUT)
        const float3 c = float3(int3((i + 3) >> 1, i, i >> 1) & 1) * 2.0 - 1.0;
#else
        const float3 c = k[i];
#endif  // defined(RAYMARCHING_CALC_NORMAL_WITHOUT_LUT)
        normal += c * RAYMARCHING_SDF((p + c * (RAYMARCHING_CALC_NORMAL_DELTA)) * rcpScales);
    }

    return normalize(normal);
}


/*!
 * @brief Calculate normal of the objects at p using central difference.
 * @param [in] p  Position.
 * @return Normal of the objects.
 */
float3 calcNormalCentralDiffRayMarching(float3 p)
{
    static const float3 s = float3(1.0, -1.0, 0.0);  // used only for generating k.
    static const float3 k[6] = {s.xzz, s.yzz, s.zxz, s.zyz, s.zzx, s.zzy};

    const float3 rcpScales = rcp(_Scales);

    float3 normal = float3(0.0, 0.0, 0.0);

    RAYMARCHING_UNROLL
    for (int i = 0; i < 6; i++) {
#if defined(RAYMARCHING_CALC_NORMAL_WITHOUT_LUT)
        const int j = i >> 1;
        const float4 v = float4(int4((int3(j + 3, i, j) >> 1), i) & 1);
        const float3 c = v.xyz * (v.w * 2.0 - 1.0);
#else
        const float3 c = k[i];
#endif  // defined(RAYMARCHING_CALC_NORMAL_WITHOUT_LUT)
        normal += c * RAYMARCHING_SDF((p + c * (RAYMARCHING_CALC_NORMAL_DELTA)) * rcpScales);
    }

    return normalize(normal);
}


/*!
 * @brief Calculate normal of the objects at p using forward difference.
 * @param [in] p  Position.
 * @return Normal of the objects.
 */
float3 calcNormalForwardDiffRayMarching(float3 p)
{
    static const float3 s = float3(1.0, -1.0, 0.0);  // used only for generating k.
    static const float3 k[3] = {s.xzz, s.zxz, s.zzx};

    const float3 rcpScales = rcp(_Scales);

    float3 normal = (-RAYMARCHING_SDF(p * rcpScales)).xxx;

    RAYMARCHING_UNROLL
    for (int i = 0; i < 3; i++) {
#if defined(RAYMARCHING_CALC_NORMAL_WITHOUT_LUT)
        const float3 c = float3(int3((i + 3) >> 1, i, i >> 1) & 1);
#else
        const float3 c = k[i];
#endif  // defined(RAYMARCHING_CALC_NORMAL_WITHOUT_LUT)
        normal += c * RAYMARCHING_SDF((p + c * (RAYMARCHING_CALC_NORMAL_DELTA)) * rcpScales);
    }

    return normalize(normal);
}


/*!
 * @brief Default SDF of the ray marching.
 * @param [in] p  Position.
 * @return Signed Distance to the objects.
 */
float3 sdfDefaultRaymarching(float3 p)
{
    return sdSphere(p, 0.5);
}


/*!
 * @brief Get color of the object.
 * @param [in] rp  Ray parameters.
 * @param [in] ro  Result of the ray marching.
 * @return Base color of the object.
 */
half4 getBaseColorDefaultRaymarching(float3 rayOrigin, float3 rayDir, float rayLength)
{
    return half4(1.0, 1.0, 1.0, 1.0);
}


#endif  // RAYMARCHING_CORE_INCLUDED
