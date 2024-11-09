using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// CustomEditor of "koturn/KRayMarching/Beads" and "koturn/KRayMarching/CrossBeads".
    /// </summary>
    public sealed class BeadsGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_BeadsBaseColor".
        /// </summary>
        private const string PropNameBeadsBaseColor = "_BeadsBaseColor";
        /// <summary>
        /// Property name of "_BeadsNumber".
        /// </summary>
        private const string PropNameBeadsNumber = "_BeadsNumber";
        /// <summary>
        /// Property name of "_TorusThickness".
        /// </summary>
        private const string PropNameTorusThickness = "_TorusThickness";
        /// <summary>
        /// Property name of "_TorusRadius".
        /// </summary>
        private const string PropNameTorusRadius = "_TorusRadius";
        /// <summary>
        /// Property name of "_AnimSpeed".
        /// </summary>
        private const string PropNameAnimSpeed = "_AnimSpeed";
        /// <summary>
        /// Property name of "_BeadsSize".
        /// </summary>
        private const string PropNameBeadsSize = "_BeadsSize";

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
                ShaderProperty(me, mps, PropNameBeadsBaseColor);
                ShaderProperty(me, mps, PropNameBeadsNumber);
                ShaderProperty(me, mps, PropNameTorusThickness);
                ShaderProperty(me, mps, PropNameTorusRadius);
                ShaderProperty(me, mps, PropNameAnimSpeed);
                ShaderProperty(me, mps, PropNameBeadsSize);
            }
        }
    }
}
