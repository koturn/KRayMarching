using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// Custom editor for "koturn/KRayMarching/Primitives/Link",
    /// </summary>
    public class LinkGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Height".
        /// </summary>
        private const string PropNameHeight = "_Height";
        /// <summary>
        /// Property name of "_Size".
        /// </summary>
        private const string PropNameSize = "_Size";
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
                ShaderProperty(me, mps, PropNameHeight);
                ShaderProperty(me, mps, PropNameSize);
                ShaderProperty(me, mps, PropNameThickness);
            }
        }
    }
}
