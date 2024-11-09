using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// CustomEditor for "koturn/KRayMarching/Primitives/VerticalCapsule",
    /// "koturn/KRayMarching/Primitives/VerticalCappedCylinder"
    /// and "koturn/KRayMarching/Primitives/RoundedCappedCylinder".
    /// </summary>
    public class VerticalCapsuleCylinderGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Height".
        /// </summary>
        private const string PropNameHeight = "_Height";
        /// <summary>
        /// Property name of "_Round".
        /// </summary>
        private const string PropNameRound = "_Round";
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
                ShaderProperty(me, mps, PropNameHeight);
                ShaderProperty(me, mps, PropNameRadius);
                ShaderProperty(me, mps, PropNameRound, false);
            }
        }
    }
}

