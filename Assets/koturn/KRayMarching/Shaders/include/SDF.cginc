#ifndef SDF_INCLUDED
#define SDF_INCLUDED


float sdSphere(float3 p, float r);
float sdBox(float3 p, float3 size);
float sdRoundBox(float3 p, float3 size, float r);
float sdBoxFrame(float3 p, float3 size, float e);
float sdTorus(float3 p, float2 t);
float sdTorus(float3 p, float radius, float thickness);
float sdCappedTorus(float3 p, float angle, float radius, float thickness);
float sdLink(float3 p, float height, float size, float thickness);
float sdCylinder(float3 p, float3 c);
float sdCylinder(float3 p, float2 center, float radius);
float sdCone(float3 p, float angle, float height);
float sdConeExact(float3 p, float angle, float height);
float sdCone(float3 p, float angle);
float sdPlane(float3 p, float3 normal, float height);
float sdHexPrism(float3 p, float size, float height);
float sdTriPrism(float3 p, float size, float height);
float sdCapsule(float3 p, float3 a, float3 b, float radius);
float sdCapsule(float3 p, float height, float radius);
float sdCappedCylinder(float3 p, float height, float radius);
float sdCappedCylinder(float3 p, float3 a, float3 b, float radius);
float sdRoundedCylinder(float3 p, float height, float radius, float r);
float sdCappedCone(float3 p, float height, float radius1, float radius2);
float sdCappedCone(float3 p, float3 a, float3 b, float ra, float rb);
float sdSolidAngle(float3 p, float angle, float height);
float sdCutSphere(float3 p, float radius, float cutHeight);
float sdCutHollowSphere(float3 p, float radius, float height, float thickness);
float sdRoundCone(float3 p, float height, float radius1, float radius2);
float sdRoundCone(float3 p, float3 a, float3 b, float ra, float rb);
float sdEllipsoid(float3 p, float3 radiuses);
float sdVesicaSegment(float3 p, float3 a, float3 b, float width);
float sdRhombus(float3 p, float xSize, float zSize, float height, float r);
float sdRhombus(float3 p, float2 xzSize, float height, float r);
float sdOctahedronExact(float3 p, float s);
float sdOctahedronExact(float3 p, float s, float3 scales);
float sdOctahedron(float3 p, float s);
float sdOctahedron(float3 p, float s, float3 scales);
float sdPyramid(float3 p, float height);


/*!
 * @brief SDF of Sphere.
 * @param [in] p  Position.
 * @param [in] r  Radius of sphere.
 * @return Signed Distance to the Sphere.
 * @see https://www.shadertoy.com/view/Xds3zN
 */
float sdSphere(float3 p, float r)
{
    return length(p) - r;
}


/*!
 * @brief SDF of box.
 * @param [in] p  Position.
 * @param [in] size  Size in each XYZ direction.
 * @return Signed Distance to the box.
 * @see https://www.youtube.com/watch?v=62-pRVZuS5c
 */
float sdBox(float3 p, float3 size)
{
    const float3 q = abs(p) - size;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}


/*!
 * @brief SDF of rounded box.
 * @param [in] p  Position.
 * @param [in] size  Size in each XYZ direction.
 * @param [in] r  Rounding parameter.
 * @return Signed Distance to the rounded box.
 */
float sdRoundBox(float3 p, float3 size, float r)
{
    return sdBox(p, size) - r;
}


/*!
 * @brief SDF of frame of box.
 * @param [in] p  Position.
 * @param [in] size  Size in each XYZ direction.
 * @param [in] e  Frame size.
 * @return Signed Distance to the frame of Box.
 * @see https://www.shadertoy.com/view/3ljcRh
 */
float sdBoxFrame(float3 p, float3 size, float e)
{
    p = abs(p) - size;
    const float3 q = abs(p + e) - e;
    return min(
        length(max(0.0, float3(p.x, q.y, q.z))) + min(0.0, max(p.x, max(q.y, q.z))),
        min(
            length(max(0.0, float3(q.x, p.y, q.z))) + min(0.0, max(q.x, max(p.y, q.z))),
            length(max(0.0, float3(q.x, q.y, p.z))) + min(0.0, max(q.x, max(q.y, p.z)))));
}


/*!
 * @brief SDF of Torus.
 * @param [in] p  Position.
 * @param [in] t  (t.x, t.y) = (radius of torus, thickness of torus).
 * @return Signed Distance to the Torus.
 */
float sdTorus(float3 p, float2 t)
{
    const float2 q = float2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}


/*!
 * @brief SDF of Torus.
 * @param [in] p  Position.
 * @param [in] radius  Radius of Torus.
 * @param [in] thickness  Thickness of Torus.
 * @return Signed Distance to the Torus.
 */
float sdTorus(float3 p, float radius, float thickness)
{
    const float2 q = float2(length(p.xz) - radius, p.y);
    return length(q) - thickness;
}


/*!
 * @brief SDF of Capped Torus.
 * @param [in] p  Position.
 * @param [in] angle  Angle
 * @param [in] radius  Radius of Torus
 * @param [in] thickness  Thickness of Torus.
 * @return Signed Distance to the Torus.
 * @see https://www.shadertoy.com/view/tl23RK
 */
float sdCappedTorus(float3 p, float angle, float radius, float thickness)
{
    float2 sc;
    sincos(angle, /* out */ sc.x, /* out */ sc.y);

    p.x = abs(p.x);
    const float k = (sc.y * p.x > sc.x * p.z) ? dot(p.xz, sc) : length(p.xz);
    // const float2 scp = sc * p.zx;
    // const float k = (scp.y > scp.x) ? dot(p.zy, sc) : length(p.zy);
    // dp3, mad, mad, add
    // return sqrt(dot(p, p) + radius * radius - 2.0 * radius * k) - thickness;
    // ---
    // dp3, mad, mad
    return sqrt(dot(p, p) + radius * (radius - 2.0 * k)) - thickness;
}


/*!
 * @brief SDF of Link.
 * @param [in] p  Position.
 * @param [in] height  Height of Link.
 * @param [in] size  Size of hole of Link.
 * @param [in] thickness  Line radius of Link.
 * @return Signed Distance to the Link.
 * @see https://www.shadertoy.com/view/wlXSD7
 */
float sdLink(float3 p, float height, float size, float thickness)
{
    const float3 q = float3(p.x, max(0.0, abs(p.y) - height), p.z);
    return length(float2(length(q.xy) - size, q.z)) - thickness;
}


/*!
 * @brief SDF of Infinite Cylinder.
 * @param [in] p  Position.
 * @param [in] c  xy: Center of Cylinder (XZ), z: Radius of Cylinder.
 * @return Signed Distance to the Infinite Cylinder.
 */
float sdCylinder(float3 p, float3 c)
{
    return sdCylinder(p, c.xy, c.z);
}


/*!
 * @brief SDF of Infinite Cylinder.
 * @param [in] p  Position.
 * @param [in] center  Center of Cylinder (XZ).
 * @param [in] radius  Radius of Cylinder.
 * @return Signed Distance to the Infinite Cylinder.
 */
float sdCylinder(float3 p, float2 center, float radius)
{
    return length(p.xz - center) - radius;
}


/*!
 * @brief SDF of Cone (not exact).
 * @param [in] p  Position.
 * @param [in] angle  Angle of Cone.
 * @param [in] height  Height of Cone.
 * @return Signed Distance to the Cone.
 */
float sdCone(float3 p, float angle, float height)
{
    float2 c;
    sincos(angle, c.y, c.x);
    const float q = length(p.xz);
    return max(dot(c.xy, float2(q, p.y)), -height - p.y);
}


/*!
 * @brief SDF of Cone.
 * @param [in] p  Position.
 * @param [in] angle  Angle of Cone.
 * @param [in] height  Height of Cone.
 * @return Signed Distance to the Cone.
 */
float sdConeExact(float3 p, float angle, float height)
{
    const float2 q = height * float2(tan(angle), -1.0);
    const float2 w = float2(length(p.xz), p.y);
    const float2 a = w - q * saturate(dot(w, q) / dot(q, q));
    const float2 b = w - q * float2(saturate(w.x / q.x), 1.0);
    // const float k = sign(q.y);
    const float k = q.y < 0.0 ? -1.0 : 1.0;
    const float d = min(dot(a, a), dot(b, b));

#if 1
    // Optimzied code.
    const float2 kwq = float2(w.x * q.y - w.y * q.x, w.y - q.y) * k;
    const float s = max(kwq.x, kwq.y);
#else
    // Original code.
    const float s = max(k * (w.x * q.y - w.y * q.x), k * (w.y - q.y));
#endif

    // return sqrt(d) * sign(s);
    return sqrt(d) * (s < 0.0 ? -1.0 : 1.0);
}


/*!
 * @brief SDF of Infinite Cone.
 * @param [in] p  Position.
 * @param [in] angle  Angle (in radian).
 * @return Signed Distance to the Infinite Cone.
 */
float sdCone(float3 p, float angle)
{
    float2 c;
    sincos(angle, c.x, c.y);
    const float2 q = float2(length(p.xz), -p.y);
    const float d = length(q - c * max(0.0, dot(q, c)));
    return d * ((q.x * c.y - q.y * c.x < 0.0) ? -1.0 : 1.0);
}


/*!
 * @brief SDF of Plane.
 * @param [in] p  Position.
 * @param [in] normal  Normal of plane (must be normalized).
 * @param [in] height  Height of plabe.
 * @return Signed Distance to the Plane.
 */
float sdPlane(float3 p, float3 normal, float height)
{
    return dot(p, normal) + height;
}


/*!
 * @brief Hexagonal Prism - exact
 * @param [in] p  Position.
 * @param [in] size  Size of hexagonal
 * @param [in] height  Height of Prism.
 * @return Signed Distance to the Hexagonal Prism.
 */
float sdHexPrism(float3 p, float size, float height)
{
    static const float3 k = float3(-sqrt(3.0) / 2.0, 0.5, rcp(sqrt(3.0)));

    p = abs(p);
    p.xy -= 2.0 * min(0.0, dot(k.xy, p.xy)) * k.xy;

    const float2 d = float2(
        length(p.xy - float2(clamp(p.x, -k.z * size, k.z * size), size)) * (p.y - size < 0.0 ? -1.0 : 1.0),
        p.z - height);
    return min(0.0, max(d.x, d.y)) + length(max(0.0, d));
}


/*!
 * @brief SDF of Triangular Prism.
 * @param [in] p  Position.
 * @param [in] size  Size of triangular.
 * @param [in] height  Height of Prism.
 * @return Signed Distance to the Hexagonal Prism.
 */
float sdTriPrism(float3 p, float size, float height)
{
    const float3 q = abs(p);
    return max(q.z - height, max(q.x * (sqrt(3.0) / 2.0) + p.y * 0.5, -p.y) - size * 0.5);
    // return max(q.z - height, max(dot(float2(q.x, p.y), float2((sqrt(3.0) / 2.0), 0.5)), -p.y) - size * 0.5);
}


/*!
 * @brief SDF of Arbitary Capsule.
 * @param [in] p  Position.
 * @param [in] a  Start position.
 * @param [in] b  End position.
 * @param [in] radius  Radius of Capsule.
 */
float sdCapsule(float3 p, float3 a, float3 b, float radius)
{
    const float3 pa = p - a;
    const float3 ba = b - a;
    const float h = saturate(dot(pa, ba) / dot(ba, ba));
    return length(pa - ba * h) - radius;
}


/*!
 * @brief SDF of Vertical Capsule.
 * @param [in] p  Position.
 * @param [in] height  Height of Capsule.
 * @param [in] radius  Radius of Capsule.
 */
float sdCapsule(float3 p, float height, float radius)
{
    p.y -= clamp(p.y, 0.0, height);
    return length(p) - radius;
}


/*!
 * @brief SDF of Vertical Capped Cylinder.
 * @param [in] p  Position.
 * @param [in] height  Length of cylinder.
 * @param [in] radius  Radius of cylinder.
 * @return Signed Distance to the Vertical Capped Cylinder.
 * @see https://www.shadertoy.com/view/wdXGDr
 */
float sdCappedCylinder(float3 p, float height, float radius)
{
    const float2 d = abs(float2(length(p.xz), p.y)) - float2(radius, height);
    return min(0.0, max(d.x, d.y)) + length(max(0.0, d));
}


/*!
 * @brief SDF of Arbitrary Capped Cylinder.
 * @param [in] p  Position.
 * @param [in] a  Start position.
 * @param [in] b  End position.
 * @param [in] radius  Radius of Cylinder.
 * @return Signed Distance to the Arbitrary Capped Cylinder.
 * @see https://www.shadertoy.com/view/wdXGDr
 */
float sdCappedCylinder(float3 p, float3 a, float3 b, float radius)
{
    const float3 ba = b - a;
    const float3 pa = p - a;
    const float baba = dot(ba, ba);
    const float paba = dot(pa, ba);
    const float x = length(pa * baba - ba * paba) - radius * baba;
    const float y = abs(paba - baba * 0.5) - baba * 0.5;
    const float x2 = x * x;
    const float y2 = y * y * baba;
    const float d = (max(x, y) < 0.0) ? -min(x2, y2) : ((x > 0.0 ? x2 : 0.0) + (y > 0.0 ? y2 : 0.0));
    // return sign(d) * sqrt(abs(d)) / baba;
    return (d < 0.0 ? -1.0 : 1.0) * sqrt(abs(d)) / baba;
}


/*!
 * @brief SDF of Rounded Cylinder.
 * @param [in] p  Position.
 * @param [in] height  Height of Cylinder.
 * @param [in] radius  Radius of cylinder.
 * @param [in] r  Round of Cylinder.
 * @return Signed Distance to the Cylinder.
 */
float sdRoundedCylinder(float3 p, float height, float radius, float r)
{
    const float2 d = float2(
        length(p.xz) - 2.0 * radius + r,
        abs(p.y) - height);
    return min(0.0, max(d.x, d.y)) + length(max(0.0, d)) - r;
}


/*!
 * @brief SDF of Vertical Capped Cone.
 * @param [in] p  Position.
 * @param [in] height  Height of Cone.
 * @param [in] radius1  Bottom radius.
 * @param [in] radius2  Top radius.
 * @return Signed Distance to the Capped Cone.
 */
float sdCappedCone(float3 p, float height, float radius1, float radius2)
{
    const float2 q = float2(length(p.xz), p.y);
    const float2 k1 = float2(radius2, height);
    const float2 k2 = float2(radius2 - radius1, 2.0 * height);
    const float2 ca = float2(q.x - min(q.x, (q.y < 0.0) ? radius1 : radius2), abs(q.y) - height);
    const float2 cb = q - k1 + k2 * saturate(dot(k1 - q, k2) / dot(k2, k2));
    const float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(dot(ca, ca), dot(cb, cb)));
}


/*!
 * @brief SDF of Arbitary Capped Cone.
 * @param [in] p  Position.
 * @param [in] a  Start position.
 * @param [in] b  End position.
 * @param [in] ra  Radius of start position.
 * @param [in] rb  Radius of end position.
 * @return Signed Distance to the Capped Cone.
 */
float sdCappedCone(float3 p, float3 a, float3 b, float ra, float rb)
{
    const float rba = rb - ra;
    const float baba = dot(b - a, b - a);
    const float papa = dot(p - a, p - a);
    const float paba = dot(p - a, b - a) / baba;
    const float x = sqrt(papa - paba * paba * baba);
    const float cax = max(0.0, x - ((paba < 0.5) ? ra : rb));
    const float cay = abs(paba - 0.5) - 0.5;
    const float k = rba * rba + baba;
    const float f = saturate((rba * (x - ra) + paba * baba) / k);
    const float cbx = x - ra - f * rba;
    const float cby = paba - f;
    const float s = (cbx < 0.0 && cay < 0.0) ? -1.0 : 1.0;
    // return s * sqrt(
    //     min(
    //         cax * cax + cay * cay * baba,
    //         cbx * cbx + cby * cby * baba));
    float4 cv = float4(cax, cay, cbx, cby);
    cv *= cv;
    return s * sqrt(
        min(
            cv.x + cv.y * baba,
            cv.z + cv.w * baba));
}


/*!
 * @brief SDF of Solid Angle.
 * @param [in] p  Position.
 * @param [in] angle  Angle (in radian).
 * @param [in] height  Height (Radius of Angle).
 * @return Signed Distance to the Solid Angle.
 * @see https://www.shadertoy.com/view/wtjSDW
 */
float sdSolidAngle(float3 p, float angle, float height)
{
    float2 sc;
    sincos(angle, /* out */ sc.x, /* out */ sc.y);

    const float2 q = float2(length(p.xz), p.y);
    const float l = length(q) - height;
    const float m = length(q - sc * clamp(dot(q, sc), 0.0, height));
    // return max(l, m * sign(sc.y * q.x - sc.x * q.y));
    return max(l, m * (sc.y * q.x - sc.x * q.y < 0.0 ? -1.0 : 1.0));
}


/*!
 * @brief SDF of Cut Sphere.
 * @param [in] p  Position.
 * @param [in] radius  Radius of Sphere.
 * @param [in] cutHeight  Cut height of Sphere.
 * @return Signed Distance to the Cut Sphere.
 * @see https://www.shadertoy.com/view/stKSzc
 */
float sdCutSphere(float3 p, float radius, float cutHeight)
{
    // sampling independent computations (only depend on shape)
    const float w = sqrt(radius * radius - cutHeight * cutHeight);

    // sampling dependant computations
    const float2 q = float2(length(p.xz), p.y);
    const float s = max(
        (cutHeight - radius) * q.x * q.x + w * w * (cutHeight + radius - 2.0 * q.y),
        // (cutHeight - radius) * (q.x * q.x) + (w * w * (cutHeight + radius - 2.0 * q.y)),
        cutHeight * q.x - w * q.y);
    return (s < 0.0) ? length(q) - radius
        : (q.x < w) ? cutHeight - q.y
        : length(q - float2(w, cutHeight));
}


/*!
 * @brief SDF of Cut Hollow Sphere.
 * @param [in] p  Position.
 * @param [in] radius  Radius of Sphere.
 * @param [in] height  Height of Half Sphere.
 * @param [in] thickness  Thickness of Sphere.
 * @return Signed Distance to the Cut Sphere.
 * @see https://www.shadertoy.com/view/7tVXRt
 */
float sdCutHollowSphere(float3 p, float radius, float height, float thickness)
{
    // sampling independent computations (only depend on shape)
    const float w = sqrt(radius * radius - height * height);

    // sampling dependant computations
    const float2 q = float2(length(p.xz), p.y);
    return ((height * q.x < w * q.y) ? length(q - float2(w, height)) : abs(length(q) - radius)) - thickness;
}


/*!
 * @brief SDF of Vertical Round Cone.
 * @param [in] p  Position.
 * @param [in] height  Height of Cone.
 * @param [in] radius1  Bottom radius.
 * @param [in] radius2  Top radius.
 * @return Signed Distance to the Capped Cone.
 */
float sdRoundCone(float3 p, float height, float radius1, float radius2)
{
    // sampling independent computations (only depend on shape)
    const float b = (radius1 - radius2) / height;
    const float a = sqrt(1.0 - b * b);

    // sampling dependant computations
    const float2 q = float2(length(p.xz), p.y);
    const float k = dot(q, float2(-b, a));

    return k < 0.0 ? length(q) - radius1
        : k > a * height ? length(q - float2(0.0, height)) - radius2
        : dot(q, float2(a, b)) - radius1;
}


/*!
 * @brief SDF of Arbitary Round Cone.
 * @param [in] p  Position.
 * @param [in] a  Start position.
 * @param [in] b  End position.
 * @param [in] ra  Radius of start position.
 * @param [in] rb  Radius of end position.
 * @return Signed Distance to the Capped Cone.
 * @see https://www.shadertoy.com/view/tdXGWr
 */
float sdRoundCone(float3 p, float3 a, float3 b, float ra, float rb)
{
    // sampling independent computations (only depend on shape)
    const float3 ba = b - a;
    const float l2 = dot(ba, ba);
    const float rr = ra - rb;
    const float a2 = l2 - rr * rr;
    const float il2 = 1.0 / l2;

    // sampling dependant computations
    const float3 pa = p - a;
    const float y = dot(pa, ba);
    const float z = y - l2;
    const float3 x = pa * l2 - ba * y;
    const float x2 = dot(x, x);
    const float y2 = y * y * l2;
    const float z2 = z * z * l2;

    // single square root!
    const float k = (rr < 0.0 ? -1.0 : 1.0) * rr * rr * x2;
    return (z < 0.0 ? -1.0 : 1.0) * a2 * z2 > k ? sqrt(x2 + z2) * il2 - rb
        : (y < 0.0 ? -1.0 : 1.0) * a2 * y2 < k ? sqrt(x2 + y2) * il2 - ra
        : (sqrt(x2 * a2 * il2) + y * rr) * il2 - ra;
}


/*!
 * @brief SDF of Ellipsoid.
 * @param [in] p  Position.
 * @param [in] radiuses  Radiuses of Ellipsoid.
 * @return Signed Distance to the Ellipsoid.
 * @see https://www.shadertoy.com/view/tdS3DG
 */
float sdEllipsoid(float3 p, float3 radiuses)
{
    // Optimized code.
    const float3 rcpR = rcp(radiuses);
    const float3 pdr = p * rcpR;
    const float k0 = length(pdr);
    const float3 pdr2 = pdr * rcpR;
    const float rcpK1 = rsqrt(dot(pdr2, pdr2));
    return (k0 * k0 - k0) * rcpK1;

    // Following code is original by Inigo Quilez.
    // const float k0 = length(p / radiuses);
    // const float k1 = length(p / (radiuses * radiuses));
    // return k0 * (k0 - 1.0) / k1;
}


/*!
 * @brief SDF of Revolved Vesica.
 * @param [in] p  Position.
 * @param [in] a  Start position.
 * @param [in] b  End position.
 * @param [in] width  Width of Vesica.
 * @return Signed Distance to the Revolved Vesica.
 * @see https://www.shadertoy.com/view/Ds2czG.
 */
float sdVesicaSegment(float3 p, float3 a, float3 b, float width)
{
    const float3 c = (a + b) * 0.5;
    const float l = length(b - a);
    const float3 v = (b - a) / l;
    const float y = dot(p - c, v);
    const float2 q = float2(length(p - c - y * v), abs(y));

    const float r = 0.5 * l;
    const float d = 0.5 * (r * r - width * width) / width;
    const float3 h = (r * q.x < d * (q.y - r)) ? float3(0.0, r, 0.0) : float3(-d, 0.0, d + width);

    return length(q - h.xy) - h.z;
}


/*!
 * @brief SDF of Rhombus.
 * @param [in] p  Position.
 * @param [in] xSize  Size in X-axis direction.
 * @param [in] zSize  Length in Z-axis direction.
 * @param [in] height  Height of Rhombus.
 * @param [in] r  Round of Rhombus.
 * @return Signed Distance to the Rhombus.
 * @see https://www.shadertoy.com/view/tlVGDc
 */
float sdRhombus(float3 p, float xSize, float zSize, float height, float r)
{
    return sdRhombus(p, float2(xSize, zSize), height, r);
}


/*!
 * @brief SDF of Rhombus.
 * @param [in] p  Position.
 * @param [in] xzSize  Length in (X-axis, Z-axis) direction.
 * @param [in] height  Height of Rhombus.
 * @param [in] r  Round of Rhombus.
 * @return Signed Distance to the Rhombus.
 * @see https://www.shadertoy.com/view/tlVGDc
 */
float sdRhombus(float3 p, float2 xzSize, float height, float r)
{
    p = abs(p);
    const float2 c = xzSize - 2.0 * p.xz;
    // const float f = clamp((ndot(xzSize, c)) / dot(xzSize, xzSize), -1.0, 1.0);
    const float f = clamp((xzSize.x * c.x - xzSize.y * c.y) / dot(xzSize, xzSize), -1.0, 1.0);
    const float2 q = float2(
        // length(p.xz - 0.5 * xzSize * float2(1.0 - f, 1.0 + f)) * sign(p.x * xzSize.y + p.z * xzSize.x - xzSize.x * xzSize.y) - r,
        length(p.xz - 0.5 * xzSize * float2(1.0 - f, 1.0 + f)) * (dot(float3(p.xz, -xzSize.x), xzSize.yxy) < 0.0 ? -1.0 : 1.0) - r,
        p.y - height);
    return min(0.0, max(q.x, q.y)) + length(max(0.0, q));
}


/*!
 * @brief SDF of Octahedron (not exact).
 * @param [in] p  Position.
 * @param [in] s  Size of Octahedron.
 * @return Signed Distance to the Octahedron.
 * @see https://www.shadertoy.com/view/wsSGDG
 */
float sdOctahedronExact(float3 p, float s)
{
    return sdOctahedronExact(p, s, (1.0).xxx);
}


/*!
 * @brief SDF of Octahedron (not exact).
 * @param [in] p  Position.
 * @param [in] s  Size of Octahedron.
 * @param [in] scales  Scales of Octahedron.
 * @return Signed Distance to the Octahedron.
 */
float sdOctahedronExact(float3 p, float s, float3 scales)
{
    p = abs(p);
    // const float m = p.x + p.y + p.z - s;
    const float m = dot(p, scales) - s;

    // float3 q;
    // if (3.0 * p.x < m) {
    //     q = p.xyz;
    // } else if (3.0 * p.y < m) {
    //     q = p.yzx;
    // } else if (3.0 * p.z < m) {
    //     q = p.zxy;
    // } else {
    //     return m * rcp(sqrt(3.0));
    // }
    const bool3 selector = 3.0 * p < m.xxx;
    float3 q;
    if (selector.x) {
        q = p.xyz;
    } else if (selector.y) {
        q = p.yzx;
    } else if (selector.z) {
        q = p.zxy;
    } else {
        return m * rcp(sqrt(3.0));
    }

    const float k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
    return length(float3(q.x, q.y - s + k, q.z - k));
}


/*!
 * @brief SDF of Octahedron (not exact).
 * @param [in] p  Position.
 * @param [in] s  Size of Octahedron.
 * @return Signed Distance to the Octahedron.
 */
float sdOctahedron(float3 p, float s)
{
    return sdOctahedron(p, s, (1.0).xxx);
}


/*!
 * @brief SDF of Octahedron.
 * @param [in] p  Position.
 * @param [in] s  Size of Octahedron.
 * @param [in] scales  Scales of Octahedron.
 * @return Signed Distance to the Octahedron.
 */
float sdOctahedron(float3 p, float s, float3 scales)
{
    static const float kNormalizeTerm = rcp(sqrt(3.0));
    return (dot(abs(p), scales) - s) * kNormalizeTerm;
}


/*!
 * @brief SDF of Pyramid.
 * @param [in] p  Position.
 * @param [in] height  Height of Pyramid.
 * @return Signed Distance to the Pyramid.
 * @see https://www.shadertoy.com/view/Ws3SDl
 */
float sdPyramid(float3 p, float height)
{
    const float m2 = height * height + 0.25;

    p.xz = abs(p.xz);
    p.xz = (p.z > p.x) ? p.zx : p.xz;
    p.xz -= (0.5).xx;

    const float3 q = float3(
        p.z,
        height * p.y - 0.5 * p.x,
        height * p.x + 0.5 * p.y);
    // const float3 h3 = float3(height, 0.5, -0.5);
    // const float3 q = float3(p.z, dot(p.yx, h3.xz), dot(p.xy, h3.xy));

    const float s = max(0.0, -q.x);
    const float t = saturate((q.y - 0.5 * p.z) / (m2 + 0.25));

    // const float a = m2 * (q.x + s) * (q.x + s) + q.y * q.y;
    const float a = m2 * pow(q.x + s, 2.0) + pow(q.y, 2.0);

    // const float b = m2 * (q.x + 0.5 * t) * (q.x + 0.5 * t) + (q.y - m2 * t) * (q.y - m2 * t);
    const float b = m2 * pow(q.x + 0.5 * t, 2.0) + pow(q.y - m2 * t, 2.0);

    const float d2 = min(q.y, -q.x * m2 - q.y * 0.5) > 0.0 ? 0.0 : min(a, b);
    // const float d2 = min(q.y, -dot(float2(m2, 0.5), q.xy)) > 0.0 ? 0.0 : min(a, b);

    // return sqrt((d2 + q.z * q.z) / m2) * sign(max(q.z, -p.y));
    return sqrt((d2 + q.z * q.z) / m2) * (max(q.z, -p.y) < 0.0 ? -1.0 : 1.0);
}


#endif  // !defined(SDF_INCLUDED)
