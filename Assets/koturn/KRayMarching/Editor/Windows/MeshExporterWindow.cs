using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using Koturn.KRayMarching.Enums;


namespace Koturn.KRayMarching.Windows
{
    /// <summary>
    /// Mesh Analyzer Window.
    /// </summary>
    public class MeshExporterWindow : EditorWindow
    {
        /// <summary>
        /// Target object.
        /// </summary>
        [SerializeField]
        private GameObject _target;
        /// <summary>
        /// Last saved path.
        /// </summary>
        [SerializeField]
        private string _filePath;
        /// <summary>
        /// Color Format.
        /// </summary>
        [SerializeField]
        private ColorFormat _colorFormat;


        /// <summary>
        /// Initialize members.
        /// </summary>
        public MeshExporterWindow()
        {
            _target = null;
            _filePath = string.Empty;
            _colorFormat = ColorFormat.RGBAFloat;
        }

        /// <summary>
        /// Draw window components.
        /// </summary>
        private void OnGUI()
        {
            using (new EditorGUILayout.VerticalScope("Box"))
            {
                using (var ccScope = new EditorGUI.ChangeCheckScope())
                {
                    var target = (GameObject)EditorGUILayout.ObjectField(_target, typeof(GameObject), true);
                    if (ccScope.changed)
                    {
                        _target = target;
                    }
                    if (ccScope.changed || string.IsNullOrEmpty(_filePath))
                    {
                        _filePath = (target == null ? string.Empty : ReplaceInvalidFileNameChars(target.name, "_")) + "MeshCreator";
                    }
                }
                _colorFormat = (ColorFormat)EditorGUILayout.EnumPopup("Color Format", _colorFormat);

                var mesh = _target == null ? null : _target.GetComponent<MeshFilter>().sharedMesh;

                using (new EditorGUI.DisabledScope(mesh == null))
                {
                    EditorGUILayout.LabelField("CSV", EditorStyles.boldLabel);
                    using (new EditorGUI.IndentLevelScope())
                    {
                        if (GUILayout.Button("Export mesh as CSV"))
                        {
                            OnExportMeshAsCsvButtonClicked();
                        }
                    }

                    EditorGUILayout.LabelField("C#", EditorStyles.boldLabel);
                    using (new EditorGUI.IndentLevelScope())
                    {
                        if (GUILayout.Button("Export mesh as C# (Inplace)"))
                        {
                            OnExportMeshAsCSharpInplaceButtonClicked();
                        }
                        if (GUILayout.Button("Export mesh as C#"))
                        {
                            OnExportMeshAsCSharpButtonClicked();
                        }
                    }
                }
            }
        }

        /// <summary>
        /// An action when button of "Export mesh as CSV" is clicked.
        /// </summary>
        private void OnExportMeshAsCsvButtonClicked()
        {
            var mesh = _target == null ? null : _target.GetComponent<MeshFilter>().sharedMesh;
            if (mesh == null)
            {
                Debug.LogError("Mesh not found.");
                return;
            }

            var fileName = Path.GetFileName(_filePath);
            var filePath = EditorUtility.SaveFilePanel(
                "Save mesh",
                Path.GetDirectoryName(_filePath),
                fileName == "" ? "MeshInfo.csv" : fileName,
                "csv");
            if (filePath == "")
            {
                return;
            }
            _filePath = filePath;
            MeshExporter.WriteMeshInfo(mesh, filePath, _colorFormat);
        }

        /// <summary>
        /// An action when button of "Export mesh as C# (Inplace)" is clicked.
        /// </summary>
        private void OnExportMeshAsCSharpInplaceButtonClicked()
        {
            var mesh = _target == null ? null : _target.GetComponent<MeshFilter>().sharedMesh;
            if (mesh == null)
            {
                Debug.LogError("Mesh not found.");
                return;
            }

            var fileName = Path.GetFileName(_filePath);
            var filePath = EditorUtility.SaveFilePanel(
                "Save mesh",
                Path.GetDirectoryName(_filePath),
                fileName == "" ? "MeshCreator.cs" : fileName,
                "cs");
            if (filePath == "")
            {
                return;
            }
            _filePath = filePath;
            MeshExporter.WriteMeshCreateMethodInplace(
                mesh,
                filePath,
                "    ",
                "ExportedMeshes",
                ReplaceInvalidClassNameChars(Path.GetFileNameWithoutExtension(filePath), "_"),
                _colorFormat);
        }

        /// <summary>
        /// An action when button of "Export mesh as C#" is clicked.
        /// </summary>
        private void OnExportMeshAsCSharpButtonClicked()
        {
            var mesh = _target == null ? null : _target.GetComponent<MeshFilter>().sharedMesh;
            if (mesh == null)
            {
                Debug.LogError("Mesh not found.");
                return;
            }

            var fileName = Path.GetFileName(_filePath);
            var filePath = EditorUtility.SaveFilePanel(
                "Save mesh",
                Path.GetDirectoryName(_filePath),
                fileName == "" ? "MeshCreator.cs" : fileName,
                "cs");
            if (filePath == "")
            {
                return;
            }
            _filePath = filePath;
            MeshExporter.WriteMeshCreateMethod(
                mesh,
                filePath,
                "    ",
                "ExportedMeshes",
                ReplaceInvalidClassNameChars(Path.GetFileNameWithoutExtension(filePath), "_"),
                _colorFormat);
        }


        /// <summary>
        /// Replace characters that cannot be used as file name.
        /// </summary>
        /// <param name="input">Source text.</param>
        /// <param name="replacement">The replacement string.</param>
        /// <returns>Replaced text.</returns>
        private static string ReplaceInvalidFileNameChars(string input, string replacement)
        {
            var sb = new StringBuilder(input.Length);
            var invalidChars = Path.GetInvalidFileNameChars();
            foreach (var c1 in input)
            {
                var isFoundInvalidChar = false;
                foreach (var c2 in invalidChars)
                {
                    if (c1 == c2)
                    {
                        isFoundInvalidChar = true;
                        break;
                    }
                }
                if (isFoundInvalidChar)
                {
                    sb.Append(replacement);
                }
                else
                {
                    sb.Append(c1);
                }
            }

            return sb.ToString();
        }

        /// <summary>
        /// Replace characters that cannot be used as class name.
        /// </summary>
        /// <param name="input">Source string.</param>
        /// <param name="replacement">The replacement string.</param>
        /// <returns>Replaced text.</returns>
        private static string ReplaceInvalidClassNameChars(string input, string replacement)
        {
            return Regex.Replace(input, @"^\d|\W", replacement);
        }

        /// <summary>
        /// Open window.
        /// </summary>
        [MenuItem("GameObject/KRayMarching/Mesh Analyzer", false, 21)]
        public static void OpenWindow()
        {
            var window = GetWindow<MeshExporterWindow>("Mesh Analyzer");
            window._target = Selection.activeGameObject;
        }
    }
}
