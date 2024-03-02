#ifndef VERT_COMMON_INCLUDED
#define VERT_COMMON_INCLUDED

#include "Utils.cginc"


UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);


#if defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)
typedef fixed face_t;
#    define FACE_SEMANTICS VFACE
#else
typedef bool face_t;
#    define FACE_SEMANTICS SV_IsFrontFace
#endif  // defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)

#if defined(SHADER_STAGE_FRAGMENT) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
#    define IS_FACING(fi)  isFacing(fi.facing)
#else
#    define IS_FACING(fi)  true
#endif


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
#if defined(_CALCSPACE_WORLD) || defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
    //! Fragment position in object/world space.
    float3 fragPos : TEXCOORD0;
#else
    //! Unnormalized ray direction in object space.
    float3 rayDirVec : TEXCOORD0;
#endif  // defined(_CALCSPACE_WORLD) || defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
#ifndef _CALCSPACE_WORLD
    //! Ray origin in object/world space.
    nointerpolation float3 rayOrigin : TEXCOORD1;
#endif  // !defined(_CALCSPACE_WORLD)
#ifdef _MAXRAYLENGTHMODE_DEPTH_TEXTURE
    float4 screenPos : TEXCOORD2;
#endif  // defined(_MAXRAYLENGTHMODE_DEPTH_TEXTURE)
    //! Lighting and shadowing parameters.
    UNITY_LIGHTING_COORDS(3, 4)
#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    //! Light map UV coordinates.
    float4 lmap : TEXCOORD5;
#endif  // defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    //! instanceID for single pass instanced rendering.
    UNITY_VERTEX_INPUT_INSTANCE_ID
    //! stereoTargetEyeIndex for single pass instanced rendering.
    UNITY_VERTEX_OUTPUT_STEREO
#if defined(SHADER_STAGE_FRAGMENT) \
    && !defined(_CULL_FRONT) \
    && !defined(_CULL_BACK) \
    && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
    //! Facing variable (fixed or bool).
    face_t facing : FACE_SEMANTICS;
#endif
};


/*!
 * @brief Output of the vertex shader, vertRayMarchingShadowCaster()
 * and input of fragment shader.
 */
struct v2f_raymarching_shadowcaster
{
    // V2F_SHADOW_CASTER;
    // `float3 vec : TEXCOORD0;` is unnecessary even if `!defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)`
    // because calculate `vec` in fragment shader.

    //! Clip space position of the vertex.
    float4 pos : SV_POSITION;
    //! Ray origin in object/world space.
    float3 rayOrigin : TEXCOORD0;
    //! Unnormalized ray direction in object/world space.
    float3 rayDirVec : TEXCOORD1;
    //! instanceID for single pass instanced rendering.
    UNITY_VERTEX_INPUT_INSTANCE_ID
    //! stereoTargetEyeIndex for single pass instanced rendering.
    UNITY_VERTEX_OUTPUT_STEREO
#if defined(SHADER_STAGE_FRAGMENT) \
    && !defined(_CULL_FRONT) \
    && !defined(_CULL_BACK)
    //! Facing variable (fixed or bool).
    face_t facing : FACE_SEMANTICS;
#endif  // defined(SHADER_STAGE_FRAGMENT)
};


/*!
 * @brief Ray parameters for Raymarching.
 */
struct rayparam
{
    //! Object/World space ray origin.
    float3 rayOrigin;
    //! Object/World space ray direction.
    float3 rayDir;
    //! Object/World space initial ray length.
    float initRayLength;
    //! Object/World space maximum ray length.
    float maxRayLength;
};


rayparam calcRayParam(v2f_raymarching_forward fi, float3 rayDir, float3 maxRayLength, float3 maxInsideLength);
rayparam calcRayParam(v2f_raymarching_shadowcaster fi, float3 maxRayLength, float3 maxInsideLength);
float4 getLightMap(v2f_raymarching_forward fi);
fixed getLightAttenRayMarching(v2f_raymarching_forward fi, float3 worldPos);
bool isFacing(v2f_raymarching_forward fi);
bool isFacing(v2f_raymarching_shadowcaster fi);
bool isFacing(face_t facing);


#if defined(UNITY_PASS_FORWARDADD) && defined(_NOFORWARDADD_ON) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH) || defined(_LIGHTING_UNLIT)
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
 * @return NaN vertex.
 */
float4 vertRayMarchingForward() : SV_POSITION
{
    return (0.0 / 0.0).xxxx;  // NaN (-qNaN)
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
    o.fragPos = objectToWorldPos(v.vertex.xyz);
#else
    const float3 vertPos = v.vertex.xyz;
    o.rayOrigin = worldToObjectPos(_WorldSpaceCameraPos);
#    if defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
    o.fragPos = vertPos;
#    else
    o.rayDirVec = vertPos - o.rayOrigin;
#    endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
#endif  // defined(_CALCSPACE_WORLD)

#ifdef LIGHTMAP_ON
    o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif  // LIGHTMAP_ON
#ifdef DYNAMICLIGHTMAP_ON
    o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif  // DYNAMICLIGHTMAP_ON

    UNITY_TRANSFER_LIGHTING(o, v.texcoord1);

    o.pos = UnityObjectToClipPos(v.vertex);

#ifdef _MAXRAYLENGTHMODE_DEPTH_TEXTURE
    o.screenPos = ComputeNonStereoScreenPos(o.pos);
    COMPUTE_EYEDEPTH(o.screenPos.z);
#endif  // defined(_MAXRAYLENGTHMODE_DEPTH_TEXTURE)

    return o;
}
#endif  // defined(UNITY_PASS_FORWARDADD) && defined(_NOFORWARDADD_ON) || defined(_DEBUGVIEW_STEP) || defined(_DEBUGVIEW_RAY_LENGTH) || defined(_LIGHTING_UNLIT)

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

    //
    // TRANSFER_SHADOW_CASTER(o)
    //
    o.pos = UnityObjectToClipPos(v.vertex);
#if !defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    o.pos = UnityApplyLinearShadowBias(o.pos);
#endif  // !defined(SHADOWS_CUBE) || defined(SHADOWS_CUBE_IN_DEPTH_TEX)

    float4 screenPos = ComputeNonStereoScreenPos(o.pos);
    COMPUTE_EYEDEPTH(screenPos.z);

#ifdef _CALCSPACE_WORLD
    o.rayOrigin = objectToWorldPos(v.vertex.xyz);
#    if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    o.rayDirVec = getCameraDirVec(screenPos);
#    else
    o.rayDirVec = isCameraOrthographic() ? getCameraForward()
        : abs(unity_LightShadowBias.x) < 1.0e-5 ? (o.rayOrigin - _WorldSpaceCameraPos)
        : getCameraDirVec(screenPos);
#    endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
#else
    o.rayOrigin = v.vertex.xyz;
#    if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    o.rayDirVec = mul((float3x3)unity_WorldToObject, getCameraDirVec(screenPos));
#    else
    o.rayDirVec = isCameraOrthographic() ? mul((float3x3)unity_WorldToObject, getCameraForward())
        : abs(unity_LightShadowBias.x) < 1.0e-5 ? (v.vertex.xyz - worldToObjectPos(_WorldSpaceCameraPos))
        : mul((float3x3)unity_WorldToObject, getCameraDirVec(screenPos));
#    endif  // defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
#endif  // defined(_CALCSPACE_WORLD)

    return o;
}


/*!
 * Calculate raymarching parameters for ForwardBase/ForwardAdd pass.
 * @param [in] fi  Input data of fragment shader function.
 * @param [in] maxRayLength  Maximum ray length.
 * @param [in] maxInsideLength  Maximum length inside an object.
 * @return Ray parameters.
 */
rayparam calcRayParam(v2f_raymarching_forward fi, float3 maxRayLength, float3 maxInsideLength)
{
    rayparam rp;

#ifdef _CALCSPACE_WORLD
    rp.rayOrigin = _WorldSpaceCameraPos;
    const float3 rayDirVec = fi.fragPos - _WorldSpaceCameraPos;
#else
    rp.rayOrigin = fi.rayOrigin;
#    if defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
    const float3 rayDirVec = fi.fragPos - fi.rayOrigin;
#    else
    const float3 rayDirVec = fi.rayDirVec;
#    endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
#endif  // defined(_CALCSPACE_WORLD)
    rp.rayDir = normalize(rayDirVec);

#if !defined(_MAXRAYLENGTHMODE_FAR_CLIP) && !defined(_MAXRAYLENGTHMODE_DEPTH_TEXTURE)
    const float clipRayLength = maxRayLength;
#else
#    ifdef _CALCSPACE_WORLD
    const float rdv = dot(rp.rayDir, getCameraForward());
#    else
    const float rdv = dot(mul((float3x3)unity_ObjectToWorld, rp.rayDir), getCameraForward());
#    endif  // defined(_CALCSPACE_WORLD)
#    ifdef _MAXRAYLENGTHMODE_FAR_CLIP
    const float linearDepth = _ProjectionParams.z;
#    else
    const float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, fi.screenPos));
#    endif  // defined(_MAXRAYLENGTHMODE_FAR_CLIP)
    const float clipRayLength = linearDepth / rdv;
#endif

    const bool isFace = isFacing(fi);

#if defined(_ASSUMEINSIDE_MAX_LENGTH)
#    ifdef _CALCSPACE_WORLD
    maxInsideLength = maxInsideLength / length(mul((float3x3)unity_WorldToObject, rp.rayDir));
#    endif  // defined(_CALCSPACE_WORLD)
    const float rayDirVecLength = length(rayDirVec);
    const float3 startPos = fi.fragPos - (isFace ? float3(0.0, 0.0, 0.0) : min(rayDirVecLength, maxInsideLength) * rp.rayDir);
    rp.initRayLength = length(startPos - rp.rayOrigin);
    rp.maxRayLength = min(clipRayLength, rayDirVecLength + (isFace ? maxInsideLength : 0.0));
#elif defined(_ASSUMEINSIDE_SIMPLE)
    rp.initRayLength = isFace ? length(fi.fragPos - rp.rayOrigin) : 0.0;
    rp.maxRayLength = isFace ? clipRayLength : length(rayDirVec);
#else
    rp.initRayLength = 0.0;
    rp.maxRayLength = clipRayLength;
#endif  // defined(_ASSUMEINSIDE_MAX_LENGTH)

    return rp;
}


/*!
 * Calculate raymarching parameters for ShadowCaster pass.
 * @param [in] fi  Input data of fragment shader function.
 * @param [in] maxRayLength  Maximum ray length.
 * @param [in] maxInsideLength  Maximum length inside an object.
 * @return Ray parameters.
 */
rayparam calcRayParam(v2f_raymarching_shadowcaster fi, float3 maxRayLength, float3 maxInsideLength)
{
    rayparam rp;

    rp.rayOrigin = fi.rayOrigin;
    rp.rayDir = normalize(isFacing(fi) ? fi.rayDirVec : -fi.rayDirVec);
    rp.initRayLength = 0.0;
    rp.maxRayLength = maxRayLength;

    return rp;
}


/*!
 * @brief Get light map coordinate.
 *
 * @param [in] fi  Input data of fragment shader function.
 * @return Light map coordinate.
 */
float4 getLightMap(v2f_raymarching_forward fi)
{
#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    return fi.lmap;
#else
    return float4(0.0, 0.0, 0.0, 0.0);
#endif  // defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
}


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


/*!
 * @brief Identify whether surface is facing the camera or facing away from the camera.
 * @param [in] fi  Input data of fragment shader for ForwardBase/ForwardAdd pass.
 * @return True if surface facing the camera or facing parameter is not defined, otherwise false.
 */
bool isFacing(v2f_raymarching_forward fi)
{
#if defined(_CULL_FRONT)
    return false;
#elif defined(_CULL_BACK)
    return true;
#elif defined(_NOFORWARDADD_ON) && defined(UNITY_PASS_FORWARDADD)
    // Unused dummy value.
    return true;
#elif defined(SHADER_STAGE_FRAGMENT) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
    return isFacing(fi.facing);
#else
    // Unused dummy value.
    return true;
#endif  // defined(_NOFORWARDADD_ON) && defined(UNITY_PASS_FORWARDADD)
}


/*!
 * @brief Identify whether surface is facing the camera or facing away from the camera.
 * @param [in] fi  Input data of fragment shader for ShadowCaster pass.
 * @return True if surface facing the camera or facing parameter is not defined, otherwise false.
 */
bool isFacing(v2f_raymarching_shadowcaster fi)
{
#if defined(_CULL_FRONT)
    return false;
#elif defined(_CULL_BACK)
    return true;
#elif defined(SHADER_STAGE_FRAGMENT)
    return isFacing(fi.facing);
#else
    return true;
#endif  // defined(SHADER_STAGE_FRAGMENT)
}


/*!
 * @brief Identify whether surface is facing the camera or facing away from the camera.
 * @param [in] facing  Facing variable (fixed or bool).
 * @return True if surface facing the camera, otherwise false.
 */
bool isFacing(face_t facing)
{
#if defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)
    return facing >= 0.0;
#else
    return facing;
#endif  // defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_D3D9)
}


#endif  // VERT_COMMON_INCLUDED
