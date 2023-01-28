#ifndef UTILS_INCLUDED
#define UTILS_INCLUDED

#include "UnityCG.cginc"
#include "AUtoLight.cginc"


float3 worldToObjectPos(float3 worldPos);
float3 worldToObjectPos(float4 worldPos);
float3 objectToWorldPos(float3 localPos);
float3 normalizedWorldSpaceViewDir(float3 worldPos);
float3 normalizedWorldSpaceLightDir(float3 worldPos);
float3 getCameraDirection(float4 projPos);
float3 getCameraDirectionVector(float4 projPos);
half4 applyFog(float fogFactor, half4 color);
half3 rgb2hsv(half3 rgb);
half3 hsv2rgb(half3 hsv);
half3 rgbAddHue(half3 rgb, half hue);


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
 * @brief Get camera direction from projected position.
 * @param [in] Projected position.
 * @return Camera direction in world space.
 */
float3 getCameraDirection(float4 projPos)
{
    return normalize(getCameraDirectionVector(projPos));
}


/*!
 * @brief Get unnormalized camera direction vector from projected position.
 * @param [in] Projected position.
 * @return Camera direction in world space.
 */
float3 getCameraDirectionVector(float4 projPos)
{
    float2 sp = (projPos.xy / projPos.w) * 2.0 - 1.0;
    sp.x *= _ScreenParams.x / _ScreenParams.y;
    return UNITY_MATRIX_V[0].xyz * sp.x
        + UNITY_MATRIX_V[1].xyz * sp.y
        - UNITY_MATRIX_V[2].xyz * abs(UNITY_MATRIX_P[1][1]);
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
 * @param [in] projPos  Projected position.
 * @return Depth value.
 */
float getDepth(float4 projPos)
{
    const float depth = projPos.z / projPos.w;
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
 * @brief Convert from RGB to HSV.
 *
 * @param [in] rgb  Three-dimensional vector of RGB.
 * @return Three-dimensional vector of HSV.
 */
half3 rgb2hsv(half3 rgb)
{
    static const half4 k = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    static const half e = 1.0e-5;

    const half4 p = rgb.g < rgb.b ? half4(rgb.bg, k.wz) : half4(rgb.gb, k.xy);
    const half4 q = rgb.r < p.x ? half4(p.xyw, rgb.r) : half4(rgb.r, p.yzx);
    const half d = q.x - min(q.w, q.y);
    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
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
