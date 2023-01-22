#ifndef LIGHTINGUTILS_INCLUDED
#define LIGHTINGUTILS_INCLUDED


#ifndef LIGHTINGUTILS_OMIT_OLD_LIGHTING
#include "Lighting.cginc"
half4 calcLightingUnityLambert(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
half4 calcLightingUnityBlinnPhong(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
#endif  // LIGHTINGUTILS_OMIT_OLD_LIGHTING

#ifndef LIGHTINGUTILS_OMIT_PBS_LIGHTING
#include "UnityPBSLighting.cginc"
half4 calcLightingUnityStandard(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
half4 calcLightingUnityStandardSpecular(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap);
#endif  // LIGHTINGUTILS_OMIT_PBS_LIGHTING

half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, /* unused */ float4 lmap);

#include "UnityLightingCommon.cginc"

UnityGI getGI(float3 worldPos, half atten);
UnityGIInput getGIInput(UnityLight light, float3 worldPos, float3 worldNormal, float3 worldViewDir, half atten, float4 lmap);


#ifndef UNITY_LIGHTING_COMMON_INCLUDED
//! Color of light.
uniform fixed4 _LightColor0;
#endif  // UNITY_LIGHTING_COMMON_INCLUDED

#if !defined(UNITY_LIGHTING_COMMON_INCLUDED) && !defined(UNITY_STANDARD_SHADOW_INCLUDED)
//! Specular color.
uniform half4 _SpecColor;
#endif  // !defined(UNITY_LIGHTING_COMMON_INCLUDED) && !defined(UNITY_STANDARD_SHADOW_INCLUDED)

//! Specular power.
uniform float _SpecPower;
//! Value of smoothness.
uniform half _Glossiness;
//! Value of Metallic.
uniform half _Metallic;



#ifndef LIGHTINGUTILS_OMIT_OLD_LIGHTING
/*!
 * Calculate lighting with Lambert Reflection Model, same as Surface Shader with Lambert.
 * @param [in] color  Base color.
 * @param [in] worldPos  World coordinate.
 * @param [in] worldNormal  Normal in world space.
 * @param [in] atten  Light attenuation.
 * @param [in] lmap  Light map parameters.
 * @return Color with lighting applied.
 */
half4 calcLightingUnityLambert(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap)
{
    SurfaceOutput so;
    UNITY_INITIALIZE_OUTPUT(SurfaceOutput, so);
    so.Albedo = color.rgb;
    so.Normal = worldNormal;
    so.Emission = half3(0.0, 0.0, 0.0);
    // so.Specular = 0.0;  // Unused
    // so.Gloss = 0.0;  // Unused
    so.Alpha = color.a;

    UnityGI gi = getGI(worldPos, atten);

#ifdef UNITY_PASS_FORWARDBASE
    const float3 worldViewDir = normalizedWorldSpaceViewDir(worldPos);
#    if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    lmap = float4(0.0, 0.0, 0.0, 0.0);
#    endif  // !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    UnityGIInput giInput = getGIInput(gi.light, worldPos, worldNormal, worldViewDir, atten, lmap);
    LightingLambert_GI(so, giInput, gi);
#endif  // UNITY_PASS_FORWARDBASE

    half4 outColor = LightingLambert(so, gi);
    outColor.rgb += so.Emission;

    return outColor;
}


/*!
 * Calculate lighting with Blinn-Phong Reflection Model, same as Surface Shader with Lambert.
 * @param [in] color  Base color.
 * @param [in] worldPos  World coordinate.
 * @param [in] worldNormal  Normal in world space.
 * @param [in] atten  Light attenuation.
 * @param [in] lmap  Light map parameters.
 * @return Color with lighting applied.
 */
half4 calcLightingUnityBlinnPhong(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap)
{
    SurfaceOutput so;
    UNITY_INITIALIZE_OUTPUT(SurfaceOutput, so);
    so.Albedo = color.rgb;
    so.Normal = worldNormal;
    so.Emission = half3(0.0, 0.0, 0.0);
    so.Specular = _SpecPower / 128.0;
    so.Gloss = _Glossiness;
    so.Alpha = color.a;

    UnityGI gi = getGI(worldPos, atten);

    const float3 worldViewDir = normalizedWorldSpaceViewDir(worldPos);
#ifdef UNITY_PASS_FORWARDBASE
#    if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    lmap = float4(0.0, 0.0, 0.0, 0.0);
#    endif  // !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    UnityGIInput giInput = getGIInput(gi.light, worldPos, worldNormal, worldViewDir, atten, lmap);
    LightingBlinnPhong_GI(so, giInput, gi);
#endif  // UNITY_PASS_FORWARDBASE

    half4 outColor = LightingBlinnPhong(so, worldViewDir, gi);
    outColor.rgb += so.Emission;

    return outColor;
}
#endif  // LIGHTINGUTILS_OMIT_OLD_LIGHTING


#ifndef LIGHTINGUTILS_OMIT_PBS_LIGHTING
/*!
 * Calculate lighting with Unity PBS, same as Surface Shader with UnityStandard.
 * @param [in] color  Base color.
 * @param [in] worldPos  World coordinate.
 * @param [in] worldNormal  Normal in world space.
 * @param [in] atten  Light attenuation.
 * @param [in] lmap  Light map parameters.
 * @return Color with lighting applied.
 */
half4 calcLightingUnityStandard(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap)
{
    SurfaceOutputStandard so;
    UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandard, so);
    so.Albedo = color.rgb;
    so.Normal = worldNormal;
    so.Emission = half3(0.0, 0.0, 0.0);
    so.Metallic = _Metallic;
    so.Smoothness = _Glossiness;
    so.Occlusion = 1.0;
    so.Alpha = color.a;

    UnityGI gi = getGI(worldPos, atten);

    const float3 worldViewDir = normalizedWorldSpaceViewDir(worldPos);
#ifdef UNITY_PASS_FORWARDBASE
#    if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    lmap = float4(0.0, 0.0, 0.0, 0.0);
#    endif  // !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    UnityGIInput giInput = getGIInput(gi.light, worldPos, worldNormal, worldViewDir, atten, lmap);
    LightingStandard_GI(so, giInput, gi);
#endif  // UNITY_PASS_FORWARDBASE

    half4 outColor = LightingStandard(so, worldViewDir, gi);
    outColor.rgb += so.Emission;

    return outColor;
}


/*!
 * Calculate lighting with Unity PBS Specular, same as Surface Shader with UnityStandardSpecular.
 * @param [in] color  Base color.
 * @param [in] worldPos  World coordinate.
 * @param [in] worldNormal  Normal in world space.
 * @param [in] atten  Light attenuation.
 * @param [in] lmap  Light map parameters.
 * @return Color with lighting applied.
 */
half4 calcLightingUnityStandardSpecular(half4 color, float3 worldPos, float3 worldNormal, half atten, float4 lmap)
{
    SurfaceOutputStandardSpecular so;
    UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandardSpecular, so);
    so.Albedo = color.rgb;
    so.Specular = _SpecColor.rgb;
    so.Normal = worldNormal;
    so.Emission = half3(0.0, 0.0, 0.0);
    so.Smoothness = _Glossiness;
    so.Occlusion = 1.0;
    so.Alpha = color.a;

    UnityGI gi = getGI(worldPos, atten);

    const float3 worldViewDir = normalizedWorldSpaceViewDir(worldPos);
#ifdef UNITY_PASS_FORWARDBASE
#    if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    lmap = float4(0.0, 0.0, 0.0, 0.0);
#    endif  // !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
    UnityGIInput giInput = getGIInput(gi.light, worldPos, worldNormal, worldViewDir, atten, lmap);
    LightingStandardSpecular_GI(so, giInput, gi);
#endif  // UNITY_PASS_FORWARDBASE

    half4 outColor = LightingStandardSpecular(so, worldViewDir, gi);
    outColor.rgb += so.Emission;

    return outColor;
}
#endif  // LIGHTINGUTILS_OMIT_PBS_LIGHTING


/*!
 * Calculate lighting.
 * @param [in] fi  Input data from vertex shader.
 * @param [in] color  Base color.
 * @param [in] worldPos  World coordinate.
 * @param [in] worldNormal  Normal in world space.
 * @return Color with lighting applied.
 */
half4 calcLightingCustom(half4 color, float3 worldPos, float3 worldNormal, half atten, /* unused */ float4 lmap)
{
    const float3 worldViewDir = normalize(_WorldSpaceCameraPos - worldPos);
    const float3 worldLightDir = normalizedWorldSpaceLightDir(worldPos);
    const fixed3 lightCol = _LightColor0.rgb * atten;

    // Lambertian reflectance.
    const float nDotL = dot(worldNormal, worldLightDir);
    const half3 diffuse = lightCol * sq(nDotL * 0.5 + 0.5);

    // Specular reflection.
    // const half3 specular = pow(max(0.0, dot(normalize(worldLightDir + worldViewDir), worldNormal)), _SpecPower) * _SpecColor.rgb * lightCol;
    const half3 specular = pow(max(0.0, dot(reflect(-worldLightDir, worldNormal), worldViewDir)), _SpecPower) * _SpecColor.rgb * lightCol;

    // Ambient color.
#    if UNITY_SHOULD_SAMPLE_SH
    const half3 ambient = ShadeSHPerPixel(
        worldNormal,
        half3(0.0, 0.0, 0.0),
        worldPos);
#    else
    const half3 ambient = half3(0.0, 0.0, 0.0);
#    endif  // !UNITY_SHOULD_SAMPLE_SH

#    if defined(_ENABLE_REFLECTION_PROBE) && defined(UNITY_PASS_FORWARDBASE)
    const half4 refColor = getRefProbeColor(
        reflect(-worldViewDir, worldNormal),
        worldPos);
    const half4 outColor = half4((diffuse + ambient) * lerp(color.rgb, refColor.rgb, _Glossiness) + specular, color.a);
#    else
    const half4 outColor = half4((diffuse + ambient) * color.rgb + specular, color.a);
#    endif  // defined(_ENABLE_REFLECTION_PROBE) && defined(UNITY_PASS_FORWARDBASE)

    return outColor;
}


/*!
 * @brief Get initial instance of UnityGI.
 * @param [in] worldPos  World coordinate.
 * @param [in] atten  Light attenuation.
 * @return Initial instance of UnityGI.
 */
UnityGI getGI(float3 worldPos, half atten)
{
    UnityGI gi;
    UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
#ifdef UNITY_PASS_FORWARDBASE
    gi.light.color = _LightColor0.rgb;
#else
    gi.light.color = _LightColor0.rgb * atten;
#endif  // UNITY_PASS_FORWARDBASE
    gi.light.dir = normalizedWorldSpaceLightDir(worldPos);
    gi.indirect.diffuse = half3(0.0, 0.0, 0.0);
    gi.indirect.specular = half3(0.0, 0.0, 0.0);

    return gi;
}


/*!
 * @brief Get initial instance of UnityGIInput.
 * @param [in] light  The lighting parameter which contains color and direction of the light.
 * @param [in] worldPos  World coordinate.
 * @param [in] worldNormal  Normal in world space.
 * @param [in] worldViewDir  View direction in world space.
 * @param [in] atten  Light attenuation.
 * @param [in] lmap  Light map parameters.
 * @return Initial instance of UnityGIInput.
 */
UnityGIInput getGIInput(UnityLight light, float3 worldPos, float3 worldNormal, float3 worldViewDir, half atten, float4 lmap)
{
    UnityGIInput giInput;
    UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
    giInput.light = light;
    giInput.worldPos = worldPos;
    giInput.worldViewDir = worldViewDir;
    giInput.atten = atten;

#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = lmap;
#else
    giInput.lightmapUV = float4(0.0, 0.0, 0.0, 0.0);
#endif  // defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)

#if UNITY_SHOULD_SAMPLE_SH
    giInput.ambient = ShadeSHPerPixel(worldNormal, 0.0, giInput.worldPos);
#else
    giInput.ambient.rgb = half3(0.0, 0.0, 0.0);
#endif  // UNITY_SHOULD_SAMPLE_SH

#if !defined(_LIGHTINGMETHOD_UNITY_LAMBERT) && !defined(_LIGHTINGMETHOD_UNITY_BLINN_PHONG)
    giInput.probeHDR[0] = unity_SpecCube0_HDR;
    giInput.probeHDR[1] = unity_SpecCube1_HDR;
#    if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin;
#    endif  // defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
#    ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
#    endif  // UNITY_SPECCUBE_BOX_PROJECTION
#endif  // !defined(_LIGHTINGMETHOD_UNITY_LAMBERT) && !defined(_LIGHTINGMETHOD_UNITY_BLINN_PHONG)

    return giInput;
}


#endif  // LIGHTINGUTILS_INCLUDED
