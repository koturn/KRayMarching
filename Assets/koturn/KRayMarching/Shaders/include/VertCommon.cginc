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
    //! instanceID for single pass instanced rendering.
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


/*!
 * @brief Input of the vertex shader, vertRayMarchingShadowCaster().
 */
struct appdata_raymarching_shadowcaster
{
    //! Local position of the vertex.
    float4 vertex : POSITION;
    //! instanceID for single pass instanced rendering.
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


/*!
 * @brief Output of the vertex shader, vertRayMarchingForward()
 * and input of fragment shader.
 */
struct v2f_raymarching_forward
{
    //! Clip space position of the vertex.
    float4 pos : SV_POSITION;
#if !defined(_NOFORWARDADD_ON) || !defined(UNITY_PASS_FORWARDADD)
    //! Ray origin in object/world space.
    nointerpolation float3 rayOrigin : TEXCOORD0;
    //! Unnormalized ray direction in object/world space.
    float3 rayDirVec : TEXCOORD1;
    //! Lighting and shadowing parameters.
    UNITY_LIGHTING_COORDS(2, 3)
#    if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
    //! Light map UV coordinates.
    float4 lmap : TEXCOORD4;
#    endif  // defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
    //! instanceID for single pass instanced rendering.
    UNITY_VERTEX_INPUT_INSTANCE_ID
    //! stereoTargetEyeIndex for single pass instanced rendering.
    UNITY_VERTEX_OUTPUT_STEREO
#endif  // !defined(_NOFORWARDADD_ON) || !defined(UNITY_PASS_FORWARDADD)
};


/*!
 * @brief Output of the vertex shader, vertRayMarchingShadowCaster()
 * and input of fragment shader.
 */
struct v2f_raymarching_shadowcaster
{
    //! Clip space position of the vertex.
    V2F_SHADOW_CASTER;
    //! Ray origin in object/world space.
    float3 rayOrigin : TEXCOORD1;
    //! Unnormalized ray direction in object/world space.
    float3 rayDirVec : TEXCOORD2;
    //! instanceID for single pass instanced rendering.
    UNITY_VERTEX_INPUT_INSTANCE_ID
    //! stereoTargetEyeIndex for single pass instanced rendering.
    UNITY_VERTEX_OUTPUT_STEREO
};




#if defined(_NOFORWARDADD_ON) && defined(UNITY_PASS_FORWARDADD)

#    if defined(UNITY_COMPILER_HLSL) \
        || defined(SHADER_API_GLCORE) \
        || defined(SHADER_API_GLES3) \
        || defined(SHADER_API_METAL) \
        || defined(SHADER_API_VULKAN) \
        || defined(SHADER_API_GLES) \
        || defined(SHADER_API_D3D11)
// Disable WARN_FLOAT_DIVISION_BY_ZERO.
#        pragma warning (disable : 4008)
#    endif

/*!
 * @brief Vertex shader function for disabling ForwardAdd Pass.
 * @return Output for fragment shader (v2f).
 */
v2f_raymarching_forward vertRayMarchingForward()
{
    v2f_raymarching_forward o;

    o.pos = (0.0 / 0.0).xxxx;  // NaN (-qNaN)

    // Following code does not generate WARN_FLOAT_DIVISION_BY_ZERO.
    // o.pos = asfloat(0x7fc00000).xxxx;  // qNaN
    // o.pos = asfloat(0xffc00000).xxxx;  // -qNaN
    // o.pos = asfloat(0x7fa00000).xxxx;  // sNaN
    // o.pos = asfloat(0xffa00000).xxxx;  // -sNaN

    return o;
}
#else
/*!
 * @brief Vertex shader function for ForwardBase and ForwardAdd Pass.
 * @param [in] v  Input data
 * @return Output for fragment shader (v2f).
 */
v2f_raymarching_forward vertRayMarchingForward(appdata_raymarching_forward v)
{
    v2f_raymarching_forward o;
    UNITY_INITIALIZE_OUTPUT(v2f_raymarching_forward, o);

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

#ifdef _CALCSPACE_WORLD
    o.rayOrigin = _WorldSpaceCameraPos * _Scales;
    o.rayDirVec = objectToWorldPos(v.vertex.xyz) - o.rayOrigin;
#else
    o.rayOrigin = worldToObjectPos(_WorldSpaceCameraPos) * _Scales;
    o.rayDirVec = v.vertex - o.rayOrigin;
#endif  // defined(_CALCSPACE_WORLD)

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
#endif  // defined(_NOFORWARDADD_ON) && defined(UNITY_PASS_FORWARDADD)

/*!
 * @brief Vertex shader function for ShadowCaster Pass.
 * @param [in] v  Input data
 * @return Output for fragment shader.
 */
v2f_raymarching_shadowcaster vertRayMarchingShadowCaster(appdata_raymarching_shadowcaster v)
{
    v2f_raymarching_shadowcaster o;
    UNITY_INITIALIZE_OUTPUT(v2f_raymarching_shadowcaster, o);

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    TRANSFER_SHADOW_CASTER(o)

    float4 projPos = ComputeNonStereoScreenPos(o.pos);
    COMPUTE_EYEDEPTH(projPos.z);

#ifdef _CALCSPACE_WORLD
    o.rayOrigin = objectToWorldPos(v.vertex.xyz);
#    if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    o.rayDirVec = getCameraDirVec(projPos);
#    else
    o.rayDirVec = isCameraOrthographic() ? getCameraForward()
        : abs(unity_LightShadowBias.x) < 1.0e-5 ? (o.rayOrigin - _WorldSpaceCameraPos)
        : getCameraDirVec(projPos);
#    endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
#else
    o.rayOrigin = v.vertex.xyz;
#    if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    o.rayDirVec = mul((float3x3)unity_WorldToObject, getCameraDirVec(projPos));
#    else
    o.rayDirVec = isCameraOrthographic() ? mul((float3x3)unity_WorldToObject, getCameraForward())
        : abs(unity_LightShadowBias.x) < 1.0e-5 ? (v.vertex.xyz - worldToObjectPos(_WorldSpaceCameraPos))
        : mul((float3x3)unity_WorldToObject, getCameraDirVec(projPos));
#    endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
#endif  // defined(_CALCSPACE_WORLD)

    return o;
}


#if !defined(_NOFORWARDADD_ON) || !defined(UNITY_PASS_FORWARDADD)
/*!
 * @brief Get light attenuation.
 *
 * @param [in] fi  Input data of fragment shader function.
 * @param [in] worldPos  Coordinate of the world.
 * @return light attenuation.
 */
fixed getLightAttenRayMarching(v2f_raymarching_forward fi, float3 worldPos)
{
    UNITY_LIGHT_ATTENUATION(atten, fi, worldPos);
    return atten;
}
#endif  // !defined(_NOFORWARDADD_ON) || !defined(UNITY_PASS_FORWARDADD)


#endif  // VERT_COMMON_INCLUDED
