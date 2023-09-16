using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// Custom editor of RayMarching shaders.
    /// </summary>
    public class RecursiveRingsGUI : KRayMarchingBaseGUI
    {
        /// <summary>
        /// Property name of "_TorusBaseColor".
        /// </summary>
        private const string PropNameTorusBaseColor = "_TorusBaseColor";
        /// <summary>
        /// Property name of "_TorusRecursion".
        /// </summary>
        private const string PropNameTorusRecursion = "_TorusRecursion";
        /// <summary>
        /// Property name of "_TorusNumber".
        /// </summary>
        private const string PropNameTorusNumber = "_TorusNumber";
        /// <summary>
        /// Property name of "_TorusThickness".
        /// </summary>
        private const string PropNameTorusThickness = "_TorusThickness";
        /// <summary>
        /// Property name of "_TorusRadius".
        /// </summary>
        private const string PropNameTorusRadius = "_TorusRadius";
        /// <summary>
        /// Property name of "_TorusAnimSpeed".
        /// </summary>
        private const string PropNameTorusAnimSpeed = "_TorusAnimSpeed";
        /// <summary>
        /// Property name of "_TorusRadiusDecay".
        /// </summary>
        private const string PropNameTorusRadiusDecay = "_TorusRadiusDecay";
        /// <summary>
        /// Property name of "_TorusThicknessDecay".
        /// </summary>
        private const string PropNameTorusThicknessDecay = "_TorusThicknessDecay";
        /// <summary>
        /// Property name of "_TorusAnimDecay".
        /// </summary>
        private const string PropNameTorusAnimDecay = "_TorusAnimDecay";
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
                ShaderProperty(me, mps, PropNameTorusBaseColor, false);
                ShaderProperty(me, mps, PropNameTorusRecursion, false);
                ShaderProperty(me, mps, PropNameTorusNumber, false);
                ShaderProperty(me, mps, PropNameTorusThickness, false);
                ShaderProperty(me, mps, PropNameTorusRadius, false);
                ShaderProperty(me, mps, PropNameTorusAnimSpeed, false);
                ShaderProperty(me, mps, PropNameTorusRadiusDecay, false);
                ShaderProperty(me, mps, PropNameTorusThicknessDecay, false);
                ShaderProperty(me, mps, PropNameTorusAnimDecay, false);
                ShaderProperty(me, mps, PropNameUseFastInvTriFunc, false);
            }
        }
    }
}
