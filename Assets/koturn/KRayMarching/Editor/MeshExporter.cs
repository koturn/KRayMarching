using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Enums;


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
        public static void WriteMeshCreateMethodInplace(Mesh mesh, string filePath, string indentString, string nsName, string className, ColorFormat colorFormat = ColorFormat.RGBAFloat)
        {
            using (var fs = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.Read))
            using (var isw = new IndentStreamWriter(fs, indentString))
            {
                isw.WriteLine("using UnityEngine;");
                isw.WriteLine("using System.Collections.Generic;");

                isw.WriteEmptyLines(2);

                if (!string.IsNullOrEmpty(nsName))
                {
                    isw.WriteLine("namespace {0}", nsName);
                    isw.WriteLine("{");
                    isw.IndentLevel++;
                }

                if (string.IsNullOrEmpty(className))
                {
                    className = "MeshCreator";
                }

                isw.WriteLine("/// <summary>");
                isw.WriteLine("/// Exported mesh data class.");
                isw.WriteLine("/// </summary>");
                isw.WriteLine("public static class {0}", className);
                isw.WriteLine("{");

                isw.IndentLevel++;

                var vertices = mesh.vertices;
                var triangles = mesh.triangles;

                isw.WriteLine("/// <summary>");
                isw.WriteLine("/// Create cube mesh with {0} vertices, {1} polygons (triangles).");
                isw.WriteLine("/// </summary>");
                isw.WriteLine("/// <param name=\"doOptimize\">A flag whether optimize mesh or not.</param>");
                isw.WriteLine("/// <param name=\"doRecalcNormals\">A flag whether recalculate normals or not.</param>");
                isw.WriteLine("/// <param name=\"doRecalcTangents\">A flag whether recalculate tangents or not.</param>");
                isw.WriteLine("/// <returns>Created mesh.</returns>");
                isw.WriteLine("public static Mesh CreateMesh(bool doOptimize = true, bool doRecalcNormals = false, bool doRecalcTangents = false)");
                isw.WriteLine("{");

                isw.IndentLevel++;

                isw.WriteLine("var mesh = new Mesh();");
                isw.WriteLine();

                EmitSetVectorArray(isw, "SetVertices", vertices);

                isw.WriteLine();
                EmitSetTriangles(isw, triangles);
                triangles = null;  // for GC.

                isw.WriteLine();
                isw.WriteLine("if (!doRecalcNormals)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                EmitSetVectorArray(isw, "SetNormals", mesh.normals);
                isw.IndentLevel--;
                isw.WriteLine("}");
                isw.WriteLine();

                isw.WriteLine("if (!doRecalcTangents)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                EmitSetVectorArray(isw, "SetTangents", mesh.tangents);
                isw.IndentLevel--;
                isw.WriteLine("}");
                isw.WriteLine();

                switch (colorFormat)
                {
                    case ColorFormat.RGB24:
                        EmitSetColors(isw, mesh.colors32, false);
                        break;
                    case ColorFormat.RGBA32:
                        EmitSetColors(isw, mesh.colors32);
                        break;
                    case ColorFormat.RGBFloat:
                        EmitSetColors(isw, mesh.colors, false);
                        break;
                    case ColorFormat.RGBAFloat:
                        EmitSetColors(isw, mesh.colors);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException(nameof(colorFormat), colorFormat, $"Invalid value for {nameof(ColorFormat)}");
                }
                isw.WriteLine();

                for (int i = 0; i < 8; i++)
                {
                    var uvList = new List<Vector2>(vertices.Length);
                    mesh.GetUVs(i, uvList);
                    EmitSetUVs(isw, i, uvList);
                    isw.WriteLine();
                }
                vertices = null;  // for GC.

                isw.WriteLine("if (doOptimize)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                isw.WriteLine("mesh.Optimize();");
                isw.IndentLevel--;
                isw.WriteLine("}");

                isw.WriteLine();
                isw.WriteLine("mesh.RecalculateBounds();");

                isw.WriteLine("if (doRecalcNormals)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                isw.WriteLine("mesh.RecalculateNormals();");
                isw.IndentLevel--;
                isw.WriteLine("}");

                isw.WriteLine("if (doRecalcTangents)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                isw.WriteLine("mesh.RecalculateTangents();");
                isw.IndentLevel--;
                isw.WriteLine("}");

                isw.WriteLine();

                isw.WriteLine("return mesh;");

                isw.IndentLevel--;
                isw.WriteLine("}");  // End of method

                isw.IndentLevel--;
                isw.WriteLine("}");  // End of class

                if (!string.IsNullOrEmpty(nsName))
                {
                    isw.IndentLevel--;
                    isw.WriteLine("}");  // End of namespace
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
        public static void WriteMeshCreateMethod(Mesh mesh, string filePath, string indentString, string nsName, string className, ColorFormat colorFormat = ColorFormat.RGBAFloat)
        {
            using (var fs = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.Read))
            using (var isw = new IndentStreamWriter(fs, indentString))
            {
                isw.WriteLine("using UnityEngine;");
                isw.WriteLine("using System.Collections.Generic;");
                isw.WriteLine("using System.Runtime.InteropServices;");

                isw.WriteEmptyLines(2);

                if (!string.IsNullOrEmpty(nsName))
                {
                    isw.WriteLine("namespace {0}", nsName);
                    isw.WriteLine("{");
                    isw.IndentLevel++;
                }

                if (string.IsNullOrEmpty(className))
                {
                    className = "MeshCreator";
                }

                isw.WriteLine("/// <summary>");
                isw.WriteLine("/// Exported mesh data class.");
                isw.WriteLine("/// </summary>");
                isw.WriteLine("public static class {0}", className);
                isw.WriteLine("{");
                isw.IndentLevel++;

                var vertices = mesh.vertices;
                var triangles = mesh.triangles;

                isw.WriteLine("/// <summary>");
                isw.WriteLine("/// Create cube mesh with {0} vertices, {1} polygons (triangles).");
                isw.WriteLine("/// </summary>");
                isw.WriteLine("/// <param name=\"doOptimize\">A flag whether optimize mesh or not.</param>");
                isw.WriteLine("/// <param name=\"doRecalcNormals\">A flag whether recalculate normals or not.</param>");
                isw.WriteLine("/// <param name=\"doRecalcTangents\">A flag whether recalculate tangents or not.</param>");
                isw.WriteLine("/// <returns>Created mesh.</returns>");
                isw.WriteLine("public static Mesh CreateMesh(bool doOptimize = true, bool doRecalcNormals = false, bool doRecalcTangents = false)");
                isw.WriteLine("{");
                isw.IndentLevel++;

                isw.WriteLine("var mesh = new Mesh();");

                isw.WriteLine();
                if (vertices.Length == 0)
                {
                    isw.WriteLine("// Has no Vertices.");
                }
                else
                {
                    isw.WriteLine("mesh.SetVertices(LoadVertices());");
                }

                isw.WriteLine();
                if (triangles.Length == 0)
                {
                    isw.WriteLine("// Has no Triangles.");
                }
                else
                {
                    isw.WriteLine("mesh.SetTriangles(LoadTriangles(), 0);");
                }

                isw.WriteLine();
                if (mesh.HasVertexAttribute(VertexAttribute.Normal))
                {
                    isw.WriteLine("if (!doRecalcNormals)");
                    isw.WriteLine("{");

                    isw.IndentLevel++;

                    isw.WriteLine("mesh.SetNormals(LoadNormals());");

                    isw.IndentLevel--;
                    isw.WriteLine("}");
                }
                else
                {
                    isw.WriteLine("// Has no Normals.");
                }

                isw.WriteLine();
                if (mesh.HasVertexAttribute(VertexAttribute.Tangent))
                {
                    isw.WriteLine("if (!doRecalcTangents)");
                    isw.WriteLine("{");
                    isw.IndentLevel++;

                    isw.WriteLine("mesh.SetTangents(LoadTangents());");

                    isw.IndentLevel--;
                    isw.WriteLine("}");
                }
                else
                {
                    isw.WriteLine("// Has no Tangents.");
                }
                isw.WriteLine();

                isw.WriteLine(mesh.HasVertexAttribute(VertexAttribute.Color)
                    ? "mesh.SetColors(LoadColors());"
                    : "// Has no Colors.");
                isw.WriteLine();

                var hasUVFlags = new bool[8];
                for (int i = 0; i < hasUVFlags.Length; i++)
                {
                    hasUVFlags[i] = mesh.HasVertexAttribute((VertexAttribute)((int)VertexAttribute.TexCoord0 + i));

                    if (hasUVFlags[i])
                    {
                        isw.WriteLine("mesh.SetUVs({0}, LoadUV{1}s());", i, i == 0 ? "" : i.ToString());
                    }
                    else
                    {
                        isw.Write("// Has no UV");
                        isw.Write(i == 0 ? "" : i.ToString());
                        isw.WriteLine(".");
                    }
                    isw.WriteLine();
                }

                isw.WriteLine("if (doOptimize)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                isw.WriteLine("mesh.Optimize();");
                isw.IndentLevel--;
                isw.WriteLine("}");

                isw.WriteLine();

                isw.WriteLine("mesh.RecalculateBounds();");

                isw.WriteLine("if (doRecalcNormals)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                isw.WriteLine("mesh.RecalculateNormals();");
                isw.IndentLevel--;
                isw.WriteLine("}");

                isw.WriteLine("if (doRecalcTangents)");
                isw.WriteLine("{");
                isw.IndentLevel++;
                isw.WriteLine("mesh.RecalculateTangents();");
                isw.IndentLevel--;
                isw.WriteLine("}");

                isw.WriteLine();

                isw.WriteLine("return mesh;");

                isw.IndentLevel--;
                isw.WriteLine("}");  // End of method

                // Emit each loading methods, LoadXXXs().
                if (vertices.Length != 0)
                {
                    isw.WriteLine();
                    EmitMethodLoadVector3Array(isw, "LoadVertices", "Vertex", vertices);
                }
                if (triangles.Length != 0)
                {
                    isw.WriteLine();
                    EmitMethodLoadIntArray(isw, "LoadTriangles", "Triangle", triangles, 3);
                    triangles = null;  // for GC.
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Normal))
                {
                    isw.WriteLine();
                    EmitMethodLoadVector3Array(isw, "LoadNormals", "Normal", mesh.normals);
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Tangent))
                {
                    isw.WriteLine();
                    EmitMethodLoadVector4Array(isw, "LoadTangents", "tangent", mesh.tangents);
                }
                if (mesh.HasVertexAttribute(VertexAttribute.Color))
                {
                    isw.WriteLine();
                    switch (colorFormat)
                    {
                        case ColorFormat.RGB24:
                            EmitMethodLoadColorArray(isw, "LoadColors", "Color", mesh.colors32, false);
                            break;
                        case ColorFormat.RGBA32:
                            EmitMethodLoadColorArray(isw, "LoadColors", "Color", mesh.colors32);
                            break;
                        case ColorFormat.RGBFloat:
                            EmitMethodLoadColorArray(isw, "LoadColors", "Color", mesh.colors, false);
                            break;
                        case ColorFormat.RGBAFloat:
                            EmitMethodLoadColorArray(isw, "LoadColors", "Color", mesh.colors);
                            break;
                        default:
                            throw new ArgumentOutOfRangeException(nameof(colorFormat), colorFormat, $"Invalid value for {nameof(ColorFormat)}");
                    }
                }

                for (int i = 0; i < hasUVFlags.Length; i++)
                {
                    var uvList = new List<Vector2>(vertices.Length);
                    if (hasUVFlags[i])
                    {
                        mesh.GetUVs(i, uvList);
                        var itemName = string.Format("UV{0}", i == 0 ? "" : i.ToString());
                        isw.WriteLine();
                        EmitMethodLoadVector2Array(isw, "Load" + itemName + "s", itemName, uvList);
                    }
                }
                vertices = null;  // for GC.

                // Emit conversion methods.
                isw.WriteLine();
                EmitMethodConvertArray(isw, "float");
                if (mesh.HasVertexAttribute(VertexAttribute.Color))
                {
                    isw.WriteLine();
                    switch (colorFormat)
                    {
                        case ColorFormat.RGB24:
                            EmitMethodConvertRGBArray(isw, "byte", "Color32");
                            break;
                        case ColorFormat.RGBA32:
                            EmitMethodConvertArray(isw, "byte");
                            break;
                        case ColorFormat.RGBFloat:
                            EmitMethodConvertRGBArray(isw, "float", "Color");
                            break;
                    }
                }

                isw.IndentLevel--;
                isw.WriteLine("}");  // End of class

                if (!string.IsNullOrEmpty(nsName))
                {
                    isw.IndentLevel--;
                    isw.WriteLine("}");  // End of namespace
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
        /// Emit code fragment to call mesh.SetXXX() which argument is the array of the <see cref="Vector3"/>.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method to call (SetXXX).</param>
        /// <param name="vectors">A <see cref="Vector3"/> array to set to the mesh.</param>
        private static void EmitSetVectorArray(IndentStreamWriter isw, string methodName, Vector3[] vectors)
        {
            if (vectors.Length == 0)
            {
                return;
            }

            isw.WriteLine("mesh.{0}(new []", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            int itemCnt = 1;
            foreach (var v in vectors)
            {
                isw.Write("new Vector3({0}f, {1}f, {2}f)", v.x, v.y, v.z);
                isw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call
        }

        /// <summary>
        /// Emit code fragment to call mesh.SetXXX() which argument is the array of the <see cref="Vector4"/>.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method to call (SetXXX).</param>
        /// <param name="vectors">A <see cref="Vector4"/> array to set to the mesh.</param>
        private static void EmitSetVectorArray(IndentStreamWriter isw, string methodName, Vector4[] vectors)
        {
            if (vectors.Length == 0)
            {
                return;
            }

            isw.WriteLine("mesh.{0}(new []", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            int itemCnt = 1;
            foreach (var v in vectors)
            {
                isw.Write("new Vector4({0}f, {1}f, {2}f, {3}f)", v.x, v.y, v.z, v.w);
                isw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call
        }

        /// <summary>
        /// Emit code fragment to call <see cref="Mesh.SetUVs(int, Vector2[])"/>.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="channel">Channel of uvs.</param>
        /// <param name="uvs">UV coordinates for each vertices.</param>
        private static void EmitSetUVs(IndentStreamWriter isw, int channel, List<Vector2> uvs)
        {
            if (uvs.Count == 0)
            {
                isw.WriteLine("// Has no UV" + channel + ".");
                return;
            }

            isw.WriteLine("mesh.SetUVs({0}, new []", channel);
            isw.WriteLine("{");
            isw.IndentLevel++;

            int itemCnt = 1;
            foreach (var uv in uvs)
            {
                isw.Write("new Vector2({0}f, {1}f)", uv.x, uv.y);
                isw.WriteLine(itemCnt < uvs.Count ? "," : "");
                itemCnt++;
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of array and method call
        }

        /// <summary>
        /// Emit code fragment to call <see cref="Mesh.SetColors(Color[])"/>.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="colors">Vertex colors.</param>
        /// <param name="isIncludeAlpha">True to embed alpha component into C# code.</param>
        private static void EmitSetColors(IndentStreamWriter isw, Color[] colors, bool isIncludeAlpha = true)
        {
            if (colors.Length == 0)
            {
                isw.WriteLine("// Has no Vertex Colors.");
                return;
            }

            isw.WriteLine("mesh.SetColors(new []");
            isw.WriteLine("{");
            isw.IndentLevel++;

            if (isIncludeAlpha)
            {
                int itemCnt = 1;
                foreach (var color in colors)
                {
                    isw.Write("new Color({0}, {1}, {2}, {3})", color.r, color.g, color.b, color.a);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }
            else
            {
                int itemCnt = 1;
                foreach (var color in colors)
                {
                    isw.Write("new Color({0}, {1}, {2})", color.r, color.g, color.b);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call
        }

        /// <summary>
        /// Emit code fragment to call <see cref="Mesh.SetColors(Color32[])"/>.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="colors">Vertex colors.</param>
        /// <param name="isIncludeAlpha">True to embed alpha component into C# code.</param>
        private static void EmitSetColors(IndentStreamWriter isw, Color32[] colors, bool isIncludeAlpha = true)
        {
            if (colors.Length == 0)
            {
                isw.WriteLine("// Has no Vertex Colors.");
                return;
            }

            isw.WriteLine("mesh.SetColors(new []");
            isw.WriteLine("{");
            isw.IndentLevel++;

            if (isIncludeAlpha)
            {
                int itemCnt = 1;
                foreach (var color in colors)
                {
                    isw.Write("new Color32({0}, {1}, {2}, {3})", color.r, color.g, color.b, color.a);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }
            else
            {
                int itemCnt = 1;
                foreach (var color in colors)
                {
                    isw.Write("new Color32({0}, {1}, {2})", color.r, color.g, color.b);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call
        }



        /// <summary>
        /// Emit code fragment to call <see cref="Mesh.SetTriangles(int[], int)"/>.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="triangles">Vertex indices to compose triangles.</param>
        private static void EmitSetTriangles(IndentStreamWriter isw, int[] triangles)
        {
            if (triangles.Length == 0)
            {
                return;
            }

            isw.WriteLine("mesh.SetTriangles(new []");
            isw.WriteLine("{");
            isw.IndentLevel++;

            for (int i = 0; i < triangles.Length; i += 3)
            {
                isw.Write("{0}, {1}, {2}", triangles[i], triangles[i + 1], triangles[i + 2]);
                isw.WriteLine(i < triangles.Length - 2 ? "," : "");
            }

            isw.IndentLevel--;
            isw.WriteLine("}, 0);");  // End of method call
        }

        /// <summary>
        /// Emit a method which returns <see cref="Vector2"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="vectors"><see cref="Vector2"/> list to embed in C# code.</param>
        private static void EmitMethodLoadVector2Array(IndentStreamWriter isw, string methodName, string itemName, List<Vector2> vectors)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Load {0} data.", itemName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <returns><see cref=\"Vector2\"/> array of {0}.</returns>", itemName);
            isw.WriteLine("private static Vector2[] {0}()", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            isw.WriteLine("return ConvertArray<Vector2>(new []");
            isw.WriteLine("{");
            isw.IndentLevel++;

            var itemCnt = 1;
            foreach (var v in vectors)
            {
                isw.Write("{0}f, {1}f", v.x, v.y);
                isw.WriteLine(itemCnt < vectors.Count ? "," : "");
                itemCnt++;
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns <see cref="Vector3"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="vectors"><see cref="Vector3"/> array to embed in C# code.</param>
        private static void EmitMethodLoadVector3Array(IndentStreamWriter isw, string methodName, string itemName, Vector3[] vectors)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Load {0} data.", itemName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <returns><see cref=\"Vector3\"/> array of {0}.</returns>", itemName);
            isw.WriteLine("private static Vector3[] {0}()", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            isw.WriteLine("return ConvertArray<Vector3>(new []");
            isw.WriteLine("{");
            isw.IndentLevel++;

            var itemCnt = 1;
            foreach (var v in vectors)
            {
                isw.Write("{0}f, {1}f, {2}f", v.x, v.y, v.z);
                isw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns <see cref="Vector4"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="vectors"><see cref="Vector4"/> array to embed in C# code.</param>
        private static void EmitMethodLoadVector4Array(IndentStreamWriter isw, string methodName, string itemName, Vector4[] vectors)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Load {0} data.", itemName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <returns><see cref=\"Vector3\"/> array of {0}.</returns>", itemName);
            isw.WriteLine("private static Vector4[] {0}()", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            isw.WriteLine("return ConvertArray<Vector4>(new []");
            isw.WriteLine("{");
            isw.IndentLevel++;

            var itemCnt = 1;
            foreach (var v in vectors)
            {
                isw.Write("{0}f, {1}f, {2}f, {3}f", v.x, v.y, v.z, v.w);
                isw.WriteLine(itemCnt < vectors.Length ? "," : "");
                itemCnt++;
            }

            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns embedded <see cref="int"/> array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="data"><see cref="int"/> array to embed in C# code.</param>
        /// <param name="nCols">Number of rows.</param>
        private static void EmitMethodLoadIntArray(IndentStreamWriter isw, string methodName, string itemName, int[] data, int nCols)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Load {0} data.", itemName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <returns><see cref=\"int\"/> array of {0}.</returns>", itemName);
            isw.WriteLine("private static int[] {0}()", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            isw.WriteLine("return new []");
            isw.WriteLine("{");
            isw.IndentLevel++;

            for (int i = 0; i < data.Length; i++)
            {
                if (i % nCols == 0)
                {
                    if (i > 0)
                    {
                        if (i < data.Length - 1)
                        {
                            // Comma at the end of line
                            isw.Write(",");
                        }
                        isw.WriteLine();
                    }
                }
                else
                {
                    isw.Write(", ");
                }
                isw.Write(data[i]);
            }

            isw.WriteLine();

            isw.IndentLevel--;
            isw.WriteLine("};");  // End of array

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns <see cref="Color"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="colors"><see cref="Color"/> array to embed in C# code.</param>
        /// <param name="isIncludeAlpha">True to embed alpha component into C# code.</param>
        private static void EmitMethodLoadColorArray(IndentStreamWriter isw, string methodName, string itemName, Color[] colors, bool isIncludeAlpha = true)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Load {0} data.", itemName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <returns><see cref=\"Color\"/> array of {0}.</returns>", itemName);
            isw.WriteLine("private static Color[] {0}()", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            if (isIncludeAlpha)
            {
                isw.WriteLine("return ConvertArray<Color>(new []");
                isw.WriteLine("{");
                isw.IndentLevel++;

                var itemCnt = 1;
                foreach (var c in colors)
                {
                    isw.Write("{0}f, {1}f, {2}f, {3}f", c.r, c.g, c.b, c.a);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }
            else
            {
                isw.WriteLine("return ConvertRGBArray(new []");
                isw.WriteLine("{");
                isw.IndentLevel++;

                var itemCnt = 1;
                foreach (var c in colors)
                {
                    isw.Write("{0}f, {1}f, {2}f", c.r, c.g, c.b);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }
            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit a method which returns <see cref="Color32"/> array created from embedded <see cref="float"/> array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="methodName">Name of method.</param>
        /// <param name="itemName">Item name to write in doc. comment.</param>
        /// <param name="colors"><see cref="Color32"/> array to embed in C# code.</param>
        /// <param name="isIncludeAlpha">True to embed alpha component into C# code.</param>
        private static void EmitMethodLoadColorArray(IndentStreamWriter isw, string methodName, string itemName, Color32[] colors, bool isIncludeAlpha = true)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Load {0} data.", itemName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <returns><see cref=\"Color32\"/> array of {0}.</returns>", itemName);
            isw.WriteLine("private static Color32[] {0}()", methodName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            if (isIncludeAlpha)
            {
                isw.WriteLine("return ConvertArray<Color32>(new byte[]");
                isw.WriteLine("{");
                isw.IndentLevel++;

                var itemCnt = 1;
                foreach (var c in colors)
                {
                    isw.Write("{0}, {1}, {2}, {3}", c.r, c.g, c.b, c.a);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }
            else
            {
                isw.WriteLine("return ConvertRGBArray(new byte[]");
                isw.WriteLine("{");
                isw.IndentLevel++;

                var itemCnt = 1;
                foreach (var c in colors)
                {
                    isw.Write("{0}, {1}, {2}", c.r, c.g, c.b);
                    isw.WriteLine(itemCnt < colors.Length ? "," : "");
                    itemCnt++;
                }
            }
            isw.IndentLevel--;
            isw.WriteLine("});");  // End of method call

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit ConvertArray method which converts <see cref="float"/> array to specified type array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="primTypeName">Type name of source array.</param>
        private static void EmitMethodConvertArray(IndentStreamWriter isw, string primTypeName)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Convert {0} array to a specified type array.", primTypeName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <typeparam name=\"T\">Destination type of array.</param>");
            isw.WriteLine("/// <param name=\"data\">Source data array.</param>");
            isw.WriteLine("/// <returns>Converted array.</returns>");
            isw.WriteLine("private static T[] ConvertArray<T>({0}[] data)", primTypeName);
            isw.IndentLevel++;
            isw.WriteLine("where T : struct");
            isw.IndentLevel--;
            isw.WriteLine("{");
            isw.IndentLevel++;

            isw.WriteLine("var dstData = new T[data.Length / (Marshal.SizeOf<T>() / sizeof({0}))];", primTypeName);
            isw.WriteLine("var gch = GCHandle.Alloc(dstData, GCHandleType.Pinned);");
            isw.WriteLine("try");
            isw.WriteLine("{");
            isw.IndentLevel++;
            isw.WriteLine("Marshal.Copy(data, 0, gch.AddrOfPinnedObject(), data.Length);");
            isw.IndentLevel--;
            isw.WriteLine("}");
            isw.WriteLine("finally");
            isw.WriteLine("{");
            isw.IndentLevel++;
            isw.WriteLine("gch.Free();");
            isw.IndentLevel--;
            isw.WriteLine("}");
            isw.WriteLine("return dstData;");

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }

        /// <summary>
        /// Emit ConvertArray method which converts array of RGB components to <see cref="Color"/> or <see cref="Color32"/> array.
        /// </summary>
        /// <param name="isw">Destination <see cref="IndentStreamWriter"/>.</param>
        /// <param name="srcTypeName">Type name of source array.</param>
        /// <param name="dstTypeName">Type name of destination array.</param>
        private static void EmitMethodConvertRGBArray(IndentStreamWriter isw, string srcTypeName, string dstTypeName)
        {
            isw.WriteLine("/// <summary>");
            isw.WriteLine("/// Convert <see cref=\"{0}\"/> array of RGB components to a <see cref=\"{1}\"/> array.", srcTypeName, dstTypeName);
            isw.WriteLine("/// </summary>");
            isw.WriteLine("/// <param name=\"data\">Source data array.</param>");
            isw.WriteLine("/// <returns>Converted array.</returns>");
            isw.WriteLine("private static {0}[] ConvertRGBArray({1}[] data)", dstTypeName, srcTypeName);
            isw.WriteLine("{");
            isw.IndentLevel++;

            isw.WriteLine("var colors = new {0}[data.Length / 3];", dstTypeName);
            isw.WriteLine("for (int i = 0; i < colors.Length; i++)");
            isw.WriteLine("{");
            isw.IndentLevel++;

            isw.WriteLine("var j = i * 3;");
            isw.WriteLine("colors[i] = new {1}(data[j], data[j + 1], data[j + 2]);", srcTypeName);

            isw.IndentLevel--;
            isw.WriteLine("}");
            isw.WriteLine("return colors;");

            isw.IndentLevel--;
            isw.WriteLine("}");  // End of method
        }
    }
}
