using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
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
        /// <returns>Created cube Mesh.</returns>
        public static Mesh CreateCubeMeshLow(Vector3 size, bool hasUV = false, bool hasNormal = false, bool hasTangent = false, bool hasVertexColor = false)
        {
            var mesh = new Mesh();

            //      3:(-++)   2:(+++)
            //
            //  5:(-+-)   4:(++-)
            //
            //      1:(--+)   0:(+-+)
            //
            //  7:(---)   6:(+--)
            var vertexData = new[]
            {
                1.0f, -1.0f, 1.0f,
                -1.0f, -1.0f, 1.0f,
                1.0f, 1.0f, 1.0f,
                -1.0f, 1.0f, 1.0f,
                1.0f, 1.0f, -1.0f,
                -1.0f, 1.0f, -1.0f,
                1.0f, -1.0f, -1.0f,
                -1.0f, -1.0f, -1.0f
            };
            mesh.SetVertices(ScaleVectorArray(ConvertArray<Vector3>(vertexData), size * 0.5f));

            mesh.SetTriangles(new []
            {
                // face back
                0, 2, 3,
                0, 3, 1,
                // face top
                2, 4, 5,
                2, 5, 3,
                // face front
                4, 6, 7,
                4, 7, 5,
                // face bottom
                6, 0, 1,
                6, 1, 7,
                // face left
                1, 3, 5,
                1, 5, 7,
                // face right
                6, 4, 2,
                6, 2, 0
            }, 0);

            if (hasUV)
            {
                //           3:(1,1)          2:(0,1)
                //
                //
                //
                // 5:(0,1)          4:(1,1)
                //
                //           1:(1,0)          0:(0,0)
                //
                //
                //
                // 7:(0,0)          6:(1,0)
                mesh.SetUVs(0, ConvertArray<Vector2>(new []
                {
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    1.0f, 1.0f,
                    0.0f, 1.0f,
                    1.0f, 0.0f,
                    0.0f, 0.0f
                }));
            }

            if (hasVertexColor)
            {
                mesh.SetColors(CreateColorsFromVertexData(vertexData));
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
        /// <returns>Created cube Mesh.</returns>
        public static Mesh CreateCubeMeshMiddle(Vector3 size, bool hasUV = false, bool hasNormal = false, bool hasTangent = false, bool hasVertexColor = false)
        {
            var mesh = new Mesh();
            //      4/8:(-++)  5/9:(+++)
            //
            //  3:(-+-)    2:(++-)
            //
            //      7/11:(--+) 6/10:(+-+)
            //
            //  0:(---)    1:(+--)
            var vertexData = new[]
            {
                // front
                -1.0f, -1.0f, -1.0f,
                1.0f, -1.0f, -1.0f,
                1.0f, 1.0f, -1.0f,
                -1.0f, 1.0f, -1.0f,
                // back
                -1.0f, 1.0f, 1.0f,
                1.0f, 1.0f, 1.0f,
                1.0f, -1.0f, 1.0f,
                -1.0f, -1.0f, 1.0f,
                // Same as 4 ~ 7, but for UVs for top and bottom.
                -1.0f, 1.0f, 1.0f,
                1.0f, 1.0f, 1.0f,
                1.0f, -1.0f, 1.0f,
                -1.0f, -1.0f, 1.0f
            };
            mesh.SetVertices(ScaleVectorArray(ConvertArray<Vector3>(vertexData), size * 0.5f));

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
                mesh.SetUVs(0, ConvertArray<Vector2>(new []
                {
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    1.0f, 1.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    0.0f, 1.0f,
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    1.0f, 1.0f,
                    0.0f, 1.0f
                }));
            }

            if (hasVertexColor)
            {
                mesh.SetColors(CreateColorsFromVertexData(vertexData));
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
            var vertexData = new []
            {
                // Face back
                1.0f, -1.0f, 1.0f,
                -1.0f, -1.0f, 1.0f,
                1.0f, 1.0f, 1.0f,
                -1.0f, 1.0f, 1.0f,
                // Face front
                1.0f, 1.0f, -1.0f,
                -1.0f, 1.0f, -1.0f,
                1.0f, -1.0f, -1.0f,
                -1.0f, -1.0f, -1.0f,
                // Face top
                1.0f, 1.0f, 1.0f,
                -1.0f, 1.0f, 1.0f,
                1.0f, 1.0f, -1.0f,
                -1.0f, 1.0f, -1.0f,
                // Face bottom
                1.0f, -1.0f, -1.0f,
                1.0f, -1.0f, 1.0f,
                -1.0f, -1.0f, 1.0f,
                -1.0f, -1.0f, -1.0f,
                // Face left
                -1.0f, -1.0f, 1.0f,
                -1.0f, 1.0f, 1.0f,
                -1.0f, 1.0f, -1.0f,
                -1.0f, -1.0f, -1.0f,
                // Face right
                1.0f, -1.0f, -1.0f,
                1.0f, 1.0f, -1.0f,
                1.0f, 1.0f, 1.0f,
                1.0f, -1.0f, 1.0f
            };
            mesh.SetVertices(ScaleVectorArray(ConvertArray<Vector3>(vertexData), size * 0.5f));

            mesh.SetTriangles(new []
            {
                // Face back
                0, 2, 3,
                0, 3, 1,
                // Face top
                8, 4, 5,
                8, 5, 9,
                // Face front
                10, 6, 7,
                10, 7, 11,
                // Face bottom
                12, 13, 14,
                12, 14, 15,
                // Face left
                16, 17, 18,
                16, 18, 19,
                // Face right
                20, 21, 22,
                20, 22, 23,
            }, 0);

            if (hasUV)
            {
                //            3:(1,1)          2:(0,1)
                //            9:(1,0)          8:(0,0)
                //           17:(0,0)         22:(1,1)
                //
                //  5:(1,1)          4:(0,1)
                // 11:(1,0)         10:(0,0)
                // 18:(0,1)         21:(0,1)
                //            1:(1,0)          0:(0,0)
                //           14:(1,1)         13:(0,1)
                //           16:(1,1)         23:(1,0)
                //
                //  7:(1,1)          6:(0,1)
                // 15:(1,0)         12:(0,0)
                // 19:(1,1)         20:(0,0)
                mesh.SetUVs(0, ConvertArray<Vector2>(new []
                {
                    // Face back
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    // Face front
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    // Face top
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    // Face bottom
                    0.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    1.0f, 0.0f,
                    // Face left
                    0.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    1.0f, 0.0f,
                    // Face right
                    0.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    1.0f, 0.0f
                }));
            }

            if (hasVertexColor)
            {
                mesh.SetColors(CreateColorsFromVertexData(vertexData));
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
        /// Adapt scale vector to all array elements.
        /// </summary>
        /// <param name="data">Target vector array.</param>
        /// <param name="scale">Scale vector.</param>
        /// <returns><paramref name="data"/> (but overwrote by the scaled results).</returns>
        private static Vector3[] ScaleVectorArray(Vector3[] data, Vector3 scale)
        {
            for (int i = 0; i < data.Length; i++)
            {
                data[i].Scale(scale);
            }
            return data;
        }

        /// <summary>
        /// Convert <see cref="float"/> array to desired type array.
        /// </summary>
        /// <typeparam name="T">Blittable type.</typeparam>
        /// <param name="srcArray">Source <see cref="float"/> array.</param>
        /// <returns>Converted array.</returns>
        private static T[] ConvertArray<T>(float[] srcArray)
            where T : struct
        {
            var dstArray = new T[srcArray.Length / (Marshal.SizeOf<T>() / sizeof(float))];
            var gch = GCHandle.Alloc(dstArray, GCHandleType.Pinned);
            try
            {
                Marshal.Copy(srcArray, 0, gch.AddrOfPinnedObject(), srcArray.Length);
            }
            finally
            {
                gch.Free();
            }

            return dstArray;
        }

        /// <summary>
        /// Convert vertex coordinates to RGB colors.
        /// </summary>
        /// <param name="vertexData">Vertex coordinates.</param>
        /// <returns><see cref="Color"/> array created from <paramref name="vertexData"/>.</returns>
        private static Color[] CreateColorsFromVertexData(float[] vertexData)
        {
            var colors = new Color[vertexData.Length / 3];
            for (int i = 0; i < colors.Length; i++)
            {
                var j = i * 3;
                colors[i] = new Color(
                    vertexData[j] * 0.5f + 0.5f,
                    vertexData[j + 1] * 0.5f + 0.5f,
                    vertexData[j + 2] * 0.5f + 0.5f);
            }

            return colors;
        }
    }
}
