using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// CustomEditor of "koturn/KRayMarching/DomainOctahedrons".
    /// </summary>
    public sealed class DomainOctahedronsGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_GridSize".
        /// </summary>
        private const string PropNameGridSize = "_GridSize";
        /// <summary>
        /// Property name of "_OctahedronSize".
        /// </summary>
        private const string PropNameOctahedronSize = "_OctahedronSize";
        /// <summary>
        /// Property name of "_AnimSpeed".
        /// </summary>
        private const string PropNameAnimSpeed = "_AnimSpeed";
        /// <summary>
        /// Property name of "_SpinSpeedRange".
        /// </summary>
        private const string PropNameSpinSpeedRange = "_SpinSpeedRange";

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
                ShaderProperty(me, mps, PropNameGridSize);
                ShaderProperty(me, mps, PropNameOctahedronSize);
                ShaderProperty(me, mps, PropNameAnimSpeed);
                ShaderProperty(me, mps, PropNameSpinSpeedRange);
            }
        }
    }
}
