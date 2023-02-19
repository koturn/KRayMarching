using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching;


namespace Koturn.KRayMarching.Primitive
{
    /// <summary>
    /// Custom editor for "koturn/KRayMarching/Primitive/Torus",
    /// </summary>
    public class TorusGUI : KRayMarchingBaseGUI
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
            }
        }
    }
}
