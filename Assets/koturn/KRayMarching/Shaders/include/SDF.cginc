#ifndef SDFPRIMITIVES_INCLUDED
#define SDFPRIMITIVES_INCLUDED


float sdSphere(float3 p, float r);
float sdTorus(float3 p, float2 t);
float sdCappedCylinder(float3 p, float h, float r);
float sdOctahedron(float3 p, float s);
float sdOctahedron(float3 p, float s, float3 scales);


/*!
 * @brief SDF of Sphere.
 * @param [in] r  Radius of sphere.
 * @return Signed Distance to the Sphere.
 */
float sdSphere(float3 p, float r)
{
    return length(p) - r;
}


/*!
 * @brief SDF of Torus.
 * @param [in] p  Position of the tip of the ray.
 * @param [in] t  (t.x, t.y) = (radius of torus, thickness of torus).
 * @return Signed Distance to the Sphere.
 */
float sdTorus(float3 p, float2 t)
{
    const float2 q = float2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}


/*!
 * @brief SDF of Capped Cylinder.
 * @param [in] p  Position of the tip of the ray.
 * @param [in] h  Length of cylinder.
 * @param [in] r  Radius of cylinder.
 * @return Signed Distance to the Sphere.
 */
float sdCappedCylinder(float3 p, float h, float r)
{
    const float2 d = abs(float2(length(p.xz), p.y)) - float2(h, r);
    return min(0.0, max(d.x, d.y)) + length(max(d, 0.0));
}


/*!
 * @brief SDF of Octahedron.
 * @param [in] p  Position of the tip of the ray.
 * @param [in] s  Size of Octahedron.
 * @return Signed Distance to the Octahedron.
 */
float sdOctahedron(float3 p, float s)
{
    return sdOctahedron(p, s, float3(1.0, 1.0, 1.0));
}


/*!
 * @brief SDF of Octahedron.
 * @param [in] p  Position of the tip of the ray.
 * @param [in] s  Size of Octahedron.
 * @param [in] scales  Size of Octahedron.
 * @return Signed Distance to the Octahedron.
 */
float sdOctahedron(float3 p, float s, float3 scales)
{
    static const float kNormalizeTerm = rcp(sqrt(3));
    return (dot(abs(p), scales) - s) * kNormalizeTerm;
}


#endif  // SDFPRIMITIVES_INCLUDED
