using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using Koturn.KRayMarching;
using Koturn.KRayMarching.Enums;


namespace Koturn.KRayMarching.Windows
{
    /// <summary>
    /// Quad mesh/
    /// </summary>
    public class QuadMeshCreatorWindow : EditorWindow
    {
        /// <summary>
        /// Target <see cref="GameObject"/>.
        /// </summary>
        [SerializeField]
        private GameObject _target;
        /// <summary>
        /// A flag whether add UV to the Quad Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasUV;
        /// <summary>
        /// A flag whether add Normal to the Quad Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasNormal;
        /// <summary>
        /// A flag whether add Tangent to the Quad Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasTangent;
        /// <summary>
        /// A flag whether add Vertex Color to the Quad Mesh or not.
        /// </summary>
        [SerializeField]
        private bool _hasVertexColor;
        /// <summary>
        /// A flag whether create back face polygon ot not.
        /// </summary>
        [SerializeField]
        private bool _isDoubleSide;
        /// <summary>
        /// A flag whether to prevent Z-Fighting when use Culling-Off shader.
        /// </summary>
        [SerializeField]
        private bool _isPreventZFighting;
        /// <summary>
        /// Last saved Asset Path.
        /// </summary>
        [SerializeField]
        private string _assetPath;
        /// <summary>
        /// Size of Quad.
        /// </summary>
        [SerializeField]
        private Vector2 _size;


        /// <summary>
        /// Initialize members.
        /// </summary>
        public QuadMeshCreatorWindow()
        {
            _target = null;
            _hasUV = false;
            _hasNormal = false;
            _hasTangent = false;
            _hasVertexColor = false;
            _isDoubleSide = false;
            _isPreventZFighting = false;
            _assetPath = null;
            _size = new Vector2(1.0f, 1.0f);
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
                            _size = (Vector2)meshFilter.sharedMesh.bounds.size;
                        }
                    }
                    if (ccScope.changed || string.IsNullOrEmpty(_assetPath))
                    {
                        _assetPath = target == null ? "Assets/NewQuadMesh.asset"
                            : "Assets/NewQuadMesh_" + target.name + ".asset";
                    }
                }

                _size = EditorGUILayout.Vector2Field("Size: ", _size);

                _isDoubleSide = EditorGUILayout.ToggleLeft("Double Side", _isDoubleSide);
                using (new EditorGUI.IndentLevelScope())
                using (new EditorGUI.DisabledScope(!_isDoubleSide))
                {
                    _isPreventZFighting = EditorGUILayout.ToggleLeft("Prevent Z-Fighting for Culling Off", _isPreventZFighting);
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

                EditorGUILayout.LabelField(_isDoubleSide
                    ? "8 vertices, 4 polygons"
                    : "4 vertices, 2 polygons");
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

            var mesh = _isDoubleSide
                ? QuadMeshCreator.CreateQuadMeshDoubleSide(_size, _hasUV, _hasNormal, _hasTangent, _hasVertexColor, _isPreventZFighting)
                : QuadMeshCreator.CreateQuadMesh(_size, _hasUV, _hasNormal, _hasTangent, _hasVertexColor);

            var target = _target;
            if (target != null)
            {
                QuadMeshCreator.ApplyMesh(target, mesh);
                QuadMeshCreator.ResizeBoxCollider(target, _size);
            }

            AssetDatabase.CreateAsset(mesh, assetPath);
            AssetDatabase.SaveAssets();
        }

        /// <summary>
        /// Open window.
        /// </summary>
        [MenuItem("GameObject/KRayMarching/Set Quad Mesh", false, 21)]
        public static void OpenWindow()
        {
            var window = EditorWindow.GetWindow<QuadMeshCreatorWindow>("Quad Mesh Creator");
            var target = Selection.activeGameObject;
            window._target = target;
            var meshFilter = target == null ? null : target.GetComponent<MeshFilter>();
            if (meshFilter != null)
            {
                window._size = (Vector2)meshFilter.sharedMesh.bounds.size;
            }
        }
    }
}
