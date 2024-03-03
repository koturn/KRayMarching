#ifndef UTILS_INCLUDED
#define UTILS_INCLUDED

#include "UnityCG.cginc"
#include "AUtoLight.cginc"


float3 worldToObjectPos(float3 worldPos);
float3 worldToObjectPos(float4 worldPos);
float3 objectToWorldPos(float3 localPos);
float3 normalizedWorldSpaceViewDir(float3 worldPos);
float3 normalizedWorldSpaceLightDir(float3 worldPos);
float3 applyShadowBias(float3 worldPos, float3 worldNormal);
float3 getCameraRight();
float3 getCameraUp();
float3 getCameraForward();
float getCameraFocalLength();
bool isCameraPerspective();
bool isCameraOrthographic();
float3 getCameraDir(float4 screenPos);
float3 getCameraDirVec(float4 screenPos);
half4 applyFog(float fogFactor, half4 color);
float getDepth(float4 clipPos);
#if defined(SHADER_API_D3D11) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))
half4 tex2DTriPlanar(Texture2D tex, SamplerState samplertex, float3 pos, float3 normal);
#endif  // defined(SHADER_API_D3D11) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))
half4 tex2DTriPlanar(sampler2D tex, float3 pos, float3 normal);
half3 rgb2hsv(half3 rgb);
half3 hsv2rgb(half3 hsv);
half3 rgbAddHue(half3 rgb, half hue);


#if defined(SHADER_API_D3D11) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))
#    define SAMPLE_TEX2D_TRIPLANAR(tex, pos, normal)  tex2DTriPlanar(tex, sampler##tex, pos, normal)
#else
#    define SAMPLE_TEX2D_TRIPLANAR(tex, pos, normal)  tex2DTriPlanar(tex, pos, normal)
#endif  // defined(SHADER_API_D3D11) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))


/*!
 * @brief Convert from world coordinate to local coordinate.
 *
 * @param [in] worldPos  World coordinate.
 * @return World coordinate.
 */
float3 worldToObjectPos(float3 worldPos)
{
    return worldToObjectPos(float4(worldPos, 1.0));
}

/*!
 * @brief Convert from world coordinate to local coordinate.
 *
 * @param [in] worldPos  World coordinate.
 * @return World coordinate.
 */
float3 worldToObjectPos(float4 worldPos)
{
    return mul(unity_WorldToObject, worldPos).xyz;
}

/*!
 * @brief Convert from local coordinate to world coordinate.
 *
 * @param [in] localPos  Local coordinate.
 * @return World coordinate.
 */
float3 objectToWorldPos(float3 localPos)
{
    return mul(unity_ObjectToWorld, float4(localPos, 1.0)).xyz;
}


/*!
 * @brief Get view direction in world space.
 *
 * @param [in] worldPos  World coordinate.
 * @return View direction in world space.
 */
float3 normalizedWorldSpaceViewDir(float3 worldPos)
{
    return normalize(UnityWorldSpaceViewDir(worldPos));
}

/*!
 * @brief Get light direction in world space.
 *
 * @param [in] worldPos  World coordinate.
 * @return Light direction in world space.
 */
float3 normalizedWorldSpaceLightDir(float3 worldPos)
{
#if !defined(USING_LIGHT_MULTI_COMPILE)
    return normalize(_WorldSpaceLightPos0.xyz - worldPos * _WorldSpaceLightPos0.w);
#elif defined(USING_DIRECTIONAL_LIGHT)
    return _WorldSpaceLightPos0.xyz;
#else
    return normalize(_WorldSpaceLightPos0.xyz - worldPos);
#endif
}


/*!
 * @brief Correct world space position with ShadowBias.
 *
 * @param [in] worldPos  World space position.
 * @param [in] worldNormal  World space normal.
 * @return Corrected world space position.
 */
float3 applyShadowBias(float3 worldPos, float3 worldNormal)
{
    UNITY_BRANCH
    if (unity_LightShadowBias.z != 0.0) {
#    if defined(USING_LIGHT_MULTI_COMPILE) && defined(USING_DIRECTIONAL_LIGHT)
        const float3 worldLightDir = UnityWorldSpaceLightDir(worldPos);
#    else
        const float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
#    endif  // defined(USING_LIGHT_MULTI_COMPILE) && defined(USING_DIRECTIONAL_LIGHT)
        const float shadowCos = dot(worldNormal, worldLightDir);
        const float shadowSine = sqrt(1.0 - shadowCos * shadowCos);
        const float normalBias = unity_LightShadowBias.z * shadowSine;
        worldPos.xyz -= worldNormal * normalBias;
    }

    return worldPos;
}


/*!
 * @brief Get right vector of the camera.
 * @return Right vector of the camera.
 */
float3 getCameraRight()
{
    return UNITY_MATRIX_V[0].xyz;
}


/*!
 * @brief Get up vector of the camera.
 * @return Up vector of the camera.
 */
float3 getCameraUp()
{
    return UNITY_MATRIX_V[1].xyz;
}


/*!
 * @brief Get forward direction of the camera.
 * @return Forward direction of the camera.
 */
float3 getCameraForward()
{
    return -UNITY_MATRIX_V[2].xyz;
}


/*!
 * @brief Get focal length of the camera.
 * @return Focal length of the camera.
 */
float getCameraFocalLength()
{
    return abs(UNITY_MATRIX_P[1][1]);
}


/*!
 * @brief Identify whether the camera is perspective or not.
 * @return True if the camera is perspective, otherwise false.
 */
bool isCameraPerspective()
{
    // return any(UNITY_MATRIX_P[3].xyz);
    // return any(UNITY_MATRIX_P[3].xyz != float3(1.0, 1.0, 1.0));
    // return dot(UNITY_MATRIX_P[3].xyz, UNITY_MATRIX_P[3].xyz) > 0.0;
    return UNITY_MATRIX_P[3][3] != 1.0;
    // return unity_OrthoParams.w == 0.0;
}


/*!
 * @brief Identify whether the camera is orthographic or not.
 * @return True if the camera is orthographic, otherwise false.
 */
bool isCameraOrthographic()
{
    // return !any(UNITY_MATRIX_P[3].xyz);
    // return all(UNITY_MATRIX_P[3].xyz == float3(0.0, 0.0, 0.0));
    // return dot(UNITY_MATRIX_P[3].xyz, UNITY_MATRIX_P[3].xyz) == 0.0;
    return UNITY_MATRIX_P[3][3] == 1.0;
    // return unity_OrthoParams.w == 1.0;
}


/*!
 * @brief Get camera direction from projected position.
 * @param [in] Screen space position.
 * @return Camera direction in world space.
 */
float3 getCameraDir(float4 screenPos)
{
    return normalize(getCameraDirVec(screenPos));
}


/*!
 * @brief Get unnormalized camera direction vector from projected position.
 * @param [in] Screen space position.
 * @return Camera direction in world space.
 */
float3 getCameraDirVec(float4 screenPos)
{
    float2 sp = (screenPos.xy / screenPos.w) * 2.0 - 1.0;

    // Following code is equivalent to: sp.x *= _ScreenParams.x / _ScreenParams.y;
    sp.x *= _ScreenParams.x * _ScreenParams.w - _ScreenParams.x;

    return getCameraRight() * sp.x
        + getCameraUp() * sp.y
        + getCameraForward() * getCameraFocalLength();
}


/*!
 * @brief Apply fog.
 *
 * UNITY_APPLY_FOG includes some variable declaration.
 * This function can be used to localize those declarations.
 * If fog is disabled, this function returns color as is.
 *
 * @param [in] color  Target color.
 * @return Fog-applied color.
 */
half4 applyFog(float fogFactor, half4 color)
{
    UNITY_APPLY_FOG(fogFactor, color);
    return color;
}


/*!
 * @brief Get depth from projected position.
 * @param [in] clipPos  Clip space position.
 * @return Depth value.
 */
float getDepth(float4 clipPos)
{
    const float depth = clipPos.z / clipPos.w;
#if defined(SHADER_API_GLCORE) \
    || defined(SHADER_API_OPENGL) \
    || defined(SHADER_API_GLES) \
    || defined(SHADER_API_GLES3)
    return depth * 0.5 + 0.5;
#else
    return depth;
#endif
}


/*!
* @brief Sample texture using Tri-Planar texture mapping.
*
* @param [in] tex  2D texture.
* @param [in] sampler  Texture sampler for tex.
* @param [in] pos  Object/World space position.
* @param [in] normal  Normal.
*
* @return Sampled color.
*/
half4 tex2DTriPlanar(Texture2D tex, SamplerState samplertex, float3 pos, float3 normal)
{
    float3 blending = normalize(max(abs(normal), 0.00001));
    blending /= dot(blending, (1.0).xxx);
    const half4 xaxis = tex.Sample(samplertex, pos.yz);
    const half4 yaxis = tex.Sample(samplertex, pos.xz);
    const half4 zaxis = tex.Sample(samplertex, pos.xy);
    return xaxis * blending.x + yaxis * blending.y + zaxis * blending.z;
}


/*!
* @brief Sample texture using Tri-Planar texture mapping.
*
* @param [in] tex  2D texture samplar.
* @param [in] pos  Object/World space position.
* @param [in] normal  Normal.
*
* @return Sampled color.
*/
half4 tex2DTriPlanar(sampler2D tex, float3 pos, float3 normal)
{
    float3 blending = normalize(max(abs(normal), 0.00001));
    blending /= dot(blending, (1.0).xxx);
    const half4 xaxis = tex2D(tex, pos.yz);
    const half4 yaxis = tex2D(tex, pos.xz);
    const half4 zaxis = tex2D(tex, pos.xy);
    return xaxis * blending.x + yaxis * blending.y + zaxis * blending.z;
}


/*!
 * @brief Convert from RGB to HSV.
 *
 * @param [in] rgb  Three-dimensional vector of RGB.
 * @return Three-dimensional vector of HSV.
 */
half3 rgb2hsv(half3 rgb)
{
    static const half4 k = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    static const half e = 1.0e-5;

#if 1
    // Optimized version.
    const bool b1 = rgb.g < rgb.b;
    half4 p = half4(b1 ? rgb.bg : rgb.gb, b1 ? k.wz : k.xy);

    const bool b2 = rgb.r < p.x;
    p.xyz = b2 ? p.xyw : p.yzx;
    const half4 q = b2 ? half4(p.xyz, rgb.r) : half4(rgb.r, p.xyz);

    const half d = q.x - min(q.w, q.y);
    const half2 hs = half2(q.w - q.y, d) / half2(6.0 * d + e, q.x + e);

    return half3(abs(q.z + hs.x), hs.y, q.x);
#else
    const half4 p = rgb.g < rgb.b ? half4(rgb.bg, k.wz) : half4(rgb.gb, k.xy);
    const half4 q = rgb.r < p.x ? half4(p.xyw, rgb.r) : half4(rgb.r, p.yzx);
    const half d = q.x - min(q.w, q.y);
    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
#endif
}


/*!
 * @brief Convert from HSV to RGB.
 *
 * @param [in] hsv  Three-dimensional vector of HSV.
 * @return Three-dimensional vector of RGB.
 */
half3 hsv2rgb(half3 hsv)
{
    static const half4 k = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);

    const half3 p = abs(frac(hsv.xxx + k.xyz) * 6.0 - k.www);
    return hsv.z * lerp(k.xxx, saturate(p - k.xxx), hsv.y);
}


/*!
 * @brief Add hue to RGB color.
 *
 * @param [in] rgb  Three-dimensional vector of RGB.
 * @param [in] hue  Scalar of hue.
 * @return Three-dimensional vector of RGB.
 */
half3 rgbAddHue(half3 rgb, half hue)
{
    half3 hsv = rgb2hsv(rgb);
    hsv.x += hue;
    return hsv2rgb(hsv);
}


#endif  // UTILS_INCLUDED
