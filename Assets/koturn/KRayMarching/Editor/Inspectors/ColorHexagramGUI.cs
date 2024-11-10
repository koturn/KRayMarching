using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// CustomEditor of "koturn/KRayMarching/ColorHexagram".
    /// </summary>
    public sealed class ColorHexagramGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_TorusRadius".
        /// </summary>
        private const string PropNameTorusRadius = "_TorusRadius";
        /// <summary>
        /// Property name of "_TorusRadiusAmp".
        /// </summary>
        private const string PropNameTorusRadiusAmp = "_TorusRadiusAmp";
        /// <summary>
        /// Property name of "_TorusWidth".
        /// </summary>
        private const string PropNameTorusWidth = "_TorusWidth";
        /// <summary>
        /// Property name of "_OctahedronSize".
        /// </summary>
        private const string PropNameOctahedronSize = "_OctahedronSize";
        /// <summary>
        /// Property name of "_LineColorMultiplier".
        /// </summary>
        private const string PropNameLineColorMultiplier = "_LineColorMultiplier";

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
                ShaderProperty(me, mps, PropNameTorusRadius, false);
                ShaderProperty(me, mps, PropNameTorusRadiusAmp, false);
                ShaderProperty(me, mps, PropNameTorusWidth, false);
                ShaderProperty(me, mps, PropNameOctahedronSize, false);
                ShaderProperty(me, mps, PropNameLineColorMultiplier, false);
            }
        }
    }
}
