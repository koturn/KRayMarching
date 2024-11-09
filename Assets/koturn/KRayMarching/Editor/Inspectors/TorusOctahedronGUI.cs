using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// CustomEditor of "koturn/KRayMarching/TorusSixOctahedron" and "koturn/KRayMarching/TorusEightOctahedron".
    /// </summary>
    public class TorusOctahedronGUI : KRayMarchingBaseGUI
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
        /// Property name of "_UseFastInvTriFunc".
        /// </summary>
        private const string PropNameUseFastInvTriFunc = "_UseFastInvTriFunc";

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
                ShaderProperty(me, mps, PropNameUseFastInvTriFunc, false);
            }
        }
    }
}
