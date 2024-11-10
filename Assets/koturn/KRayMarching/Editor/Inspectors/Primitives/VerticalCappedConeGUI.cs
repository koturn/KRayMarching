using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// CustomEditor for "koturn/KRayMarching/Primitives/VerticalCappedCone"
    /// and "koturn/KRayMarching/Primitives/VerticalRoundCone".
    /// </summary>
    public sealed class VerticalCappedConeGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Height".
        /// </summary>
        private const string PropNameHeight = "_Height";
        /// <summary>
        /// Property name of "_Radius1".
        /// </summary>
        private const string PropNameRadius1 = "_Radius1";
        /// <summary>
        /// Property name of "_Radius2".
        /// </summary>
        private const string PropNameRadius2 = "_Radius2";

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
                ShaderProperty(me, mps, PropNameRadius1);
                ShaderProperty(me, mps, PropNameRadius2);
            }
        }
    }
}
