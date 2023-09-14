using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Enums;


namespace Koturn.KRayMarching
{
    /// <summary>
    /// Custom editor of RAyMarching shaders.
    /// </summary>
    public class KRayMarchingBaseGUI : ShaderGUI
    {
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
        /// Property name of "_DisableForwardAdd".
        /// </summary>
        private const string PropNameDisableForwardAdd = "_DisableForwardAdd";
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
        /// Property name of "_Cull".
        /// </summary>
        private const string PropNameCull = "_Cull";
        /// <summary>
        /// Property name of "__RenderingMode".
        /// </summary>
        private const string PropNameRenderingMode = "__RenderingMode";
        /// <summary>
        /// Property name of "_AlphaTest".
        /// </summary>
        private const string PropNameAlphaTest = "_AlphaTest";
        /// <summary>
        /// Property name of "_Cutoff".
        /// </summary>
        private const string PropNameCutoff = "_Cutoff";
        /// <summary>
        /// Property name of "_SrcBlend".
        /// </summary>
        private const string PropNameSrcBlend = "_SrcBlend";
        /// <summary>
        /// Property name of "_DstBlend".
        /// </summary>
        private const string PropNameDstBlend = "_DstBlend";
        /// <summary>
        /// Property name of "_SrcBlendAlpha".
        /// </summary>
        private const string PropNameSrcBlendAlpha = "_SrcBlendAlpha";
        /// <summary>
        /// Property name of "_DstBlendAlpha".
        /// </summary>
        private const string PropNameDstBlendAlpha = "_DstBlendAlpha";
        /// <summary>
        /// Property name of "_BlendOp".
        /// </summary>
        private const string PropNameBlendOp = "_BlendOp";
        /// <summary>
        /// Property name of "_BlendOpAlpha".
        /// </summary>
        private const string PropNameBlendOpAlpha = "_BlendOpAlpha";
        /// <summary>
        /// Property name of "_ZTest".
        /// </summary>
        private const string PropNameZTest = "_ZTest";
        /// <summary>
        /// Property name of "_ZWrite".
        /// </summary>
        private const string PropNameZWrite = "_ZWrite";
        /// <summary>
        /// Property name of "_OffsetFact".
        /// </summary>
        private const string PropNameOffsetFact = "_OffsetFact";
        /// <summary>
        /// Property name of "_OffsetUnit".
        /// </summary>
        private const string PropNameOffsetUnit = "_OffsetUnit";
        /// <summary>
        /// Property name of "_ColorMask".
        /// </summary>
        private const string PropNameColorMask = "_ColorMask";
        /// <summary>
        /// Property name of "_AlphaToMask".
        /// </summary>
        private const string PropNameAlphaToMask = "_AlphaToMask";
        /// <summary>
        /// Property name of "_StencilRef".
        /// </summary>
        private const string PropNameStencilRef = "_StencilRef";
        /// <summary>
        /// Property name of "_StencilReadMask".
        /// </summary>
        private const string PropNameStencilReadMask = "_StencilReadMask";
        /// <summary>
        /// Property name of "_StencilWriteMask".
        /// </summary>
        private const string PropNameStencilWriteMask = "_StencilWriteMask";
        /// <summary>
        /// Property name of "_StencilCompFunc".
        /// </summary>
        private const string PropNameStencilCompFunc = "_StencilCompFunc";
        /// <summary>
        /// Property name of "_StencilPass".
        /// </summary>
        private const string PropNameStencilPass = "_StencilPass";
        /// <summary>
        /// Property name of "_StencilFail".
        /// </summary>
        private const string PropNameStencilFail = "_StencilFail";
        /// <summary>
        /// Property name of "_StencilZFail".
        /// </summary>
        private const string PropNameStencilZFail = "_StencilZFail";
        /// <summary>
        /// Tag name of "RenderType".
        /// </summary>
        private const string TagRenderType = "RenderType";


        /// <summary>
        /// Keyword of "_AlphaTest" which is enabled.
        /// </summary>
        private static readonly string KeywordAlphaTestOn;


        /// <summary>
        /// Initialize static members.
        /// </summary>
        static KRayMarchingBaseGUI()
        {
            KeywordAlphaTestOn = PropNameAlphaTest.ToUpper() + "_ON";
        }


        /// <summary>
        /// Draw property items.
        /// </summary>
        /// <param name="me">The <see cref="MaterialEditor"/> that are calling this <see cref="OnGUI(MaterialEditor, MaterialProperty[])"/> (the 'owner').</param>
        /// <param name="mps">Material properties of the current selected shader.</param>
        public override void OnGUI(MaterialEditor me, MaterialProperty[] mps)
        {
            EditorGUILayout.LabelField("Ray Marching Parameters", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                var mpDisableForwardAdd = FindAndDrawProperty(me, mps, PropNameDisableForwardAdd, false);

                ShaderProperty(me, mps, PropNameMaxLoop, false);
                using (new EditorGUI.DisabledScope(mpDisableForwardAdd != null && ToBool(mpDisableForwardAdd.floatValue)))
                {
                    ShaderProperty(me, mps, PropNameMaxLoopForwardAdd, false);
                }
                ShaderProperty(me, mps, PropNameMaxLoopShadowCaster, false);
                ShaderProperty(me, mps, PropNameMinRayLength, false);
                ShaderProperty(me, mps, PropNameMaxRayLength, false);
                ShaderProperty(me, mps, PropNameScales, false);
                ShaderProperty(me, mps, PropNameMarchingFactor, false);
            }

            EditorGUILayout.LabelField("Lighting Parameters", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameColor, false);

                var mpLightingMethod = FindAndDrawProperty(me, mps, PropNameLightingMethod, false);
                var lightingMethod = (LightingMethod)(mpLightingMethod == null ? -1 : (int)mpLightingMethod.floatValue);


                var isNeedGM = true;
                var mpEnableReflectionProbe = FindAndDrawProperty(me, mps, PropNameEnableReflectionProbe, false);
                if (mpEnableReflectionProbe != null)
                {
                    isNeedGM = ToBool(mpEnableReflectionProbe.floatValue);
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

            EditorGUILayout.Space();

            EditorGUILayout.LabelField("Rendering Options", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameCull, false);
                DrawRenderingMode(me, mps);
                ShaderProperty(me, mps, PropNameZTest, false);
                DrawOffsetProperties(me, mps, PropNameOffsetFact, PropNameOffsetUnit);
                ShaderProperty(me, mps, PropNameColorMask, false);
                ShaderProperty(me, mps, PropNameAlphaToMask, false);

                EditorGUILayout.Space();
                DrawBlendProperties(me, mps);
                EditorGUILayout.Space();
                DrawStencilProperties(me, mps);
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
        /// Find properties which has specified names.
        /// </summary>
        /// <param name="propNames">Names of shader property.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        /// <param name="isMandatory">If <c>true</c> then this method will throw an exception
        /// if one of properties with <<paramref name="propNames"/> was not found.</param>
        /// <return>Found properties.</return>
        protected static List<MaterialProperty> FindProperties(string[] propNames, MaterialProperty[] mps, bool isMandatory = true)
        {
            var mpList = new List<MaterialProperty>(propNames.Length);
            foreach (var propName in propNames)
            {
                var prop = FindProperty(propName, mps, isMandatory);
                if (prop != null)
                {
                    mpList.Add(prop);
                }
            }

            return mpList;
        }

        /// <summary>
        /// Draw inspector items of <see cref="RenderingMode"/>.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/></param>
        /// <param name="mps"><see cref="MaterialProperty"/> array</param>
        private void DrawRenderingMode(MaterialEditor me, MaterialProperty[] mps)
        {
            var mpRenderingMode = FindProperty(PropNameRenderingMode, mps, false);
            var mode = RenderingMode.Custom;
            if (mpRenderingMode != null)
            {
                using (var ccScope = new EditorGUI.ChangeCheckScope())
                {
                    mode = (RenderingMode)EditorGUILayout.EnumPopup(mpRenderingMode.displayName, (RenderingMode)mpRenderingMode.floatValue);
                    mpRenderingMode.floatValue = (float)mode;
                    if (ccScope.changed)
                    {
                        if (mode != RenderingMode.Custom)
                        {
                            foreach (var material in mpRenderingMode.targets.Cast<Material>())
                            {
                                ApplyRenderingMode(material, mode);
                            }
                        }
                    }
                }
            }

            using (new EditorGUI.DisabledScope(mode != RenderingMode.Cutout && mode != RenderingMode.Custom))
            {
                var mpAlphaTest = FindAndDrawProperty(me, mps, PropNameAlphaTest, false);
                if (mpAlphaTest != null)
                {
                    using (new EditorGUI.IndentLevelScope())
                    using (new EditorGUI.DisabledScope(!ToBool(mpAlphaTest.floatValue)))
                    {
                        ShaderProperty(me, mps, PropNameCutoff);
                    }
                }
            }

            using (new EditorGUI.DisabledScope(mode != RenderingMode.Custom))
            {
                ShaderProperty(me, mps, PropNameZWrite, false);
            }
        }

        /// <summary>
        /// Change blend of <paramref name="material"/>.
        /// </summary>
        /// <param name="material">Target material</param>
        /// <param name="renderingMode">Rendering mode</param>
        private static void ApplyRenderingMode(Material material, RenderingMode renderingMode)
        {
            switch (renderingMode)
            {
                case RenderingMode.Opaque:
                    // material.SetOverrideTag(TagRenderType, "");
                    SetAlphaTest(material, false);
                    material.SetInt(PropNameZWrite, 1);
                    material.SetInt(PropNameSrcBlend, (int)BlendMode.One);
                    material.SetInt(PropNameDstBlend, (int)BlendMode.Zero);
                    material.SetInt(PropNameSrcBlendAlpha, (int)BlendMode.One);
                    material.SetInt(PropNameDstBlendAlpha, (int)BlendMode.Zero);
                    material.SetInt(PropNameBlendOp, (int)BlendOp.Add);
                    material.SetInt(PropNameBlendOpAlpha, (int)BlendOp.Add);
                    material.renderQueue = -1;
                    break;
                case RenderingMode.Cutout:
                    // material.SetOverrideTag(TagRenderType, "TransparentCutout");
                    SetAlphaTest(material, true);
                    material.SetInt(PropNameZWrite, 1);
                    material.SetInt(PropNameSrcBlend, (int)BlendMode.One);
                    material.SetInt(PropNameDstBlend, (int)BlendMode.Zero);
                    material.SetInt(PropNameSrcBlendAlpha, (int)BlendMode.One);
                    material.SetInt(PropNameDstBlendAlpha, (int)BlendMode.Zero);
                    material.SetInt(PropNameBlendOp, (int)BlendOp.Add);
                    material.SetInt(PropNameBlendOpAlpha, (int)BlendOp.Add);
                    material.renderQueue = (int)RenderQueue.AlphaTest;
                    break;
                case RenderingMode.Fade:
                    // material.SetOverrideTag(TagRenderType, "Transparent");
                    SetAlphaTest(material, false);
                    material.SetInt(PropNameZWrite, 0);
                    material.SetInt(PropNameSrcBlend, (int)BlendMode.SrcAlpha);
                    material.SetInt(PropNameDstBlend, (int)BlendMode.OneMinusSrcAlpha);
                    material.SetInt(PropNameSrcBlendAlpha, (int)BlendMode.SrcAlpha);
                    material.SetInt(PropNameDstBlendAlpha, (int)BlendMode.OneMinusSrcAlpha);
                    material.SetInt(PropNameBlendOp, (int)BlendOp.Add);
                    material.SetInt(PropNameBlendOpAlpha, (int)BlendOp.Add);
                    material.renderQueue = (int)RenderQueue.Transparent;
                    break;
                case RenderingMode.Transparent:
                    // material.SetOverrideTag(TagRenderType, "Transparent");
                    SetAlphaTest(material, false);
                    material.SetInt(PropNameZWrite, 0);
                    material.SetInt(PropNameSrcBlend, (int)BlendMode.One);
                    material.SetInt(PropNameDstBlend, (int)BlendMode.OneMinusSrcAlpha);
                    material.SetInt(PropNameSrcBlendAlpha, (int)BlendMode.One);
                    material.SetInt(PropNameDstBlendAlpha, (int)BlendMode.OneMinusSrcAlpha);
                    material.SetInt(PropNameBlendOp, (int)BlendOp.Add);
                    material.SetInt(PropNameBlendOpAlpha, (int)BlendOp.Add);
                    material.renderQueue = (int)RenderQueue.Transparent;
                    break;
                case RenderingMode.Additive:
                    // material.SetOverrideTag(TagRenderType, "Transparent");
                    SetAlphaTest(material, false);
                    material.SetInt(PropNameZWrite, 0);
                    material.SetInt(PropNameSrcBlend, (int)BlendMode.SrcAlpha);
                    material.SetInt(PropNameDstBlend, (int)BlendMode.One);
                    material.SetInt(PropNameSrcBlendAlpha, (int)BlendMode.SrcAlpha);
                    material.SetInt(PropNameDstBlendAlpha, (int)BlendMode.One);
                    material.SetInt(PropNameBlendOp, (int)BlendOp.Add);
                    material.SetInt(PropNameBlendOpAlpha, (int)BlendOp.Add);
                    material.renderQueue = (int)RenderQueue.Transparent;
                    break;
                case RenderingMode.Multiply:
                    // material.SetOverrideTag(TagRenderType, "Transparent");
                    SetAlphaTest(material, false);
                    material.SetInt(PropNameZWrite, 0);
                    material.SetInt(PropNameSrcBlend, (int)BlendMode.DstColor);
                    material.SetInt(PropNameDstBlend, (int)BlendMode.Zero);
                    material.SetInt(PropNameSrcBlendAlpha, (int)BlendMode.DstColor);
                    material.SetInt(PropNameDstBlendAlpha, (int)BlendMode.Zero);
                    material.SetInt(PropNameBlendOp, (int)BlendOp.Add);
                    material.SetInt(PropNameBlendOpAlpha, (int)BlendOp.Add);
                    material.renderQueue = (int)RenderQueue.Transparent;
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(renderingMode), renderingMode, null);
            }
        }

        /// <summary>
        /// Draw inspector items of "Blend".
        /// </summary>
        /// <param name="material">Target material</param>
        /// <param name="isEnabled"><para>Toggle switch value.</para>
        /// <para>If this value is true, _AlphaTest is set to 1 and define a keyword "_ALPHATEST_ON".</para>
        /// <para>Otherwise _AlphaTest is set to 0 and undefine a keyword "_ALPHATEST_ON".</para>
        /// </param>
        private static void SetAlphaTest(Material material, bool isEnabled)
        {
            if (!material.HasProperty(PropNameAlphaTest))
            {
                return;
            }

            if (isEnabled)
            {
                material.SetInt(PropNameAlphaTest, 1);
                material.EnableKeyword(KeywordAlphaTestOn);
            }
            else
            {
                material.SetInt(PropNameAlphaTest, 0);
                material.DisableKeyword(KeywordAlphaTestOn);
            }
        }

        /// <summary>
        /// Draw inspector items of "Blend".
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/></param>
        /// <param name="mps"><see cref="MaterialProperty"/> array</param>
        private void DrawBlendProperties(MaterialEditor me, MaterialProperty[] mps)
        {
            var mpRenderingMode = FindProperty(PropNameRenderingMode, mps, false);
            using (new EditorGUI.DisabledScope(mpRenderingMode != null && (RenderingMode)mpRenderingMode.floatValue != RenderingMode.Custom))
            {
                var propSrcBlend = FindProperty(PropNameSrcBlend, mps, false);
                var propDstBlend = FindProperty(PropNameDstBlend, mps, false);
                if (propSrcBlend == null || propDstBlend == null)
                {
                    return;
                }

                EditorGUILayout.LabelField("Blend", EditorStyles.boldLabel);
                using (new EditorGUI.IndentLevelScope())
                using (new EditorGUILayout.VerticalScope(GUI.skin.box))
                {
                    ShaderProperty(me, propSrcBlend);
                    ShaderProperty(me, propDstBlend);

                    var propSrcBlendAlpha = FindProperty(PropNameSrcBlendAlpha, mps, false);
                    var propDstBlendAlpha = FindProperty(PropNameDstBlendAlpha, mps, false);
                    if (propSrcBlendAlpha != null && propDstBlendAlpha != null)
                    {
                        ShaderProperty(me, propSrcBlendAlpha);
                        ShaderProperty(me, propDstBlendAlpha);
                    }

                    ShaderProperty(me, mps, PropNameBlendOp, false);
                    ShaderProperty(me, mps, PropNameBlendOpAlpha, false);
                }
            }
        }

        /// <summary>
        /// Draw inspector items of "Offset".
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/></param>
        /// <param name="mps"><see cref="MaterialProperty"/> array</param>
        /// <param name="propNameFactor">Property name for the first argument of "Offset"</param>
        /// <param name="propNameUnit">Property name for the second argument of "Offset"</param>
        private static void DrawOffsetProperties(MaterialEditor me, MaterialProperty[] mps, string propNameFactor, string propNameUnit)
        {
            var propFactor = FindProperty(propNameFactor, mps, false);
            var propUnit = FindProperty(propNameUnit, mps, false);
            if (propFactor == null || propUnit == null)
            {
                return;
            }
            EditorGUILayout.LabelField("Offset");
            using (new EditorGUI.IndentLevelScope())
            {
                ShaderProperty(me, propFactor);
                ShaderProperty(me, propUnit);
            }
        }

        /// <summary>
        /// Draw inspector items of Stencil.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/></param>
        /// <param name="mps"><see cref="MaterialProperty"/> array</param>
        private static void DrawStencilProperties(MaterialEditor me, MaterialProperty[] mps)
        {
            var stencilProps = FindProperties(new []
            {
                PropNameStencilRef,
                PropNameStencilReadMask,
                PropNameStencilWriteMask,
                PropNameStencilCompFunc,
                PropNameStencilPass,
                PropNameStencilFail,
                PropNameStencilZFail
            }, mps, false);

            if (stencilProps.Count == 0)
            {
                return;
            }

            EditorGUILayout.LabelField("Stencil", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                foreach (var prop in stencilProps)
                {
                    me.ShaderProperty(prop, prop.displayName);
                }
            }
        }

        /// <summary>
        /// Draw inspector items of advanced options.
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        private static void DrawAdvancedOptions(MaterialEditor me, MaterialProperty[] mps)
        {
            EditorGUILayout.LabelField("Advanced Options", EditorStyles.boldLabel);
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

        /// <summary>
        /// Convert a <see cref="float"/> value to <see cref="bool"/> value.
        /// </summary>
        /// <param name="floatValue">Source <see cref="float"/> value.</param>
        /// <returns>True if <paramref name="floatValue"/> is greater than 0.5, otherwise false.</returns>
        private static bool ToBool(float floatValue)
        {
            return floatValue >= 0.5f;
        }
    }
}
