using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Inspectors;


namespace Koturn.KRayMarching.Inspectors.Primitives
{
    /// <summary>
    /// Custom editor for "koturn/KRayMarching/Primitives/Box",
    /// "koturn/KRayMarching/Primitives/RoundBox" and "koturn/KRayMarching/Primitives/BoxFrame"
    /// </summary>
    public class BoxGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Size".
        /// </summary>
        private const string PropNameSize = "_Size";
        /// <summary>
        /// Property name of "_FrameSize".
        /// </summary>
        private const string PropNameFrameSize = "_FrameSize";
        /// <summary>
        /// Property name of "_Round".
        /// </summary>
        private const string PropNameRound = "_Round";

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
                ShaderProperty(me, mps, PropNameSize);
                ShaderProperty(me, mps, PropNameFrameSize, false);
                ShaderProperty(me, mps, PropNameRound, false);
            }
        }
    }
}
