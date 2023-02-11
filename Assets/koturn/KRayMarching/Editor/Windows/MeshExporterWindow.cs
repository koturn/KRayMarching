using System.IO;
using UnityEditor;
using UnityEngine;


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
        /// Draw window components.
        /// </summary>
        private void OnGUI()
        {
            using (new EditorGUILayout.VerticalScope("Box"))
            {
                _target = (GameObject)EditorGUILayout.ObjectField(_target, typeof(GameObject), true);
                var mesh = _target == null ? null : _target.GetComponent<MeshFilter>().sharedMesh;

                using (new EditorGUI.DisabledScope(mesh == null))
                {
                    if (GUILayout.Button("Export mesh as CSV"))
                    {
                        OnExportMeshAsCsvButtonClicked();
                    }
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
            MeshExporter.WriteMeshInfo(mesh, filePath);
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
            MeshExporter.WriteMeshCreateMethodInplace(mesh, filePath, "    ", "ExportedMeshes", "MeshCreator");
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
            MeshExporter.WriteMeshCreateMethod(mesh, filePath, "    ", "ExportedMeshes", "MeshCreator");
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
