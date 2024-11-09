using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// CustomEditor for "koturn/KRayMarching/Primitives/Sphere",
    /// "koturn/KRayMarching/Primitives/CutSphere"
    /// and "koturn/KRayMarching/Primitives/CutHollowSphere".
    /// </summary>
    public class SphereGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Radius".
        /// </summary>
        private const string PropNameRadius = "_Radius";
        /// <summary>
        /// Property name of "_Height".
        /// </summary>
        private const string PropNameHeight = "_Height";
        /// <summary>
        /// Property name of "_CutHeight".
        /// </summary>
        private const string PropNameCutHeight = "_CutHeight";
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
                ShaderProperty(me, mps, PropNameHeight, false);
                ShaderProperty(me, mps, PropNameCutHeight, false);
                ShaderProperty(me, mps, PropNameThickness, false);
            }
        }
    }
}
