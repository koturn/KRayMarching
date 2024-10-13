#ifndef MATH_INCLUDED
#define MATH_INCLUDED

#include "UnityCG.cginc"


float sq(float x);
float fmodglsl(float x, float y);
float2 fmodglsl(float2 x, float2 y);
float3 fmodglsl(float3 x, float3 y);
float4 fmodglsl(float4 x, float4 y);
float rand(float x, float y);
float2 rand(float2 x, float2 y);
float3 rand(float3 x, float3 y);
float4 rand(float4 x, float4 y);
float rand(float x, float y, float p, float q);
float2 rand(float2 x, float2 y, float2 p, float2 q);
float3 rand(float3 x, float3 y, float3 p, float3 q);
float4 rand(float4 x, float4 y, float4 p, float4 q);
float atanPos(float x);
float atanFast(float x);
float atan2Fast(float x, float y);
float3 normalizeEx(float3 v);
float2 rotate2D(float2 v, float angle);
float2 rotate2D(float2 v, float2 pivot, float angle);
float2x2 rotate2DMat(float angle);
float2 invRotate2D(float2 v, float angle);
float2 invRotate2D(float2 v, float2 pivot, float angle);
float2x2 invRotate2DMat(float angle);
float2 pmod(float2 p, float r);
float2 pmod(float2 p, float angle, float r);
float2 pmod(float2 p, float angle, float r, out float pIndex);
float getPmodIndex(float2 p, float r);
float2 pmodFast(float2 p, float r);
float getPmodIndexFast(float2 p, float r);


/*!
 * @brief Calculate squared value.
 *
 * @param [in] x  A value.
 * @return x * x
 */
float sq(float x)
{
    return x * x;
}


/*!
 * @brief Returns the remainder of x divided by y with the same sign as y.
 *
 * @param [in] x  Scalar numerator.
 * @param [in] y  Scalar denominator.
 * @return Remainder of x / y with the same sign as y.
 */
float fmodglsl(float x, float y)
{
    return x - y * floor(x / y);
}


/*!
 * @brief Returns the remainder of x divided by y with the same sign as y.
 *
 * @param [in] x  Vector numerator.
 * @param [in] y  Vector denominator.
 * @return Remainder of x / y with the same sign as y.
 */
float2 fmodglsl(float2 x, float2 y)
{
    return x - y * floor(x / y);
}


/*!
 * @brief Returns the remainder of x divided by y with the same sign as y.
 *
 * @param [in] x  Vector numerator.
 * @param [in] y  Vector denominator.
 * @return Remainder of x / y with the same sign as y.
 */
float3 fmodglsl(float3 x, float3 y)
{
    return x - y * floor(x / y);
}


/*!
 * @brief Returns the remainder of x divided by y with the same sign as y.
 *
 * @param [in] x  Vector numerator.
 * @param [in] y  Vector denominator.
 * @return Remainder of x / y with the same sign as y.
 */
float4 fmodglsl(float4 x, float4 y)
{
    return x - y * floor(x / y);
}


/*!
 * @brief Returns a random value between 0.0 and 1.0.
 * @param [in] x  First seed value used for generation.
 * @param [in] y  Second seed value used for generation.
 * @return Pseudo-random number value between 0.0 and 1.0.
 */
float rand(float x, float y)
{
    return frac(sin(x * 12.9898 + y * 78.233) * 43758.5453);
}


/*!
 * @brief Returns a random value between 0.0 and 1.0.
 * @param [in] x  First seed vector used for generation.
 * @param [in] y  Second seed vector used for generation.
 * @return Pseudo-random number vector between 0.0 and 1.0.
 */
float2 rand(float2 x, float2 y)
{
    return frac(sin(x * 12.9898 + y * 78.233) * 43758.5453);
}


/*!
 * @brief Returns a random value between 0.0 and 1.0.
 * @param [in] x  First seed vector used for generation.
 * @param [in] y  Second seed vector used for generation.
 * @return Pseudo-random number vector between 0.0 and 1.0.
 */
float3 rand(float3 x, float3 y)
{
    return frac(sin(x * 12.9898 + y * 78.233) * 43758.5453);
}


/*!
 * @brief Returns a random value between 0.0 and 1.0.
 * @param [in] x  First seed vector used for generation.
 * @param [in] y  Second seed vector used for generation.
 * @return Pseudo-random number vector between 0.0 and 1.0.
 */
float4 rand(float4 x, float4 y)
{
    return frac(sin(x * 12.9898 + y * 78.233) * 43758.5453);
}


/*!
 * @brief Returns a random value between p and q.
 * @param [in] x  First seed value used for generation.
 * @param [in] y  Second seed value used for generation.
 * @param [in] p  Minimum output value.
 * @param [in] q  Maximum output value.
 * @return Pseudo-random number value between p and q.
 */
float rand(float x, float y, float p, float q)
{
    return lerp(p, q, rand(x, y));
}


/*!
 * @brief Returns a random value between p and q.
 * @param [in] x  First seed vector used for generation.
 * @param [in] y  Second seed vector used for generation.
 * @param [in] p  Minimum output value.
 * @param [in] q  Maximum output value.
 * @return Pseudo-random number vector between p and q.
 */
float2 rand(float2 x, float2 y, float2 p, float2 q)
{
    return lerp(p, q, rand(x, y));
}


/*!
 * @brief Returns a random value between p and q.
 * @param [in] x  First seed vector used for generation.
 * @param [in] y  Second seed vector used for generation.
 * @param [in] p  Minimum output value.
 * @param [in] q  Maximum output value.
 * @return Pseudo-random number vector between p and q.
 */
float3 rand(float3 x, float3 y, float3 p, float3 q)
{
    return lerp(p, q, rand(x, y));
}


/*!
 * @brief Returns a random value between p and q.
 * @param [in] x  First seed vector used for generation.
 * @param [in] y  Second seed vector used for generation.
 * @param [in] p  Minimum output value.
 * @param [in] q  Maximum output value.
 * @return Pseudo-random number vector between p and q.
 */
float4 rand(float4 x, float4 y, float4 p, float4 q)
{
    return lerp(p, q, rand(x, y));
}


/*
 * @brief Fast acos().
 * @param [in] x  The first argument of acos().
 * @return Approximate value of acos().
 * @see https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
 */
float acosFast(float x)
{
#if 0
    const float res = sqrt(1.0 - abs(x)) * UNITY_HALF_PI;
#else
    const float ox = abs(x);
    const float res = (-0.156583 * ox + UNITY_HALF_PI) * sqrt(1.0 - ox);
#endif

    return x >= 0.0 ? res : (UNITY_PI - res);
}


/*
 * @brief Fast asin().
 * @param [in] x  The first argument of asin().
 * @return Approximate value of asin().
 * @see https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
 */
float asinFast(float x)
{
    return UNITY_HALF_PI - acosFast(x);
}


/*
 * @brief Tune for input [-infinity, infinity] and provide output [0, PI/2].
 * @param [in] x  Input [-infinity, infinity].
 * @return Approximate positive value of atan().
 */
float atanPos(float x)
{
    const float absX = abs(x);
    const float t0 = absX < 1.0 ? absX : rcp(absX);
#if 1
    const float poly = (-0.269408 * t0 + 1.05863) * t0;
#else
    const float t1 = t0 * t0;
    float poly = 0.0872929;
    poly = -0.301895 + poly * t1;
    poly = 1.0 + poly * t1;
    poly *= t0;
#endif

    return absX < 1.0 ? poly : (UNITY_HALF_PI - poly);
}


/*
 * @brief Fast atan().
 * @param [in] x  The first argument of atan().
 * @return Approximate value of atan().
 * @see https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
 */
float atanFast(float x)
{
    const float t0 = atanPos(x);
    return x < 0.0 ? -t0 : t0;
}


/*
 * @brief Fast atan2().
 * @param [in] x  The first argument of atan2().
 * @param [in] y  The second argument of atan2().
 * @return Approximate value of atan().
 * @see https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
 */
float atan2Fast(float x, float y)
{
#if 1
    const float2 p = float2(x, y);
    const float2 d = p.xy / p.yx;

    //
    // Tune for positive input [0, infinity] and provide output [0, PI/2]
    //
    const float2 absD = abs(d);
    const float t0 = absD.x < 1.0 ? absD.x : absD.y;
#if 1
    const float poly = (-0.269408 * t0 + 1.05863) * t0;
#else
    const float t1 = t0 * t0;
    float poly = 0.0872929;
    poly = -0.301895 + poly * t1;
    poly = 1.0 + poly * t1;
    poly *= t0;
#endif
    const float u0 = absD.x < 1.0 ? poly : (UNITY_HALF_PI - poly);

    return (d.x >= 0.0 ? u0 : -u0) + (y >= 0.0 ? 0.0 : x >= 0.0 ? UNITY_PI : -UNITY_PI);
#else
    return atanFast(x / y) + UNITY_PI * (y < 0.0 ? 1.0 : 0.0) * (x < 0.0 ? -1.0 : 1.0);
#endif
}


/*!
 * @brief Zero-Division avoided normalize.
 * @param [in] v  A vector.
 * @return normalized vector or zero vector.
 */
float3 normalizeEx(float3 v)
{
    const float vDotV = dot(v, v);
    return vDotV == 0.0 ? v : (rsqrt(vDotV) * v);
}


/*!
 * @brief Rotate on 2D plane
 *
 * @param [in] v  Target vector
 * @param [in] angle  Angle of rotation.
 * @return Rotated vector.
 */
float2 rotate2D(float2 v, float angle)
{
    float s, c;
    sincos(angle, /* out */ s, /* out */ c);
    return float2(
        v.x * c - v.y * s,
        v.x * s + v.y * c);
}


/*!
 * @brief Rotate on 2D plane
 *
 * @param [in] v  Target vector
 * @param [in] pivot  Pivot of rotation.
 * @param [in] angle  Angle of rotation.
 * @return Rotated vector.
 */
float2 rotate2D(float2 v, float2 pivot, float angle)
{
    return rotate2D(v - pivot, angle) + pivot;
}


/*!
 * @brief Get 2D-rotation matrix.
 *
 * @param [in] angle  Angle of rotation.
 * @return 2D-rotation matrix.
 */
float2x2 rotate2DMat(float angle)
{
    float s, c;
    sincos(angle, /* out */ s, /* out */ c);
    return float2x2(c, -s, s, c);
}


/*!
 * @brief Inverse rotate on 2D plane
 *
 * @param [in] v  Target vector
 * @param [in] angle  Angle of rotation.
 * @return Rotated vector.
 */
float2 invRotate2D(float2 v, float angle)
{
    float s, c;
    sincos(angle, /* out */ s, /* out */ c);
    return float2(
        v.x * c + v.y * s,
        -v.x * s + v.y * c);
}


/*!
 * @brief Inverse rotate on 2D plane
 *
 * @param [in] v  Target vector
 * @param [in] pivot  Pivot of rotation.
 * @param [in] angle  Angle of rotation.
 * @return Rotated vector.
 */
float2 invRotate2D(float2 v, float2 pivot, float angle)
{
    return invRotate2D(v - pivot, angle) + pivot;
}


/*!
 * @brief Get Inverse 2D-rotation matrix.
 *
 * @param [in] angle  Angle of rotation.
 * @return 2D-rotation matrix.
 */
float2x2 invRotate2DMat(float angle)
{
    float s, c;
    sincos(angle, /* out */ s, /* out */ c);
    return float2x2(c, s, -s, c);
}


/*!
 * @brief Polar Mod (Fold Rotate) Function.
 *
 * @param [in] p  2D-coordinate.
 * @param [in] r  Number of divisions.
 * @return 2D-coordinate of polar mod.
 */
float2 pmod(float2 p, float r)
{
    return pmod(p, atan2(p.y, p.x), r);
}


/*!
 * @brief Polar Mod (Fold Rotate) Function.
 *
 * @param [in] p  2D-coordinate.
 * @param [in] angle  Value of atan2(p.x, p.y).
 * @param [in] r  Number of divisions.
 * @return 2D-coordinate of polar mod.
 */
float2 pmod(float2 p, float angle, float r)
{
    const float a = angle + UNITY_PI / r;
    const float n = UNITY_TWO_PI / r;
    return rotate2D(p, -floor(a / n) * n);
}


/*!
 * @brief Polar Mod (Fold Rotate) Function.
 *
 * @param [in] p  2D-coordinate.
 * @param [in] angle  Value of atan2(p.x, p.y).
 * @param [in] r  Number of divisions.
 * @param [in] pIndex  Index of rotate position.
 * @return 2D-coordinate of polar mod.
 */
float2 pmod(float2 p, float angle, float r, out float pIndex)
{
    const float a = angle + UNITY_PI / r;
    const float n = UNITY_TWO_PI / r;
    pIndex = floor(a / n);
    return rotate2D(p, -pIndex * n);
}


/*!
 * @brief Get index of Polar Mod (Fold Rotate).
 *
 * @param [in] p  2D-coordinate.
 * @param [in] r  Number of divisions.
 * @return Index of Polar Mod.
 */
float getPmodIndex(float2 p, float r)
{
    const float a = atan2(p.y, p.x) + UNITY_PI / r;
    const float n = UNITY_TWO_PI / r;
    return floor(a / n);
}


/*!
 * @brief Polar Mod (Fold Rotate) Function using atan2Fast().
 *
 * @param [in] p  2D-coordinate.
 * @param [in] r  Number of divisions.
 * @return 2D-coordinate of polar mod.
 */
float2 pmodFast(float2 p, float r)
{
    return pmod(p, atan2Fast(p.y, p.x), r);
}


/*!
 * @brief Get index of Polar Mod (Fold Rotate) using atan2Fast().
 *
 * @param [in] p  2D-coordinate.
 * @param [in] r  Number of divisions.
 * @return Index of Polar Mod.
 */
float getPmodIndexFast(float2 p, float r)
{
    const float a = atan2Fast(p.y, p.x) + UNITY_PI / r;
    const float n = UNITY_TWO_PI / r;
    return floor(a / n);
}


#endif  // MATH_INCLUDED
