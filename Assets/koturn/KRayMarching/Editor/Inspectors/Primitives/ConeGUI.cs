using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// CustomEditor for "koturn/KRayMarching/Primitives/Cone",
    /// "koturn/KRayMarching/Primitives/InfinityCone",
    /// and "koturn/KRayMarching/Primitives/SolidAngle".
    /// </summary>
    public sealed class ConeGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Angle".
        /// </summary>
        private const string PropNameAngle = "_Angle";
        /// <summary>
        /// Property name of "_Height".
        /// </summary>
        private const string PropNameHeight = "_Height";
        /// <summary>
        /// Property name of "_NotExact".
        /// </summary>
        private const string PropNameNotExact = "_NotExact";

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
                ShaderProperty(me, mps, PropNameAngle);
                ShaderProperty(me, mps, PropNameHeight, false);
                ShaderProperty(me, mps, PropNameNotExact, false);
            }
        }
    }
}
