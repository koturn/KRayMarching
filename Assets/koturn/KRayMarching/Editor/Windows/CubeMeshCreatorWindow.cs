using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using Koturn.KRayMarching;
using Koturn.KRayMarching.Enums;


namespace Koturn.KRayMarching.Windows
{
    /// <summary>
    /// Cube mesh/
    /// </summary>
    public class CubeMeshCreatorWindow : EditorWindow
    {
        /// <summary>
        /// Target <see cref="GameObject"/>.
        /// </summary>
        [SerializeField]
        private GameObject _target;
        /// <summary>
        /// A flag whether add UV to the Cube Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasUV;
        /// <summary>
        /// A flag whether add Normal to the Cube Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasNormal;
        /// <summary>
        /// A flag whether add Tangent to the Cube Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasTangent;
        /// <summary>
        /// A flag whether add Vertex Color to the Cube Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasVertexColor;
        /// <summary>
        /// Quality of Cube Mesh.
        /// </summary>
        [SerializeField]
        private CubeQuality _cubeQuality;
        /// <summary>
        /// Last saved Asset Path.
        /// </summary>
        [SerializeField]
        private string _assetPath;
        /// <summary>
        /// Size of Cube.
        /// </summary>
        [SerializeField]
        private Vector3 _size;


        /// <summary>
        /// Initialize members.
        /// </summary>
        public CubeMeshCreatorWindow()
        {
            _target = null;
            _hasUV = false;
            _hasNormal = false;
            _hasTangent = false;
            _hasVertexColor = false;
            _cubeQuality = CubeQuality.Low;
            _assetPath = null;
            _size = new Vector3(1.0f, 1.0f, 1.0f);
        }

        /// <Summary>
        /// Draw window components.
        /// </Summary>
        private void OnGUI()
        {
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                using (var ccScope = new EditorGUI.ChangeCheckScope())
                {
                    var target = (GameObject)EditorGUILayout.ObjectField(_target, typeof(GameObject), true);
                    if (ccScope.changed)
                    {
                        _target = target;
                        var meshFilter = target == null ? null : target.GetComponent<MeshFilter>();
                        if (meshFilter != null)
                        {
                            _size = meshFilter.sharedMesh.bounds.size;
                        }
                    }
                    if (ccScope.changed || string.IsNullOrEmpty(_assetPath))
                    {
                        _assetPath = target == null ? "Assets/NewCubeMesh.asset"
                            : "Assets/NewCubeMesh_" + target.name + ".asset";
                    }
                }

                _size = EditorGUILayout.Vector3Field("Size: ", _size);

                using (var ccScope = new EditorGUI.ChangeCheckScope())
                {
                    _cubeQuality = (CubeQuality)EditorGUILayout.EnumPopup("Cube Quality", _cubeQuality);
                    if (ccScope.changed)
                    {
                        switch (_cubeQuality)
                        {
                            case CubeQuality.Low:
                                _hasUV = false;
                                _hasNormal = false;
                                _hasTangent = false;
                                break;
                            case CubeQuality.Middle:
                                _hasUV = true;
                                _hasNormal = false;
                                _hasTangent = false;
                                break;
                            case CubeQuality.High:
                                _hasUV = true;
                                _hasNormal = true;
                                _hasTangent = true;
                                break;
                        }
                    }
                }

                _hasUV = EditorGUILayout.ToggleLeft("Write UV", _hasUV);
                _hasNormal = EditorGUILayout.ToggleLeft("Write Normal", _hasNormal);
                _hasTangent = EditorGUILayout.ToggleLeft("Write Tangent", _hasTangent);
                _hasVertexColor = EditorGUILayout.ToggleLeft("Write Vertex Color", _hasVertexColor);

                using (new EditorGUI.DisabledScope(_target == null))
                {
                    if (GUILayout.Button("Create Mesh"))
                    {
                        OnCreateMeshButtonClicked();
                    }
                }

                string infoMessage = null;
                switch (_cubeQuality)
                {
                    case CubeQuality.Low:
                        infoMessage = "8 vertices, 12 polygons";
                        break;
                    case CubeQuality.Middle:
                        infoMessage = "12 vertices, 12 polygons";
                        break;
                    case CubeQuality.High:
                        infoMessage = "24 vertices, 12 polygons";
                        break;
                }

                if (infoMessage != null)
                {
                    EditorGUILayout.LabelField(infoMessage);
                }
            }
        }

        /// <summary>
        /// An action when button of "Create Mesh" is clicked.
        /// </summary>
        private void OnCreateMeshButtonClicked()
        {
            var assetPath = EditorUtility.SaveFilePanelInProject(
                "Save mesh",
                Path.GetFileName(_assetPath),
                "asset",
                "Enter a file name to save the mesh to",
                Path.GetDirectoryName(_assetPath));
            if (assetPath == "")
            {
                return;
            }
            _assetPath = assetPath;

            Mesh mesh;
            switch (_cubeQuality)
            {
                case CubeQuality.Low:
                    mesh = CubeMeshCreator.CreateCubeMeshLow(_size, _hasUV, _hasNormal, _hasTangent, _hasVertexColor);
                    break;
                case CubeQuality.Middle:
                    mesh = CubeMeshCreator.CreateCubeMeshMiddle(_size, _hasUV, _hasNormal, _hasTangent, _hasVertexColor);
                    break;
                case CubeQuality.High:
                    mesh = CubeMeshCreator.CreateCubeMeshHigh(_size, _hasUV, _hasNormal, _hasTangent, _hasVertexColor);
                    break;
                default:
                    throw new ArgumentOutOfRangeException("Invalid enum value of CubeQuality: " + _cubeQuality);
            }

            var target = _target;
            if (target != null)
            {
                CubeMeshCreator.ApplyMesh(target, mesh);
                CubeMeshCreator.ResizeBoxCollider(target, _size);
            }

            AssetDatabase.CreateAsset(mesh, assetPath);
            AssetDatabase.SaveAssets();
        }

        /// <summary>
        /// Open window.
        /// </summary>
        [MenuItem("GameObject/KRayMarching/Set Cube Mesh", false, 20)]
        public static void OpenWindow()
        {
            var window = EditorWindow.GetWindow<CubeMeshCreatorWindow>("Cube Mesh Creator");
            var target = Selection.activeGameObject;
            window._target = target;
            var meshFilter = target == null ? null : target.GetComponent<MeshFilter>();
            if (meshFilter != null)
            {
                window._size = meshFilter.sharedMesh.bounds.size;
            }
        }
    }
}
