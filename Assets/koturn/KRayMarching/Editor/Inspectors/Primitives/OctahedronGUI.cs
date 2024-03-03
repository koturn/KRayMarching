using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// Custom editor for "koturn/KRayMarching/Primitives/Octahedron".
    /// </summary>
    public class OctahedronGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Size".
        /// </summary>
        private const string PropNameSize = "_Size";
        /// <summary>
        /// Property name of "_OctahedronScales".
        /// </summary>
        private const string PropNameOctahedronScales = "_OctahedronScales";
        /// <summary>
        /// Property name of "_Exact".
        /// </summary>
        private const string PropNameExact = "_Exact";

        /// <summary>
        /// Draw custom properties.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        protected override void DrawCustomProperties(MaterialEditor me, MaterialProperty[] mps)
        {
            EditorGUILayout.LabelField("SDF Parameters", EditorStyles.boldLabel);

            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameSize);
                ShaderProperty(me, mps, PropNameOctahedronScales);
                ShaderProperty(me, mps, PropNameExact);
            }
        }
    }
}
