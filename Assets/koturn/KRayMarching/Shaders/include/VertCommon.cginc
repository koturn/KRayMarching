#ifndef VERT_COMMON_INCLUDED
#define VERT_COMMON_INCLUDED

#include "Utils.cginc"


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
    //! Ray origin in object/world space.
    nointerpolation float3 rayOrigin : TEXCOORD0;
    //! Unnormalized ray direction in object/world space.
    float3 rayDirVec : TEXCOORD1;
#if defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
    //! Fragment position in object/world space.
    float3 fragPos : TEXCOORD2;
#endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
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
#if defined(SHADER_STAGE_FRAGMENT) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
    //! Facing variable (fixed or bool).
    face_t facing : FACE_SEMANTICS;
#endif  // defined(SHADER_STAGE_FRAGMENT) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
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
#if defined(SHADER_STAGE_FRAGMENT)
    //! Facing variable (fixed or bool).
    face_t facing : FACE_SEMANTICS;
#endif  // defined(SHADER_STAGE_FRAGMENT)
};


float2 calcInitAndMaxRayLength(v2f_raymarching_forward fi, float3 rayDir, float3 maxRayLength, float3 maxInsideLength);
float4 getLightMap(v2f_raymarching_forward fi);
fixed getLightAttenRayMarching(v2f_raymarching_forward fi, float3 worldPos);
bool isFacing(v2f_raymarching_forward fi);
bool isFacing(v2f_raymarching_shadowcaster fi);
bool isFacing(face_t facing);


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
    const float3 vertPos = objectToWorldPos(v.vertex.xyz);
    o.rayOrigin = _WorldSpaceCameraPos;
#else
    const float3 vertPos = v.vertex.xyz;
    o.rayOrigin = worldToObjectPos(_WorldSpaceCameraPos);
#endif  // defined(_CALCSPACE_WORLD)

    o.rayDirVec = vertPos - o.rayOrigin;

#if defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)
    o.fragPos = vertPos;
#endif  // defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH)

#ifdef LIGHTMAP_ON
    o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif  // LIGHTMAP_ON
#ifdef DYNAMICLIGHTMAP_ON
    o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif  // DYNAMICLIGHTMAP_ON

    UNITY_TRANSFER_LIGHTING(o, v.texcoord1);

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
 * Calculate initial and maximum ray length.
 * @param [in] fi  Input data of fragment shader function.
 * @param [in] rayDir  Direction of the ray.
 * @param [in] maxRayLength  Maximum ray length.
 * @param [in] maxInsideLength  Maximum length inside an object.
 * @return Intial and recalculated maximum ray length.
 */
float2 calcInitAndMaxRayLength(v2f_raymarching_forward fi, float3 rayDir, float3 maxRayLength, float3 maxInsideLength)
{
#if defined(_ASSUMEINSIDE_MAX_LENGTH)
#    ifdef _CALCSPACE_WORLD
    maxInsideLength = maxInsideLength / length(mul((float3x3)unity_WorldToObject, rayDir));
#    endif  // defined(_CALCSPACE_WORLD)
    const float rayDirVecLength = length(fi.rayDirVec);
    const float3 startPos = fi.fragPos - (isFacing(fi) ? float3(0.0, 0.0, 0.0) : min(rayDirVecLength, maxInsideLength) * rayDir);
    const float initRayLength = length(startPos - fi.rayOrigin);
    const float recalcedMaxRayLength = min(maxRayLength, rayDirVecLength + (isFacing(fi) ? maxInsideLength : 0.0));
#elif defined(_ASSUMEINSIDE_SIMPLE)
    const float initRayLength = isFacing(fi) ? length(fi.fragPos - fi.rayOrigin) : 0.0;
    const float recalcedMaxRayLength = isFacing(fi) ? maxRayLength : length(fi.rayDirVec);
#else
    const float initRayLength = 0.0;
    const float recalcedMaxRayLength = maxRayLength;
#endif  // defined(_ASSUMEINSIDE_MAX_LENGTH)

    return float2(initRayLength, recalcedMaxRayLength);
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
#if defined(_NOFORWARDADD_ON) && defined(UNITY_PASS_FORWARDADD)
    return true;
#elif defined(SHADER_STAGE_FRAGMENT) && (defined(_ASSUMEINSIDE_SIMPLE) || defined(_ASSUMEINSIDE_MAX_LENGTH))
    return isFacing(fi.facing);
#else
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
#if defined(SHADER_STAGE_FRAGMENT)
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
