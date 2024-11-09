using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// CustomEditor of "koturn/KRayMarching/MengerSponge".
    /// </summary>
    public sealed class MengerSpongeGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Iteration".
        /// </summary>
        private const string PropNameIteration = "_Iteration";
        /// <summary>
        /// Property name of "_Offset".
        /// </summary>
        private const string PropNameOffset = "_Offset";
        /// <summary>
        /// Property name of "_DecayScale".
        /// </summary>
        private const string PropNameDecayScale = "_DecayScale";

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
                ShaderProperty(me, mps, PropNameIteration);
                ShaderProperty(me, mps, PropNameOffset);
                ShaderProperty(me, mps, PropNameDecayScale);
            }
        }
    }
}
