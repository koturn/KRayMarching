using UnityEditor;
using UnityEngine;


namespace Koturn.KRayMarching.Drawers
{
    /// <summary>
    /// Custom material property for ColorMask.
    /// </summary>
    public sealed class ColorMaskDrawer : MaterialPropertyDrawer
    {
        private static readonly string[] ColorMasks = { "None", "A", "B", "BA", "G", "GA", "GB", "GBA", "R", "RA", "RB", "RBA", "RG", "RGA", "RGB", "RGBA" };

        /// <summary>
        /// Draw ColorMask property.
        /// </summary>
        /// <param name="position">Rectangle on the screen to use for the property GUI.</param>
        /// <param name="prop">The <see cref="MaterialProperty"/> to make the custom GUI for.</param>
        /// <param name="label">The label of this property.</param>
        /// <param name="editor">Current material editor.</param>
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            using (var ccScope = new EditorGUI.ChangeCheckScope())
            {
                EditorGUI.showMixedValue = prop.hasMixedValue;
                var index = EditorGUI.Popup(position, label, (int)prop.floatValue, ColorMasks);
                EditorGUI.showMixedValue = false;
                if (ccScope.changed)
                {
                    prop.floatValue = index;
                }
            }
        }
    }
}
