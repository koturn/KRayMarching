using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// CustomEditor for "koturn/KRayMarching/Primitives/Plane".
    /// </summary>
    public sealed class PlaneGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Normal".
        /// </summary>
        private const string PropNameNormal = "_Normal";
        /// <summary>
        /// Property name of "_Height".
        /// </summary>
        private const string PropNameHeight = "_Height";

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
                ShaderProperty(me, mps, PropNameNormal);
                ShaderProperty(me, mps, PropNameHeight);
            }
        }
    }
}
