using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;


namespace Koturn.KRayMarching
{
    /// <summary>
    /// Custom editor of RAyMarching shaders.
    /// </summary>
    public class KRayMarchingBaseGUI : ShaderGUI
    {
        /// <summary>
        /// Property name of "_Cull".
        /// </summary>
        private const string PropNameCull = "_Cull";
        /// <summary>
        /// Property name of "_ColorMask".
        /// </summary>
        private const string PropNameColorMask = "_ColorMask";
        /// <summary>
        /// Property name of "_AlphaToMask".
        /// </summary>
        private const string PropNameAlphaToMask = "_AlphaToMask";

        /// <summary>
        /// Property name of "_Color".
        /// </summary>
        private const string PropNameColor = "_Color";
        /// <summary>
        /// Property name of "_MaxLoop".
        /// </summary>
        private const string PropNameMaxLoop = "_MaxLoop";
        /// <summary>
        /// Property name of "_MaxLoopForwardAdd".
        /// </summary>
        private const string PropNameMaxLoopForwardAdd = "_MaxLoopForwardAdd";
        /// <summary>
        /// Property name of "_MaxLoopShadowCaster".
        /// </summary>
        private const string PropNameMaxLoopShadowCaster = "_MaxLoopShadowCaster";
        /// <summary>
        /// Property name of "_MinRayLength".
        /// </summary>
        private const string PropNameMinRayLength = "_MinRayLength";
        /// <summary>
        /// Property name of "_MaxRayLength".
        /// </summary>
        private const string PropNameMaxRayLength = "_MaxRayLength";
        /// <summary>
        /// Property name of "_Scales".
        /// </summary>
        private const string PropNameScales = "_Scales";
        /// <summary>
        /// Property name of "_MarchingFactor".
        /// </summary>
        private const string PropNameMarchingFactor = "_MarchingFactor";

        /// <summary>
        /// Property name of "_LightingMethod".
        /// </summary>
        private const string PropNameLightingMethod = "_LightingMethod";
        /// <summary>
        /// Property name of "_SpecColor".
        /// </summary>
        private const string PropNameSpecColor = "_SpecColor";
        /// <summary>
        /// Property name of "_SpecPower".
        /// </summary>
        private const string PropNameSpecPower = "_SpecPower";
        /// <summary>
        /// Property name of "_EnableRefProbe".
        /// </summary>
        private const string PropNameEnableReflectionProbe = "_EnableReflectionProbe";
        /// <summary>
        /// Property name of "_Glossiness".
        /// </summary>
        private const string PropNameGlossiness = "_Glossiness";
        /// <summary>
        /// Property name of "_Metallic".
        /// </summary>
        private const string PropNameMetallic = "_Metallic";
        /// <summary>
        /// Property name of "_DiffuseMode".
        /// </summary>
        private const string PropNameDiffuseMode = "_DiffuseMode";
        /// <summary>
        /// Property name of "_SpecularMode".
        /// </summary>
        private const string PropNameSpecularMode = "_SpecularMode";
        /// <summary>
        /// Property name of "_AmbientMode".
        /// </summary>
        private const string PropNameAmbientMode = "_AmbientMode";
        /// <summary>
        /// Property name of "_NormalCalcMode".
        /// </summary>
        private const string PropNameNormalCalcMethod = "_NormalCalcMethod";
        /// <summary>
        /// Property name of "_NormalCalcOptimize".
        /// </summary>
        private const string PropNameNormalCalcOptimize = "_NormalCalcOptimize";

        /// <summary>
        /// Draw property items.
        /// </summary>
        /// <param name="me">The <see cref="MaterialEditor"/> that are calling this <see cref="OnGUI(MaterialEditor, MaterialProperty[])"/> (the 'owner').</param>
        /// <param name="mps">Material properties of the current selected shader.</param>
        public override void OnGUI(MaterialEditor me, MaterialProperty[] mps)
        {
            EditorGUILayout.LabelField("Ray Marching Parameters", EditorStyles.boldLabel);
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameMaxLoop, false);
                ShaderProperty(me, mps, PropNameMaxLoopForwardAdd, false);
                ShaderProperty(me, mps, PropNameMaxLoopShadowCaster, false);
                ShaderProperty(me, mps, PropNameMinRayLength, false);
                ShaderProperty(me, mps, PropNameMaxRayLength, false);
                ShaderProperty(me, mps, PropNameScales, false);
                ShaderProperty(me, mps, PropNameMarchingFactor, false);
            }

            EditorGUILayout.LabelField("Lighting Parameters", EditorStyles.boldLabel);
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameColor, false);

                var mpLightingMethod = FindAndDrawProperty(me, mps, PropNameLightingMethod, false);
                var lightingMethod = (LightingMethod)(mpLightingMethod == null ? -1 : (int)mpLightingMethod.floatValue);


                var isNeedGM = true;
                var mpEnableReflectionProbe = FindAndDrawProperty(me, mps, PropNameEnableReflectionProbe, false);
                if (mpEnableReflectionProbe != null)
                {
                    isNeedGM = (mpEnableReflectionProbe.floatValue >= 0.5f);
                }

                using (new EditorGUI.DisabledScope(!isNeedGM))
                {
                    using (new EditorGUI.DisabledScope(lightingMethod == LightingMethod.UnityLambert))
                    {
                        ShaderProperty(me, mps, PropNameGlossiness, false);
                    }
                    using (new EditorGUI.DisabledScope(lightingMethod != LightingMethod.UnityStandard))
                    {
                        ShaderProperty(me, mps, PropNameMetallic, false);
                    }
                }

                using (new EditorGUI.DisabledScope(lightingMethod == LightingMethod.UnityLambert))
                {
                    ShaderProperty(me, mps, PropNameSpecColor, false);
                    ShaderProperty(me, mps, PropNameSpecPower, false);
                }

                using (new EditorGUI.DisabledScope(lightingMethod != LightingMethod.Custom))
                {
                    ShaderProperty(me, mps, PropNameDiffuseMode, false);
                    ShaderProperty(me, mps, PropNameSpecularMode, false);
                    ShaderProperty(me, mps, PropNameAmbientMode, false);
                }

                var mpNormalCalcMethod = FindProperty(PropNameNormalCalcMethod, mps, false);
                var mpNormalCalcOptimize = FindProperty(PropNameNormalCalcOptimize, mps, false);
                if (mpNormalCalcMethod != null && mpNormalCalcOptimize != null)
                {
                    EditorGUILayout.LabelField("Normal Calculation Options", EditorStyles.boldLabel);
                    using (new EditorGUI.IndentLevelScope())
                    using (new EditorGUILayout.VerticalScope(GUI.skin.box))
                    {
                        ShaderProperty(me, mpNormalCalcMethod);
                        ShaderProperty(me, mpNormalCalcOptimize);
                    }
                }
            }

            DrawCustomProperties(me, mps);

            EditorGUILayout.LabelField("Rendering Options", EditorStyles.boldLabel);
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameCull, false);
                ShaderProperty(me, mps, PropNameColorMask, false);
                ShaderProperty(me, mps, PropNameAlphaToMask, false);

                EditorGUILayout.Space();

                DrawAdvancedOptions(me, mps);
            }
        }

        /// <summary>
        /// Draw custom properties.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        protected virtual void DrawCustomProperties(MaterialEditor me, MaterialProperty[] mps)
        {
            // Do nothing.
        }

        /// <summary>
        /// Draw default item of specified shader property.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        /// <param name="propName">Name of shader property.</param>
        /// <param name="isMandatory">If <c>true</c> then this method will throw an exception
        /// if a property with <<paramref name="propName"/> was not found.</param>
        protected static void ShaderProperty(MaterialEditor me, MaterialProperty[] mps, string propName, bool isMandatory = true)
        {
            var prop = FindProperty(propName, mps, isMandatory);
            if (prop != null)
            {
                ShaderProperty(me, prop);
            }
        }

        /// <summary>
        /// Draw default item of specified shader property.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mp">Target <see cref="MaterialProperty"/>.</param>
        protected static void ShaderProperty(MaterialEditor me, MaterialProperty mp)
        {
            if (mp != null)
            {
                me.ShaderProperty(mp, mp.displayName);
            }
        }

        /// <summary>
        /// Draw default item of specified shader property and return the property.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        /// <param name="propName">Name of shader property.</param>
        /// <param name="isMandatory">If <c>true</c> then this method will throw an exception
        /// if a property with <<paramref name="propName"/> was not found.</param>
        /// <return>Found property.</return>
        protected static MaterialProperty FindAndDrawProperty(MaterialEditor me, MaterialProperty[] mps, string propName, bool isMandatory = true)
        {
            var prop = FindProperty(propName, mps, isMandatory);
            if (prop != null)
            {
                ShaderProperty(me, prop);
            }

            return prop;
        }

        /// <summary>
        /// Draw inspector items of advanced options.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        private static void DrawAdvancedOptions(MaterialEditor me, MaterialProperty[] mps)
        {
            GUILayout.Label("Advanced Options", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                me.RenderQueueField();
#if UNITY_5_6_OR_NEWER
                me.EnableInstancingField();
                me.DoubleSidedGIField();
#endif  // UNITY_5_6_OR_NEWER
            }
        }
    }
}
