#ifndef MATH_INCLUDED
#define MATH_INCLUDED

#include "UnityCG.cginc"


float sq(float x);
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


#ifdef MATH_REPLACE_TO_FAST_INVTRIFUNC
#    define acos(x)  acosFast(x)
#    define asin(x)  asinFast(x)
#    define atan(x)  atanFast(x)
#    define atan2(x, y)  atan2Fast(x, y)
#endif  // MATH_REPLACE_TO_FAST_INVTRIFUNC


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
 * @brief Calculate positive value of atan().
 * @param [in] x  The first argument of atan().
 * @return Approximate positive value of atan().
 */
float atanPos(float x)
{
    const float t0 = x < 1.0 ? x : rcp(x);
#if 1
    const float poly = (-0.269408 * t0 + 1.05863) * t0;
#else
    const float t1 = t0 * t0;
    float poly = 0.0872929;
    poly = -0.301895 + poly * t1;
    poly = 1.0 + poly * t1;
    poly *= t0;
#endif

    return x < 1.0 ? poly : (UNITY_HALF_PI - poly);
}


/*
 * @brief Fast atan().
 * @param [in] x  The first argument of atan().
 * @return Approximate value of atan().
 * @see https://seblagarde.wordpress.com/2014/12/01/inverse-trigonometric-functions-gpu-optimization-for-amd-gcn-architecture/
 */
float atanFast(float x)
{
    const float t0 = atanPos(abs(x));
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
    return atanFast(x / y) + UNITY_PI * (y < 0.0) * (x < 0.0 ? -1.0 : 1.0);
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
    return mul(rotate2DMat(angle), v);
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
    return mul(invRotate2DMat(angle), v);
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
    return pmod(p, atan2(p.x, p.y), r);
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
    return rotate2D(p, floor(a / n) * n);
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
    return rotate2D(p, pIndex * n);
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


#endif  // MATH_INCLUDED
