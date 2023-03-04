using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching
{
    /// <summary>
    /// Quad Mesh Creator.
    /// </summary>
    public static class QuadMeshCreator
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
        /// <para>UVs and normals of created Quad are incorrect.</para>
        /// </summary>
        /// <param name="size">Size of cube.</param>
        /// <param name="hasUV">A flag whether adding UV coordinate to mesh or not.</param>
        /// <param name="hasNormal">A flag whether adding Normal coordinate to mesh or not.</param>
        /// <param name="hasTangent">A flag whether adding Tangent coordinate to mesh or not.</param>
        /// <param name="hasVertexColor">A flag whether adding color to mesh or not.</param>
        /// <returns>Created cube Mesh.</returns>
        public static Mesh CreateQuadMesh(Vector2 size, bool hasUV = false, bool hasNormal = false, bool hasTangent = false, bool hasVertexColor = false)
        {
            var mesh = new Mesh();

            // 2:(-+-)  3:(++-)
            //
            //
            // 0:(---)  1:(+--)
            var vertexData = new[]
            {
                -1.0f, -1.0f, 0.0f,
                1.0f, -1.0f, 0.0f,
                -1.0f, 1.0f, 0.0f,
                1.0f, 1.0f, 0.0f
            };
            mesh.SetVertices(ScaleVectorArray(ConvertArray<Vector3>(vertexData), size * 0.5f));

            mesh.SetTriangles(new []
            {
                0, 3, 1,
                3, 0, 2
            }, 0);

            if (hasUV)
            {
                // 3:(0,1)  4:(1,1)
                //
                //
                // 1:(0,0)  2:(1,0)
                mesh.SetUVs(0, ConvertArray<Vector2>(new []
                {
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f
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
        /// <para>Create cube mesh with 8 vertices, 12 polygons (triangles) and no UV coordinates.</para>
        /// <para>UVs and normals of created Quad are incorrect.</para>
        /// </summary>
        /// <param name="size">Size of cube.</param>
        /// <param name="hasUV">A flag whether adding UV coordinate to mesh or not.</param>
        /// <param name="hasNormal">A flag whether adding Normal coordinate to mesh or not.</param>
        /// <param name="hasTangent">A flag whether adding Tangent coordinate to mesh or not.</param>
        /// <param name="hasVertexColor">A flag whether adding color to mesh or not.</param>
        /// <returns>Created cube Mesh.</returns>
        public static Mesh CreateQuadMeshDoubleSide(Vector2 size, bool hasUV = false, bool hasNormal = false, bool hasTangent = false, bool hasVertexColor = false, bool isPreventZFighting = true)
        {
            float eps = isPreventZFighting ? 1.0e-5f : 0.0f;
            var mesh = new Mesh();

            // 2:(-+0)  3:(++0)
            // 7:(-+0)  6:(++0)
            //
            //
            // 0:(--0)  1:(+-0)
            // 5:(--0)  4:(+-0)
            var vertexData = new[]
            {
                // face front
                -1.0f, -1.0f, -eps,
                1.0f, -1.0f, -eps,
                -1.0f, 1.0f, -eps,
                1.0f, 1.0f, -eps,
                // face back
                1.0f, -1.0f, eps,
                -1.0f, -1.0f, eps,
                1.0f, 1.0f, eps,
                -1.0f, 1.0f, eps
            };
            mesh.SetVertices(ScaleVectorArray(ConvertArray<Vector3>(vertexData), size * 0.5f));

            mesh.SetTriangles(new []
            {
                // face front
                0, 3, 1,
                3, 0, 2,
                // face back
                4, 7, 5,
                7, 4, 6
            }, 0);

            if (hasUV)
            {
                // 2:(0,1)  3:(1,1)
                // 7:(1,1)  6:(0,1)
                //
                //
                // 0:(0,0)  1:(1,0)
                // 5:(1,0)  4:(0,0)
                mesh.SetUVs(0, ConvertArray<Vector2>(new []
                {
                    // face front
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f,
                    // face back
                    0.0f, 0.0f,
                    1.0f, 0.0f,
                    0.0f, 1.0f,
                    1.0f, 1.0f
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
        private static Vector3[] ScaleVectorArray(Vector3[] data, Vector2 scale)
        {
            var scale3d = new Vector3(scale.x, scale.y, 1.0f);
            for (int i = 0; i < data.Length; i++)
            {
                data[i].Scale(scale3d);
            }
            return data;
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
