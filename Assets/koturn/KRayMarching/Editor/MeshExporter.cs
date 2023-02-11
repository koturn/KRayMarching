using UnityEngine;
using UnityEngine.Rendering;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;


namespace Koturn.KRayMarching
{
    /// <summary>
    /// Mesh Exporter.
    /// </summary>
    public static class MeshExporter
    {
        /// <summary>
        /// Write mesh information as a CSV file.
        /// </summary>
        /// <param name="mesh">Target mesh.</param>
        /// <param name="filePath">A file path to write.</param>
        public static void WriteMeshInfo(Mesh mesh, string filePath)
        {
            using (var fs = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.Read))
            using (var sw = new StreamWriter(fs))
            {
                WriteVectorItem(sw, "Vertices", mesh.vertices);
                WriteTriangleItem(sw, "Triangles", mesh.triangles);
                WriteVectorItem(sw, "Normals", mesh.normals);
                WriteVectorItem(sw, "Tangents", mesh.tangents);
                WriteColorItem(sw, "Colors", mesh.colors);
                WriteVectorItem(sw, "UVs", mesh.uv);
                WriteVectorItem(sw, "UV1s", mesh.uv2);
                WriteVectorItem(sw, "UV2s", mesh.uv2);
                WriteVectorItem(sw, "UV3s", mesh.uv3);
                WriteVectorItem(sw, "UV4s", mesh.uv4);
                WriteVectorItem(sw, "UV5s", mesh.uv5);
                WriteVectorItem(sw, "UV6s", mesh.uv6);
                WriteVectorItem(sw, "UV7s", mesh.uv7);
            }
        }

        /// <summary>
        /// Write mesh data as a C# code which is easy to read but has large code size.
        /// </summary>
        /// <param name="mesh">Target mesh.</param>
        /// <param name="filePath">A file path to write.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="nsName">Name of namespace. Null or empty string means no namespace.</param>
        /// <param name="className">Class name.</param>
        public static void WriteMeshCreateMethodInplace(Mesh mesh, string filePath, string indentString, string nsName, string className)
        {
            using (var fs = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.Read))
            using (var sw = new StreamWriter(fs))
            {
                sw.WriteLine("using UnityEngine;");
                sw.WriteLine("using System.Collections.Generic;");

                sw.WriteLine();
                sw.WriteLine();

                int indentLevel = 0;
                if (!string.IsNullOrEmpty(nsName))
                {
                    sw.WriteLine("namespace {0}", nsName);
                    sw.WriteLine("{");
                    indentLevel++;
                }

                if (string.IsNullOrEmpty(className))
                {
                    className = "MeshCreator";
                }

                var indent = GetIndentString(indentString, indentLevel);

                sw.Write(indent);
                sw.WriteLine("/// <summary>");
                sw.Write(indent);
                sw.WriteLine("/// Exported mesh data class.");
                sw.Write(indent);
                sw.WriteLine("/// </summary>");
                sw.Write(indent);
                sw.WriteLine("public class {0}", className);
                sw.Write(indent);
                sw.WriteLine("{");

                indent = GetIndentString(indentString, ++indentLevel);

                var vertices = mesh.vertices;
                var triangles = mesh.triangles;

                sw.Write(indent);
                sw.WriteLine("/// <summary>");
                sw.Write(indent);
                sw.WriteLine("/// Create cube mesh with {0} vertices, {1} polygons (triangles).");
                sw.Write(indent);
                sw.WriteLine("/// </summary>");
                sw.Write(indent);
                sw.WriteLine("/// <param name=\"doOptimize\">A flag whether optimize mesh or not.</param>");
                sw.Write(indent);
                sw.WriteLine("/// <param name=\"doRecalcNormals\">A flag whether recalculate normals or not.</param>");
                sw.Write(indent);
                sw.WriteLine("/// <param name=\"doRecalcTangents\">A flag whether recalculate tangents or not.</param>");
                sw.Write(indent);
                sw.WriteLine("/// <returns>Created mesh.</returns>");
                sw.Write(indent);
                sw.WriteLine("public static Mesh CreateMesh(bool doOptimize = true, bool doRecalcNormals = false, bool doRecalcTangents = false)");
                sw.Write(indent);
                sw.WriteLine("{");

                indent = GetIndentString(indentString, ++indentLevel);

                sw.Write(indent);
                sw.WriteLine("var mesh = new Mesh();");
                sw.WriteLine();

                EmitSetVectorArray(sw, "SetVertices", vertices, indentString, indentLevel);

                sw.WriteLine();
                EmitSetTriangles(sw, triangles, indentString, indentLevel);
                triangles = null;  // for GC.

                sw.WriteLine();
                sw.Write(indent);
                sw.WriteLine("if (!doRecalcNormals)");
                sw.Write(indent);
                sw.WriteLine("{");
                EmitSetVectorArray(sw, "SetNormals", mesh.normals, indentString, indentLevel + 1);
                sw.Write(indent);
                sw.WriteLine("}");
                sw.WriteLine();

                sw.Write(indent);
                sw.WriteLine("if (!doRecalcTangents)");
                sw.Write(indent);
                sw.WriteLine("{");
                EmitSetVectorArray(sw, "SetTangents", mesh.tangents, indentString, indentLevel + 1);
                sw.Write(indent);
                sw.WriteLine("}");
                sw.WriteLine();

                EmitSetColors(sw, mesh.colors, indentString, indentLevel);
                sw.WriteLine();

                for (int i = 0; i < 8; i++)
                {
                    var uvList = new List<Vector2>(vertices.Length);
                    mesh.GetUVs(i, uvList);
                    EmitSetUVs(sw, i, uvList, indentString, indentLevel);
                    sw.WriteLine();
                }
                vertices = null;  // for GC.

                sw.Write(indent);
                sw.WriteLine("if (doOptimize)");
                sw.Write(indent);
                sw.WriteLine("{");
                indent = GetIndentString(indentString, ++indentLevel);
                sw.Write(indent);
                sw.WriteLine("mesh.Optimize();");
                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");

                sw.WriteLine("");
                sw.Write(indent);
                sw.WriteLine("mesh.RecalculateBounds();");

                sw.Write(indent);
                sw.WriteLine("if (doRecalcNormals)");
                sw.Write(indent);
                sw.WriteLine("{");
                indent = GetIndentString(indentString, ++indentLevel);
                sw.Write(indent);
                sw.WriteLine("mesh.RecalculateNormals();");
                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");

                sw.Write(indent);
                sw.WriteLine("if (doRecalcTangents)");
                sw.Write(indent);
                sw.WriteLine("{");
                indent = GetIndentString(indentString, ++indentLevel);
                sw.Write(indent);
                sw.WriteLine("mesh.RecalculateTangents();");
                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");

                sw.WriteLine();

                sw.Write(indent);
                sw.WriteLine("return mesh;");

                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");  // End of method

                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");  // End of class

                if (!string.IsNullOrEmpty(nsName))
                {
                    sw.WriteLine("}");  // End of namespace
                }
            }
        }

        /// <summary>
        /// Write mesh data as a C# code which is optimized to execute.
        /// </summary>
        /// <param name="mesh">Target mesh.</param>
        /// <param name="filePath">A file path to write.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="nsName">Name of namespace. Null or empty string means no namespace.</param>
        /// <param name="className">Class name.</param>
        public static void WriteMeshCreateMethod(Mesh mesh, string filePath, string indentString, string nsName, string className)
        {
            using (var fs = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.Read))
            using (var sw = new StreamWriter(fs))
            {
                sw.WriteLine("using UnityEngine;");
                sw.WriteLine("using System.Collections.Generic;");

                sw.WriteLine();
                sw.WriteLine();

                int indentLevel = 0;
                if (!string.IsNullOrEmpty(nsName))
                {
                    sw.WriteLine("namespace {0}", nsName);
                    sw.WriteLine("{");
                    indentLevel++;
                }

                if (string.IsNullOrEmpty(className))
                {
                    className = "MeshCreator";
                }

                var indent = GetIndentString(indentString, indentLevel);

                sw.Write(indent);
                sw.WriteLine("/// <summary>");
                sw.Write(indent);
                sw.WriteLine("/// Exported mesh data class.");
                sw.Write(indent);
                sw.WriteLine("/// </summary>");
                sw.Write(indent);
                sw.WriteLine("public class {0}", className);
                sw.Write(indent);
                sw.WriteLine("{");

                indent = GetIndentString(indentString, ++indentLevel);

                var vertices = mesh.vertices;
                var triangles = mesh.triangles;

                sw.Write(indent);
                sw.WriteLine("/// <summary>");
                sw.Write(indent);
                sw.WriteLine("/// Create cube mesh with {0} vertices, {1} polygons (triangles).");
                sw.Write(indent);
                sw.WriteLine("/// </summary>");
                sw.Write(indent);
                sw.WriteLine("/// <param name=\"doOptimize\">A flag whether optimize mesh or not.</param>");
                sw.Write(indent);
                sw.WriteLine("/// <param name=\"doRecalcNormals\">A flag whether recalculate normals or not.</param>");
                sw.Write(indent);
                sw.WriteLine("/// <param name=\"doRecalcTangents\">A flag whether recalculate tangents or not.</param>");
                sw.Write(indent);
                sw.WriteLine("/// <returns>Created mesh.</returns>");
                sw.Write(indent);
                sw.WriteLine("public static Mesh CreateMesh(bool doOptimize = true, bool doRecalcNormals = false, bool doRecalcTangents = false)");
                sw.Write(indent);
                sw.WriteLine("{");

                indent = GetIndentString(indentString, ++indentLevel);

                sw.Write(indent);
                sw.WriteLine("var mesh = new Mesh();");

                sw.WriteLine();
                sw.Write(indent);
                if (vertices.Length == 0)
                {
                    sw.WriteLine("// Has no Vertices.");
                }
                else
                {
                    sw.WriteLine("mesh.SetVertices(LoadVertices());");
                }

                sw.WriteLine();
                sw.Write(indent);
                if (triangles.Length == 0)
                {
                    sw.WriteLine("// Has no Triangles.");
                }
                else
                {
                    sw.WriteLine("mesh.SetTriangles(LoadTriangles(), 0);");
                }

                sw.WriteLine();
                sw.Write(indent);
                if (mesh.HasVertexAttribute(VertexAttribute.Normal))
                {
                    sw.WriteLine("if (!doRecalcNormals)");
                    sw.Write(indent);
                    sw.WriteLine("{");

                    indent = GetIndentString(indentString, ++indentLevel);

                    sw.Write(indent);
                    sw.WriteLine("mesh.SetNormals(LoadNormals());");

                    indent = GetIndentString(indentString, --indentLevel);
                    sw.Write(indent);
                    sw.WriteLine("}");
                }
                else
                {
                    sw.WriteLine("// Has no Normals.");
                }

                sw.WriteLine();
                sw.Write(indent);
                if (mesh.HasVertexAttribute(VertexAttribute.Tangent))
                {
                    sw.WriteLine("if (!doRecalcTangents)");
                    sw.Write(indent);
                    sw.WriteLine("{");

                    indent = GetIndentString(indentString, ++indentLevel);

                    sw.Write(indent);
                    sw.WriteLine("mesh.SetTangents(LoadTangents());");

                    indent = GetIndentString(indentString, --indentLevel);
                    sw.Write(indent);
                    sw.WriteLine("}");
                }
                else
                {
                    sw.WriteLine("// Has no Tangents.");
                }
                sw.WriteLine();

                sw.Write(indent);
                sw.WriteLine(mesh.HasVertexAttribute(VertexAttribute.Color)
                    ? "mesh.SetColors(LoadColors());"
                    : "// Has no Colors.");
                sw.WriteLine();

                var hasUVFlags = new bool[8];
                for (int i = 0; i < hasUVFlags.Length; i++)
                {
                    hasUVFlags[i] = mesh.HasVertexAttribute((VertexAttribute)((int)VertexAttribute.TexCoord0 + i));

                    sw.Write(indent);
                    if (hasUVFlags[i])
                    {
                        sw.WriteLine("mesh.SetUVs({0}, LoadUV{1}s());", i, i == 0 ? "" : i.ToString());
                    }
                    else
                    {
                        sw.Write("// Has no UV");
                        sw.Write(i == 0 ? "" : i.ToString());
                        sw.WriteLine(".");
                    }
                    sw.WriteLine();
                }

                sw.Write(indent);
                sw.WriteLine("if (doOptimize)");
                sw.Write(indent);
                sw.WriteLine("{");
                indent = GetIndentString(indentString, ++indentLevel);
                sw.Write(indent);
                sw.WriteLine("mesh.Optimize();");
                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");

                sw.WriteLine();

                sw.Write(indent);
                sw.WriteLine("mesh.RecalculateBounds();");

                sw.Write(indent);
                sw.WriteLine("if (doRecalcNormals)");
                sw.Write(indent);
                sw.WriteLine("{");
                indent = GetIndentString(indentString, ++indentLevel);
                sw.Write(indent);
                sw.WriteLine("mesh.RecalculateNormals();");
                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");

                sw.Write(indent);
                sw.WriteLine("if (doRecalcTangents)");
                sw.Write(indent);
                sw.WriteLine("{");
                indent = GetIndentString(indentString, ++indentLevel);
                sw.Write(indent);
                sw.WriteLine("mesh.RecalculateTangents();");
                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");

                sw.WriteLine();

                sw.Write(indent);
                sw.WriteLine("return mesh;");

                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");  // End of method

                // Emit each loading methods, LoadXXXs().
                int mlv2Cnt = 0;
                int mlv3Cnt = 0;
                if (vertices.Length != 0)
                {
                    sw.WriteLine();
                    EmitMethodLoadVector3Array(sw, "LoadVertices", "Vertex", vertices, indentString, indentLevel);
                    mlv3Cnt++;
                }
                if (triangles.Length != 0)
                {
                    sw.WriteLine();
                    EmitMethodLoadIntArray(sw, "LoadTriangles", "Triangle", triangles, 3, indentString, indentLevel);
                    triangles = null;  // for GC.
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Normal))
                {
                    sw.WriteLine();
                    EmitMethodLoadVector3Array(sw, "LoadNormals", "Normal", mesh.normals, indentString, indentLevel);
                    mlv3Cnt++;
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Tangent))
                {
                    sw.WriteLine();
                    EmitMethodLoadVector4Array(sw, "LoadTangents", "tangent", mesh.tangents, indentString, indentLevel);
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Color))
                {
                    sw.WriteLine();
                    EmitMethodLoadColorArray(sw, "LoadColors", "Color", mesh.colors, indentString, indentLevel);
                }

                for (int i = 0; i < hasUVFlags.Length; i++)
                {
                    var uvList = new List<Vector2>(vertices.Length);
                    if (hasUVFlags[i])
                    {
                        mesh.GetUVs(i, uvList);
                        var itemName = string.Format("UV{0}", i == 0 ? "" : i.ToString());
                        sw.WriteLine();
                        EmitMethodLoadVector2List(sw, "Load" + itemName + "s", itemName, uvList, indentString, indentLevel);
                        mlv2Cnt++;
                    }
                }
                vertices = null;  // for GC.

                // Emit conversion methods, AsXXX().
                if (mlv2Cnt > 0)
                {
                    sw.WriteLine();
                    EmitMethodAsVectorNList(sw, 2, indentString, indentLevel);
                }
                if (mlv3Cnt > 0)
                {
                    sw.WriteLine();
                    EmitMethodAsVectorNArray(sw, 3, indentString, indentLevel);
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Tangent))
                {
                    sw.WriteLine();
                    EmitMethodAsVectorNArray(sw, 4, indentString, indentLevel);
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Color))
                {
                    sw.WriteLine();
                    EmitMethodAsColorArray(sw, indentString, indentLevel);
                }

                indent = GetIndentString(indentString, --indentLevel);
                sw.Write(indent);
                sw.WriteLine("}");  // End of class

                if (!string.IsNullOrEmpty(nsName))
                {
                    sw.WriteLine("}");  // End of namespace
                }
            }
        }

        /// <summary>
        /// Write array of <see cref="Vector2"/> as a CSV.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="itemName">Name of item.</param>
        /// <param name="vectors">A <see cref="Vector2"/> array.</param>
        private static void WriteVectorItem(TextWriter tw, string itemName, Vector2[] vectors)
        {
            tw.WriteLine("{0},{1}", itemName, vectors.Length);
            foreach (var v in vectors)
            {
                tw.WriteLine("{0},{1}", v.x, v.y);
            }
        }

        /// <summary>
        /// Write array of <see cref="Vector3"/> as a CSV.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="itemName">Name of item.</param>
        /// <param name="vectors">A <see cref="Vector3"/> array.</param>
        private static void WriteVectorItem(TextWriter tw, string itemName, Vector3[] vectors)
        {
            tw.WriteLine("{0},{1}", itemName, vectors.Length);
            foreach (var v in vectors)
            {
                tw.WriteLine("{0},{1},{2}", v.x, v.y, v.z);
            }
        }

        /// <summary>
        /// Write array of <see cref="Vector4"/> as a CSV.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="itemName">Name of item.</param>
        /// <param name="vectors">A <see cref="Vector4"/> array.</param>
        private static void WriteVectorItem(TextWriter tw, string itemName, Vector4[] vectors)
        {
            tw.WriteLine("{0},{1}", itemName, vectors.Length);
            foreach (var v in vectors)
            {
                tw.WriteLine("{0},{1},{2},{3}", v.x, v.y, v.z, v.w);
            }
        }

        /// <summary>
        /// Write triangle data as a CSV.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="itemName">Name of item.</param>
        /// <param name="triangles">Vertex indices to compose triangles.</param>
        private static void WriteTriangleItem(TextWriter tw, string itemName, int[] triangles)
        {
            tw.WriteLine("{0},{1}", itemName, triangles.Length / 3);
            for (int i = 0; i < triangles.Length; i += 3)
            {
                tw.WriteLine("{0},{1},{2}", triangles[i], triangles[i + 1], triangles[i + 2]);
            }
        }

        /// <summary>
        /// Write vertex color data as a CSV.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="itemName">Name of item.</param>
        /// <param name="colors">Vertex colors.</param>
        private static void WriteColorItem(TextWriter tw, string itemName, Color[] colors)
        {
            tw.WriteLine("{0},{1}", itemName, colors.Length);
            foreach (var c in colors)
            {
                tw.WriteLine("{0},{1},{2},{3}", c.r, c.g, c.b, c.a);
            }
        }

        /// <summary>
        /// Get indent string according to specified indent level.
        /// </summary>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        /// <returns>Indent string.</returns>
        private static string GetIndentString(string indentString, int indentLevel)
        {
            if (indentLevel < 1)
            {
                return "";
            }
            var sb = new StringBuilder(indentString.Length * indentLevel);
            for (int i = 0; i < indentLevel; i++)
            {
                sb.Append(indentString);
            }
            return sb.ToString();
        }

        /// <summary>
        /// Emit code fragment to call mesh.SetXXX() which argument is the array of the <see cref="Vector3"/>.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="methodName">Name of method to call (SetXXX).</param>
        /// <param name="vectors">A <see cref="Vector3"/> array to set to the mesh.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitSetVectorArray(TextWriter tw, string methodName, Vector3[] vectors, string indentString, int indentLevel)
        {
            if (vectors.Length == 0)
            {
                return;
            }

            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("mesh.{0}(new []", methodName);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            int itemCnt = 1;
            foreach (var v in vectors)
            {
                tw.Write(indent);
                tw.Write("new Vector3({0}f, {1}f, {2}f)", v.x, v.y, v.z);
                tw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of method call
        }

        /// <summary>
        /// Emit code fragment to call mesh.SetXXX() which argument is the array of the <see cref="Vector4"/>.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="methodName">Name of method to call (SetXXX).</param>
        /// <param name="vectors">A <see cref="Vector4"/> array to set to the mesh.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitSetVectorArray(TextWriter tw, string methodName, Vector4[] vectors, string indentString, int indentLevel)
        {
            if (vectors.Length == 0)
            {
                return;
            }

            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("mesh.{0}(new []", methodName);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            int itemCnt = 1;
            foreach (var v in vectors)
            {
                tw.Write(indent);
                tw.Write("new Vector4({0}f, {1}f, {2}f, {3}f)", v.x, v.y, v.z, v.w);
                tw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of method call
        }

        /// <summary>
        /// Emit code fragment to call <see cref="Mesh.SetUVs(int, Vector2[])"/>.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="channel">Channel of uvs.</param>
        /// <param name="uvs">UV coordinates for each vertices.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitSetUVs(TextWriter tw, int channel, IList<Vector2> uvs, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            if (uvs.Count == 0)
            {
                tw.Write(indent);
                tw.WriteLine("/// Has no UV" + channel + ".");
                return;
            }

            tw.Write(indent);
            tw.WriteLine("mesh.SetUVs({0}, new List<Vector2>()", channel);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            int itemCnt = 1;
            foreach (var uv in uvs)
            {
                tw.Write(indent);
                tw.Write("new Vector2({0}f, {1}f)", uv.x, uv.y);
                tw.WriteLine(itemCnt < uvs.Count ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of list and method call
        }

        /// <summary>
        /// Emit code fragment to call <see cref="Mesh.SetColors(Color[])"/>.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="colors">Vertex colors.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitSetColors(TextWriter tw, Color[] colors, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            if (colors.Length == 0)
            {
                tw.Write(indent);
                tw.WriteLine("/// Has no Vertex Colors.");
                return;
            }

            tw.Write(indent);
            tw.WriteLine("mesh.SetColors(new []");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            int itemCnt = 1;
            foreach (var color in colors)
            {
                tw.Write(indent);
                tw.Write("new Color({0}, {1}, {2})", color.r, color.g, color.b, color.a);
                tw.WriteLine(itemCnt < colors.Length ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of method call
        }

        /// <summary>
        /// Emit code fragment to call <see cref="Mesh.SetTriangles(int[], int)"/>.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="triangles">Vertex indices to compose triangles.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitSetTriangles(TextWriter tw, int[] triangles, string indentString, int indentLevel)
        {
            if (triangles.Length == 0)
            {
                return;
            }

            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("mesh.SetTriangles(new []");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            for (int i = 0; i < triangles.Length; i += 3)
            {
                tw.Write(indent);
                tw.Write("{0}, {1}, {2}", triangles[i], triangles[i + 1], triangles[i + 2]);
                tw.WriteLine(i < triangles.Length - 2 ? "," : "");
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}, 0);");  // End of method call
        }

        /// <summary>
        /// Emit a method which returns <see cref="Vector2"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="vectors"><see cref="Vector2"/> list to embedded in C# code.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodLoadVector2List(TextWriter tw, string methodName, string itemName, IList<Vector2> vectors, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load {0} data.", itemName);
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"Vector2\"/> array of {0}.</returns>", itemName);

            tw.Write(indent);
            tw.WriteLine("private static List<Vector2> {0}()", methodName);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("return AsVector2List(new []");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            var itemCnt = 1;
            foreach (var v in vectors)
            {
                tw.Write(indent);
                tw.Write("{0}f, {1}f", v.x, v.y);
                tw.WriteLine(itemCnt < vectors.Count ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of method call

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns <see cref="Vector3"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="vectors"><see cref="Vector3"/> array to embedded in C# code.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodLoadVector3Array(TextWriter tw, string methodName, string itemName, Vector3[] vectors, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load {0} data.", itemName);
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"Vector3\"/> array of {0}.</returns>", itemName);

            tw.Write(indent);
            tw.WriteLine("private static Vector3[] {0}()", methodName);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("return AsVector3Array(new []");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            var itemCnt = 1;
            foreach (var v in vectors)
            {
                tw.Write(indent);
                tw.Write("{0}f, {1}f, {2}f", v.x, v.y, v.z);
                tw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of method call

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns <see cref="Vector4"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="vectors"><see cref="Vector4"/> array to embedded in C# code.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodLoadVector4Array(TextWriter tw, string methodName, string itemName, Vector4[] vectors, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load {0} data.", itemName);
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"Vector4\"/> array of {0}.</returns>", itemName);

            tw.Write(indent);
            tw.WriteLine("private static Vector4[] {0}()", methodName);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("return AsVector4Array(new []");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            var itemCnt = 1;
            foreach (var v in vectors)
            {
                tw.Write(indent);
                tw.Write("{0}f, {1}f, {2}f, {3}f", v.x, v.y, v.z, v.w);
                tw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of method call

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns embedded <see cref="int"/> array.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="nCols">Number of rows.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="data"><see cref="int"/> array to embedded in C# code.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodLoadIntArray(TextWriter tw, string methodName, string itemName, int[] data, int nCols, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load {0} data.", itemName);
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"int\"/> array of {0}.</returns>", itemName);

            tw.Write(indent);
            tw.WriteLine("private static int[] {0}()", methodName);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("return new []");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            for (int i = 0; i < data.Length; i++)
            {
                if (i % nCols == 0)
                {
                    if (i > 0)
                    {
                        if (i < data.Length - 1)
                        {
                            // Comma at the end of line
                            tw.Write(",");
                        }
                        tw.WriteLine();
                    }
                    tw.Write(indent);
                }
                else
                {
                    tw.Write(", ");
                }
                tw.Write(data[i]);
            }

            tw.WriteLine();

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("};");  // End of array

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns <see cref="Color"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="colors"><see cref="Color"/> array to embedded in C# code.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodLoadColorArray(TextWriter tw, string methodName, string itemName, Color[] colors, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load {0} data.", itemName);
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"Color\"/> array of {0}.</returns>", itemName);

            tw.Write(indent);
            tw.WriteLine("private static Color[] {0}()", methodName);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("return AsColorArray(new []");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            var itemCnt = 1;
            foreach (var c in colors)
            {
                tw.Write(indent);
                tw.Write("{0}f, {1}f, {2}f, {3}f", c.r, c.g, c.b, c.a);
                tw.WriteLine(itemCnt < colors.Length ? "," : "");
                itemCnt++;
            }

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("});");  // End of method call

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit AsVectorNArray method which converts <see cref="float"/> array
        /// to <see cref="Vector2"/>, <see cref="Vector3"/> or <see cref="Vector4"/> array.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="dim">Dimension of vector.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodAsVectorNArray(TextWriter tw, int dim, string indentString, int indentLevel)
        {
            if (dim < 2 || dim > 4)
            {
                throw new ArgumentException("dim must be 2, 3 or 4");
            }

            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load float array as a <see cref=\"Vector{0}\"/> array.", dim);
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <param name=\"data\">Data array for <see cref=\"Vector{0}\"/></param>", dim);
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"Vector{0}\"/> array.</returns>", dim);

            tw.Write(indent);
            tw.WriteLine("private static Vector{0}[] AsVector{0}Array(float[] data)", dim);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("var vectors = new Vector{0}[data.Length / {0}];", dim);
            tw.Write(indent);
            tw.WriteLine("for (int i = 0; i < vectors.Length; i++)");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("var j = i * {0};", dim);
            tw.Write(indent);
            tw.Write("vectors[i] = new Vector{0}(data[j]", dim);
            for (int i = 1; i < dim; i++)
            {
                tw.Write(", data[j + {0}]", i);
            }
            tw.WriteLine(");");

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of for

            tw.Write(indent);
            tw.WriteLine("return vectors;");

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit AsVectorNList method which converts <see cref="float"/> array
        /// to <see cref=\"List{T}\"/> of <see cref="Vector2"/>, <see cref="Vector3"/> or <see cref="Vector4"/>.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="dim">Dimension of vector.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodAsVectorNList(TextWriter tw, int dim, string indentString, int indentLevel)
        {
            if (dim < 2 || dim > 4)
            {
                throw new ArgumentException("dim must be 2, 3 or 4");
            }

            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load float array as a <see cref=\"List{{T}}\"/> of <see cref=\"Vector{0}\"/>.", dim);
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <param name=\"data\">Data array for <see cref=\"Vector{0}\"/></param>", dim);
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"List{{T}}\"/> of <see cref=\"Vector{0}\"/>.</returns>", dim);

            tw.Write(indent);
            tw.WriteLine("private static List<Vector{0}> AsVector{0}List(float[] data)", dim);
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("var vectors = new List<Vector{0}>(data.Length / {0});", dim);
            tw.Write(indent);
            tw.WriteLine("for (int i = 0; i < vectors.Capacity; i++)");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("var j = i * {0};", dim);
            tw.Write(indent);
            tw.Write("vectors.Add(new Vector{0}(data[j]", dim);
            for (int i = 1; i < dim; i++)
            {
                tw.Write(", data[j + {0}]", i);
            }
            tw.WriteLine("));");

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of for

            tw.Write(indent);
            tw.WriteLine("return vectors;");

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit AsColorArray method which converts <see cref="float"/> array to <see cref="Color"/> array.
        /// </summary>
        /// <param name="tw">Destination <see cref="TextWriter"/>.</param>
        /// <param name="indentString">A string for indentation.</param>
        /// <param name="indentLevel">Indent level.</param>
        private static void EmitMethodAsColorArray(TextWriter tw, string indentString, int indentLevel)
        {
            var indent = GetIndentString(indentString, indentLevel);

            tw.Write(indent);
            tw.WriteLine("/// <summary>");
            tw.Write(indent);
            tw.WriteLine("/// Load <see cref=\"float\"/>array as a <see cref=\"Color\"/> array.");
            tw.Write(indent);
            tw.WriteLine("/// </summary>");
            tw.Write(indent);
            tw.WriteLine("/// <param name=\"data\">Data array for <see cref=\"Color\"/></param>");
            tw.Write(indent);
            tw.WriteLine("/// <returns><see cref=\"Color\"/> array.</returns>");

            tw.Write(indent);
            tw.WriteLine("private static Color[] AsColorArray(float[] data)");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("var colors = new Color[data.Length / 4];");
            tw.Write(indent);
            tw.WriteLine("for (int i = 0; i < colors.Length; i++)");
            tw.Write(indent);
            tw.WriteLine("{");

            indent = GetIndentString(indentString, ++indentLevel);

            tw.Write(indent);
            tw.WriteLine("var j = i * 4;");
            tw.Write(indent);
            tw.WriteLine("colors[i] = new Color(data[j], data[j + 1], data[j + 2], data[j + 3]);");

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of for

            tw.Write(indent);
            tw.WriteLine("return colors;");

            indent = GetIndentString(indentString, --indentLevel);
            tw.Write(indent);
            tw.WriteLine("}");  // End of method
        }
    }
}
