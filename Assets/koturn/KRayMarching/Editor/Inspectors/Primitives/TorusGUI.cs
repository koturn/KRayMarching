using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// CustomEditor for "koturn/KRayMarching/Primitives/Torus",
    /// </summary>
    public sealed class TorusGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Radius".
        /// </summary>
        private const string PropNameRadius = "_Radius";
        /// <summary>
        /// Property name of "_Thickness".
        /// </summary>
        private const string PropNameThickness = "_Thickness";
        /// <summary>
        /// Property name of "_Angle".
        /// </summary>
        private const string PropNameAngle = "_Angle";

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
                ShaderProperty(me, mps, PropNameRadius);
                ShaderProperty(me, mps, PropNameThickness);
                ShaderProperty(me, mps, PropNameAngle, false);
            }
        }
    }
}
