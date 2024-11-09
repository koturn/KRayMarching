#ifndef REFPROBE_INCLUDED
#define REFPROBE_INCLUDED

#include "alt/AltUnityCG.cginc"
#include "alt/AltUnityStandardUtils.cginc"


half4 getRefProbeColor(float3 worldRefDir, float3 worldPos);
half4 getRefProbeColor0(float3 worldRefDir, float3 worldPos);
half4 getRefProbeColor1(float3 worldRefDir, float3 worldPos);
float3 boxProj0(float3 worldRefDir, float3 worldPos);
float3 boxProj1(float3 worldRefDir, float3 worldPos);


/*!
 * @brief Get blended color of the two reflection probes.
 *
 * @param [in] worldRefDir  Reflect direction (must be normalized).
 * @param [in] worldPos  World coordinate.
 * @return Color of reflection probe.
 */
half4 getRefProbeColor(float3 worldRefDir, float3 worldPos)
{
    return lerp(
        getRefProbeColor1(worldRefDir, worldPos),
        getRefProbeColor0(worldRefDir, worldPos),
        unity_SpecCube0_BoxMin.w);
}


/*!
 * @brief Get color of the first reflection probe.
 *
 * @param [in] worldRefDir  Reflect direction (must be normalized).
 * @param [in] worldPos  World coordinate.
 * @return Color of the first reflection probe.
 */
half4 getRefProbeColor0(float3 worldRefDir, float3 worldPos)
{
    half4 refColor = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, boxProj0(worldRefDir, worldPos), 0.0);
    refColor.rgb = DecodeHDR(refColor, unity_SpecCube0_HDR);
    return refColor;
}


/*!
 * @brief Get color of the second reflection probe.
 *
 * @param [in] worldRefDir  Reflect direction (must be normalized).
 * @param [in] worldPos  World coordinate.
 * @return Color of the second reflection probe.
 */
half4 getRefProbeColor1(float3 worldRefDir, float3 worldPos)
{
    half4 refColor = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, boxProj1(worldRefDir, worldPos), 0.0);
    refColor.rgb = DecodeHDR(refColor, unity_SpecCube1_HDR);
    return refColor;
}


/*!
 * @brief Get reflection direction of the first reflection probe
 * considering box projection.
 *
 * @param [in] worldRefDir  Refrection dir (must be normalized).
 * @param [in] worldPos  World coordinate.
 * @return Refrection direction considering box projection.
 */
float3 boxProj0(float3 worldRefDir, float3 worldPos)
{
    return BoxProjectedCubemapDirectionAlt(
        worldRefDir,
        worldPos,
        unity_SpecCube0_ProbePosition,
        unity_SpecCube0_BoxMin,
        unity_SpecCube0_BoxMax);
}


/*!
 * @brief Get reflection direction of the second reflection probe
 * considering box projection.
 *
 * @param [in] worldRefDir  Refrection dir (must be normalized).
 * @param [in] worldPos  World coordinate.
 * @return Refrection direction considering box projection.
 */
float3 boxProj1(float3 worldRefDir, float3 worldPos)
{
    return BoxProjectedCubemapDirectionAlt(
        worldRefDir,
        worldPos,
        unity_SpecCube1_ProbePosition,
        unity_SpecCube1_BoxMin,
        unity_SpecCube1_BoxMax);
}


#endif  // !defined(REFPROBE_INCLUDED)
