using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching;


namespace Koturn.KRayMarching.Primitive
{
    /// <summary>
    /// Custom editor for "koturn/KRayMarching/Primitive/HexPrism"
    /// and "koturn/KRayMarching/Primitive/TriPrism".
    /// </summary>
    public class PrismGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_Size".
        /// </summary>
        private const string PropNameSize = "_Size";
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
                ShaderProperty(me, mps, PropNameSize);
                ShaderProperty(me, mps, PropNameHeight);
            }
        }
    }
}
