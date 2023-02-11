using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching
{
    /// <summary>
    /// Cube Mesh Creator.
    /// </summary>
    public static class CubeMeshCreator
    {
        /// <summary>
        /// Apply mesh to the <<see cref="GameObject"/>.
        /// </summary>
        /// <param name="go">Target <<see cref="GameObject"/>.</param>
        /// <param name="mesh">A mesh to set.</param>
        public static void ApplyMesh(GameObject go, Mesh mesh)
        {
            // Add MeshFilter if not exists.
            var meshFilter = go.GetComponent<MeshFilter>();
            if (meshFilter == null)
            {
                meshFilter = go.AddComponent<MeshFilter>();
            }
            meshFilter.sharedMesh = mesh;

            // Add MeshRenderer if not exists.
            if (go.GetComponent<MeshRenderer>() == null)
            {
                var meshRenderer = go.AddComponent<MeshRenderer>();
                meshRenderer.sharedMaterial = AssetDatabase.GetBuiltinExtraResource<Material>("Default-Material.mat");
            }
        }

        /// <summary>
        /// Resize box collider of the <<see cref="GameObject"/>.
        /// </summary>
        /// <param name="go">Target <<see cref="GameObject"/>.</param>
        /// <param name="size">New size of box collider.</param>
        public static void ResizeBoxCollider(GameObject go, Vector3 size)
        {
            // Resize box collider if exists.
            var boxCollider = go.GetComponent<BoxCollider>();
            if (boxCollider != null)
            {
                boxCollider.size = size;
            }
        }

        /// <summary>
        /// <para>Create cube mesh with 8 vertices, 12 polygons (triangles) and no UV coordinates.</para>
        /// <para>UVs and normals of created Cube are incorrect.</para>
        /// </summary>
        /// <param name="size">Size of cube.</param>
        /// <param name="hasUV">A flag whether adding UV coordinate to mesh or not.</param>
        /// <param name="hasNormal">A flag whether adding Normal coordinate to mesh or not.</param>
        /// <param name="hasTangent">A flag whether adding Tangent coordinate to mesh or not.</param>
        /// <param name="hasVertexColor">A flag whether adding color to mesh or not.</param>
        public static Mesh CreateCubeMeshLow(Vector3 size, bool hasUV = false, bool hasNormal = false, bool hasTangent = false, bool hasVertexColor = false)
        {
            var p = size * 0.5f;

            var mesh = new Mesh();

            //      4:(-++)   5:(+++)
            //
            //  3:(-+-)   2:(++-)
            //
            //      7:(--+)   6:(+-+)
            //
            //  0:(---)   1:(+--)
            var vertices = new []
            {
                new Vector3(-p.x, -p.y, -p.z),
                new Vector3(p.x, -p.y, -p.z),
                new Vector3(p.x, p.y, -p.z),
                new Vector3(-p.x, p.y, -p.z),
                new Vector3(-p.x, p.y, p.z),
                new Vector3(p.x, p.y, p.z),
                new Vector3(p.x, -p.y, p.z),
                new Vector3(-p.x, -p.y, p.z)
            };
            mesh.SetVertices(vertices);

            mesh.SetTriangles(new []
            {
                // Face front
                0, 2, 1,
                0, 3, 2,
                // Face top
                2, 3, 4,
                2, 4, 5,
                // Face right
                1, 2, 5,
                1, 5, 6,
                // Face left
                0, 7, 4,
                0, 4, 3,
                // Face back
                5, 4, 7,
                5, 7, 6,
                // Face bottom
                0, 6, 7,
                0, 1, 6
            }, 0);

            if (hasUV)
            {
                //          4:(1,1)           5:(0,1)
                //
                //
                //
                // 3:(0,1)          2:(1,1)
                //
                //           7:(1,0)          6:(0,0)
                //
                //
                //
                // 0:(0,0)          1:(1,0)
                mesh.SetUVs(0, new []
                {
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f)
                });
            }

            if (hasVertexColor)
            {
                mesh.SetColors(CreateColorsFromVertices(vertices, Rcp(p)));
            }

            mesh.Optimize();
            mesh.RecalculateBounds();
            if (hasNormal)
            {
                mesh.RecalculateNormals();
            }
            if (hasTangent)
            {
                mesh.RecalculateTangents();
            }

            return mesh;
        }

        /// <summary>
        /// Create cube mesh with 12 vertices, 12 polygons (triangles) and UV coordinates.
        /// </summary>
        /// <param name="size">Size of cube.</param>
        /// <param name="hasUV">A flag whether adding UV coordinate to mesh or not.</param>
        /// <param name="hasNormal">A flag whether adding Normal coordinate to mesh or not.</param>
        /// <param name="hasTangent">A flag whether adding Tangent coordinate to mesh or not.</param>
        /// <param name="hasVertexColor">A flag whether adding color to mesh or not.</param>
        public static Mesh CreateCubeMeshMiddle(Vector3 size, bool hasUV = false, bool hasNormal = false, bool hasTangent = false, bool hasVertexColor = false)
        {
            var mesh = new Mesh();
            var p = size * 0.5f;

            //      4/8:(-++)  5/9:(+++)
            //
            //  3:(-+-)    2:(++-)
            //
            //      7/11:(--+) 6/10:(+-+)
            //
            //  0:(---)    1:(+--)
            var vertices = new []
            {
                // front
                new Vector3(-p.x, -p.y, -p.z),
                new Vector3(p.x, -p.y, -p.z),
                new Vector3(p.x, p.y, -p.z),
                new Vector3(-p.x, p.y, -p.z),
                // back
                new Vector3(-p.x, p.y, p.z),
                new Vector3(p.x, p.y, p.z),
                new Vector3(p.x, -p.y, p.z),
                new Vector3(-p.x, -p.y, p.z),
                // Same as 4 ~ 7, but for UVs for top and bottom.
                new Vector3(-p.x, p.y, p.z),
                new Vector3(p.x, p.y, p.z),
                new Vector3(p.x, -p.y, p.z),
                new Vector3(-p.x, -p.y, p.z),
            };
            mesh.SetVertices(vertices);

            mesh.SetTriangles(new []
            {
                // Face front
                0, 2, 1,
                0, 3, 2,
                // Face top
                2, 3, 8,
                2, 8, 9,
                // Face right
                1, 2, 5,
                1, 5, 6,
                // Face left
                0, 7, 4,
                0, 4, 3,
                // Face back
                5, 4, 7,
                5, 7, 6,
                // Face bottom
                0, 10, 11,
                0, 1, 10
            }, 0);

            if (hasUV)
            {
                //          4:(1,1)           5:(0,1)
                //          8:(0,0)           9:(1,0)
                //
                //
                // 3:(0,1)          2:(1,1)
                //
                //           7:(1,0)          6:(0,0)
                //          11:(0,1)         10:(1,1)
                //
                //
                // 0:(0,0)          1:(1,0)
                mesh.SetUVs(0, new []
                {
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f)
                });
            }

            if (hasVertexColor)
            {
                mesh.SetColors(CreateColorsFromVertices(vertices, Rcp(p)));
            }

            mesh.Optimize();
            mesh.RecalculateBounds();
            if (hasNormal)
            {
                mesh.RecalculateNormals();
            }
            if (hasTangent)
            {
                mesh.RecalculateTangents();
            }

            return mesh;
        }

        /// <summary>
        /// <para>Create cube mesh with 24 vertices, 12 polygons (triangles) and no UV coordinates,
        /// which is same as the cube of Unity Primitives.</para>
        /// <para>UVs and normals of created Cube are correct.</para>
        /// /// </summary>
        /// <param name="size">Size of cube.</param>
        /// <param name="hasUV">A flag whether adding UV coordinate to mesh or not.</param>
        /// <param name="hasNormal">A flag whether adding Normal coordinate to mesh or not.</param>
        /// <param name="hasTangent">A flag whether adding Tangent coordinate to mesh or not.</param>
        /// <param name="hasVertexColor">A flag whether adding color to mesh or not.</param>
        public static Mesh CreateCubeMeshHigh(Vector3 size, bool hasUV = false, bool hasNormal = false, bool hasTangent = false, bool hasVertexColor = false)
        {
            var mesh = new Mesh();
            var p = size * 0.5f;

            //            3:(-++)          2:(+++)
            //            9                8
            //           17               22
            //
            //  5:(-+-)          4:(++-)
            // 11               10
            // 18               21
            //            1:(--+)          0:(+-+)
            //           14               13
            //           16               23
            //
            //  7:(---)          6:(+--)
            // 15               12
            // 19               20
            var vertices = new []
            {
                // Face back
                new Vector3(p.x, -p.y, p.z),
                new Vector3(-p.x, -p.y, p.z),
                new Vector3(p.x, p.y, p.z),
                new Vector3(-p.x, p.y, p.z),
                // Face front
                new Vector3(p.x, p.y, -p.z),
                new Vector3(-p.x, p.y, -p.z),
                new Vector3(p.x, -p.y, -p.z),
                new Vector3(-p.x, -p.y, -p.z),
                // Face top
                new Vector3(p.x, p.y, p.z),
                new Vector3(-p.x, p.y, p.z),
                new Vector3(p.x, p.y, -p.z),
                new Vector3(-p.x, p.y, -p.z),
                // Face bottom
                new Vector3(p.x, -p.y, -p.z),
                new Vector3(p.x, -p.y, p.z),
                new Vector3(-p.x, -p.y, p.z),
                new Vector3(-p.x, -p.y, -p.z),
                // Face left
                new Vector3(-p.x, -p.y, p.z),
                new Vector3(-p.x, p.y, p.z),
                new Vector3(-p.x, p.y, -p.z),
                new Vector3(-p.x, -p.y, -p.z),
                // Face right
                new Vector3(p.x, -p.y, -p.z),
                new Vector3(p.x, p.y, -p.z),
                new Vector3(p.x, p.y, p.z),
                new Vector3(p.x, -p.y, p.z)
            };
            mesh.SetVertices(vertices);

            mesh.SetTriangles(new []
            {
                // Face front
                0, 2, 1,
                0, 3, 2,
                // Face top
                4, 5, 6,
                4, 6, 7,
                // Face right
                8, 9, 10,
                8, 10, 11,
                // Face left
                12, 15, 14,
                12, 14, 13,
                // Face back
                17, 16, 19,
                17, 19, 18,
                // Face bottom
                20, 22, 23,
                20, 21, 22
            }, 0);

            if (hasUV)
            {
                mesh.SetUVs(0, new []
                {
                    // front (0 ~ 3)
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    // top (4 ~ 7)
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    // right (8 ~ 11)
                    new Vector2(1.0f, 0.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(0.0f, 0.0f),
                    // left (12 ~ 15)
                    new Vector2(0.0f, 0.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(1.0f, 0.0f),
                    // back (16 ~ 19)
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f),
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    // bottom (20 ~ 23)
                    new Vector2(0.0f, 0.0f),
                    new Vector2(1.0f, 0.0f),
                    new Vector2(1.0f, 1.0f),
                    new Vector2(0.0f, 1.0f)
                });
            }

            if (hasVertexColor)
            {
                mesh.SetColors(CreateColorsFromVertices(vertices, Rcp(p)));
            }

            mesh.Optimize();
            mesh.RecalculateBounds();
            if (hasNormal)
            {
                mesh.RecalculateNormals();
            }
            if (hasTangent)
            {
                mesh.RecalculateTangents();
            }

            return mesh;
        }

        /// <summary>
        /// Convert vertex coordinates to RGB colors.
        /// </summary>
        /// <param name="vertices">Vertex coordinates.</param>
        /// <param name="sNormTerms">Normalize term to convert vertex coordinates to [-1.0f, 1.0f].</param>
        /// <returns><see cref="Color"/> array created from <paramref name="vertices"/>.</returns>
        private static Color[] CreateColorsFromVertices(Vector3[] vertices, Vector3 sNormTerms)
        {
            var colors = new Color[vertices.Length];
            for (int i = 0; i < colors.Length; i++)
            {
                var q = (Mul(vertices[i], sNormTerms) + Vector3.one) * 0.5f;
                colors[i] = new Color(q.x, q.y, q.z);
            }

            return colors;
        }

        /// <summary>
        /// Calculate reciprocal vector.
        /// </summary>
        /// <param name="v">Source vector.</param>
        /// <returns>Reciprocal vector of <paramref name="v"/>.</returns>
        private static Vector3 Rcp(Vector3 v)
        {
            return new Vector3(1.0f / v.x, 1.0f / v.y, 1.0f / v.z);
        }

        /// <summary>
        /// Calculate Hadamard product of two vectors.
        /// </summary>
        /// <param name="a">First <see cref="Vector3"/>.</param>
        /// <param name="b">Second <see cref="Vector3"/>.</param>
        /// <returns>Hadamard product of <paramref name="a"/> and <see cref="b"/>.</returns>
        private static Vector3 Mul(Vector3 a, Vector3 b)
        {
            return new Vector3(a.x * b.x, a.y * b.y, a.z * b.z);
        }
    }
}
