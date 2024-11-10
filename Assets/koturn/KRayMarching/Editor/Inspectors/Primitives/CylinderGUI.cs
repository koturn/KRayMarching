using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// CustomEditor for "koturn/KRayMarching/Primitives/Cylinder",
    /// </summary>
    public sealed class CylinderGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Center".
        /// </summary>
        private const string PropNameCenter = "_Center";
        /// <summary>
        /// Property name of "_Radius".
        /// </summary>
        private const string PropNameRadius = "_Radius";

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
                ShaderProperty(me, mps, PropNameCenter);
                ShaderProperty(me, mps, PropNameRadius);
            }
        }
    }
}
