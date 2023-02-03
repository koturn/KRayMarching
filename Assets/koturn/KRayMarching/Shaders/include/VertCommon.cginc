#ifndef VERT_COMMON_INCLUDED
#define VERT_COMMON_INCLUDED

#include "Utils.cginc"


//! Scale vector.
uniform float3 _Scales;


/*!
 * @brief Input of the vertex shader, vertRayMarchingForward().
 */
struct appdata_raymarching_forward
{
    //! Local position of the vertex.
    float4 vertex : POSITION;
#ifdef LIGHTMAP_ON
    //! Lightmap coordinate.
    float2 texcoord1 : TEXCOORD1;
#endif  // LIGHTMAP_ON
#ifdef DYNAMICLIGHTMAP_ON
    //! Dynamic Lightmap coordinate.
    float2 texcoord2 : TEXCOORD2;
#endif  // DYNAMICLIGHTMAP_ON
};


/*!
 * @brief Input of the vertex shader, vertRayMarchingShadowCaster().
 */
struct appdata_raymarching_shadowcaster
{
    //! Local position of the vertex.
    float4 vertex : POSITION;
};


/*!
 * @brief Output of the vertex shader, vertRayMarchingForward()
 * and input of fragment shader.
 */
struct v2f_raymarching_forward
{
    //! Clip space position of the vertex.
    float4 pos : SV_POSITION;
    //! Ray origin in object space (Local space position of the camera).
    nointerpolation float3 localRayOrigin : TEXCOORD0;
    //! Unnormalized ray direction in object space.
    float3 localRayDirVector : TEXCOORD1;
    //! Lighting and shadowing parameters.
    UNITY_LIGHTING_COORDS(2, 3)
#if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
    //! Light map UV coordinates.
    float4 lmap : TEXCOORD4;
#endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
};


/*!
 * @brief Output of the vertex shader, vertRayMarchingShadowCaster()
 * and input of fragment shader.
 */
struct v2f_raymarching_shadowcaster
{
    //! Clip space position of the vertex.
    V2F_SHADOW_CASTER;
    //! Ray origin in object space.
    float3 localRayOrigin : TEXCOORD1;
    //! Unnormalized ray direction in object space.
    float3 localRayDirVector : TEXCOORD2;
};




/*!
 * @brief Vertex shader function for ForwardBase and ForwardAdd Pass.
 * @param [in] v  Input data
 * @return Output for fragment shader (v2f).
 */
v2f_raymarching_forward vertRayMarchingForward(appdata_raymarching_forward v)
{
    v2f_raymarching_forward o;
    UNITY_INITIALIZE_OUTPUT(v2f_raymarching_forward, o);

    o.localRayOrigin = worldToObjectPos(_WorldSpaceCameraPos) * _Scales;
    o.localRayDirVector = v.vertex - o.localRayOrigin;

#ifdef LIGHTMAP_ON
    o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif  // LIGHTMAP_ON
#ifdef DYNAMICLIGHTMAP_ON
    o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif  // DYNAMICLIGHTMAP_ON

    UNITY_TRANSFER_LIGHTING(o, v.texcoord1);

    v.vertex.xyz /= _Scales;
    o.pos = UnityObjectToClipPos(v.vertex);

    return o;
}


/*!
 * @brief Vertex shader function for ShadowCaster Pass.
 * @param [in] v  Input data
 * @return Output for fragment shader.
 */
v2f_raymarching_shadowcaster vertRayMarchingShadowCaster(appdata_raymarching_shadowcaster v)
{
    v2f_raymarching_shadowcaster o;
    UNITY_INITIALIZE_OUTPUT(v2f_raymarching_shadowcaster, o);

    TRANSFER_SHADOW_CASTER(o)

    o.localRayOrigin = v.vertex.xyz;

    float4 projPos = ComputeNonStereoScreenPos(o.pos);
    COMPUTE_EYEDEPTH(projPos.z);
#if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    o.localRayDirVector = mul((float3x3)unity_WorldToObject, getCameraDirectionVector(projPos));
#else
    o.localRayDirVector = isCameraOrthographic() ? mul((float3x3)unity_WorldToObject, getCameraForward())
        : abs(unity_LightShadowBias.x) < 1.0e-5 ? (v.vertex.xyz - worldToObjectPos(_WorldSpaceCameraPos))
        : mul((float3x3)unity_WorldToObject, getCameraDirectionVector(projPos));
#endif

    return o;
}


#endif  // VERT_COMMON_INCLUDED
