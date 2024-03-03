using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Enums;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// Custom editor of RAyMarching shaders.
    /// </summary>
    public class KRayMarchingBaseGUI : ShaderGUI
    {
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
        /// Property name of "_MaxRayLengthMode".
        /// </summary>
        private const string PropNameMaxRayLengthMode = "_MaxRayLengthMode";
        /// <summary>
        /// Property name of "_MaxRayLength".
        /// </summary>
        private const string PropNameMaxRayLength = "_MaxRayLength";
        /// <summary>
        /// Property name of "_Scales".
        /// </summary>
        private const string PropNameScales = "_Scales";
        /// <summary>
        /// Property name of "_CalcSpace".
        /// </summary>
        private const string PropNameCalcSpace = "_CalcSpace";
        /// <summary>
        /// Property name of "_AssumeInside".
        /// </summary>
        private const string PropNameAssumeInside = "_AssumeInside";
        /// <summary>
        /// Property name of "_MaxInsideLength".
        /// </summary>
        private const string PropNameMaxInsideLength = "_MaxInsideLength";
        /// <summary>
        /// Property name of "_StepMethod".
        /// </summary>
        private const string PropNameStepMethod = "_StepMethod";
        /// <summary>
        /// Property name of "_MarchingFactor".
        /// </summary>
        private const string PropNameMarchingFactor = "_MarchingFactor";
        /// <summary>
        /// Property name of "_OverRelaxFactor".
        /// </summary>
        private const string PropNameOverRelaxFactor = "_OverRelaxFactor";
        /// <summary>
        /// Property name of "_AccelationFactor".
        /// </summary>
        private const string PropNameAccelarationFactor = "_AccelarationFactor";
        /// <summary>
        /// Property name of "_AutoRelaxFactor".
        /// </summary>
        private const string PropNameAutoRelaxFactor = "_AutoRelaxFactor";
        /// <summary>
        /// Property name of "_DebugView".
        /// </summary>
        private const string PropNameDebugView = "_DebugView";
        /// <summary>
        /// Property name of "_DebugStepDiv".
        /// </summary>
        private const string PropNameDebugStepDiv = "_DebugStepDiv";
        /// <summary>
        /// Property name of "_DebugRayLengthDiv".
        /// </summary>
        private const string PropNameDebugRayLengthDiv = "_DebugRayLengthDiv";
        /// <summary>
        /// Property name of "_Color".
        /// </summary>
        private const string PropNameColor = "_Color";
        /// <summary>
        /// Property name of "_Lighting".
        /// </summary>
        private const string PropNameLighting = "_Lighting";
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
        /// Property name of "_SpecColor".
        /// </summary>
        private const string PropNameSpecColor = "_SpecColor";
        /// <summary>
        /// Property name of "_SpecPower".
        /// </summary>
        private const string PropNameSpecPower = "_SpecPower";
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
        /// Property name of "_NoDepth".
        /// </summary>
        private const string PropNameNoDepth = "_NoDepth";
        /// <summary>
        /// Property name of "_NoForwardAdd".
        /// </summary>
        private const string PropNameNoForwardAdd = "_NoForwardAdd";
        /// <summary>
        /// Property name of "_Cull".
        /// </summary>
        private const string PropNameCull = "_Cull";
        /// <summary>
        /// Property name of "_Mode".
        /// </summary>
        private const string PropNameMode = "_Mode";
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
        /// Property name of "_ZClip".
        /// </summary>
        private const string PropNameZClip = "_ZClip";
        /// <summary>
        /// Property name of "_ZWrite".
        /// </summary>
        private const string PropNameZWrite = "_ZWrite";
        /// <summary>
        /// Property name of "_OffsetFactor".
        /// </summary>
        private const string PropNameOffsetFactor = "_OffsetFactor";
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
        /// Property name of "_StencilComp".
        /// </summary>
        private const string PropNameStencilComp = "_StencilComp";
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
        /// Editor UI mode names.
        /// </summary>
        private static readonly string[] _editorModeNames;

        /// <summary>
        /// Current editor UI mode.
        /// </summary>
        private static EditorMode _editorMode;
        /// <summary>
        /// Key list of cache of MaterialPropertyHandlers.
        /// </summary>
        private static List<string> _propStringList;


        /// <summary>
        /// Initialize <see cref="_editorMode"/>, <see cref="_editorModeNames"/>.
        /// </summary>
        static KRayMarchingBaseGUI()
        {
            _editorMode = (EditorMode)(-1);
            _editorModeNames = Enum.GetNames(typeof(EditorMode));
        }

        /// <summary>
        /// Draw property items.
        /// </summary>
        /// <param name="me">The <see cref="MaterialEditor"/> that are calling this <see cref="OnGUI(MaterialEditor, MaterialProperty[])"/> (the 'owner').</param>
        /// <param name="mps">Material properties of the current selected shader.</param>
        public override void OnGUI(MaterialEditor me, MaterialProperty[] mps)
        {
            if (!Enum.IsDefined(typeof(EditorMode), _editorMode))
            {
                MaterialPropertyUtil.ClearDecoratorDrawers(((Material)me.target).shader, mps);
                _editorMode = EditorMode.Custom;
            }
            using (var ccScope = new EditorGUI.ChangeCheckScope())
            {
                _editorMode = (EditorMode)GUILayout.Toolbar((int)_editorMode, _editorModeNames);
                if (ccScope.changed)
                {
                    if (_propStringList != null)
                    {
                        MaterialPropertyUtil.ClearPropertyHandlerCache(_propStringList);
                    }

                    if (_editorMode == EditorMode.Custom)
                    {
                        _propStringList = MaterialPropertyUtil.ClearDecoratorDrawers(((Material)me.target).shader, mps);
                    }
                    else
                    {
                        _propStringList = MaterialPropertyUtil.ClearCustomDrawers(((Material)me.target).shader, mps);
                    }
                }
            }
            if (_editorMode == EditorMode.Default)
            {
                base.OnGUI(me, mps);
                return;
            }

            var mpNoForwardAdd = FindProperty(PropNameNoForwardAdd, mps, false);

            EditorGUILayout.LabelField("Ray Marching Parameters", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameMaxLoop, false);
                using (new EditorGUI.DisabledScope(mpNoForwardAdd != null && ToBool(mpNoForwardAdd.floatValue)))
                {
                    ShaderProperty(me, mps, PropNameMaxLoopForwardAdd, false);
                }
                ShaderProperty(me, mps, PropNameMaxLoopShadowCaster, false);
                ShaderProperty(me, mps, PropNameMinRayLength, false);
                ShaderProperty(me, mps, PropNameMaxRayLengthMode, false);
                ShaderProperty(me, mps, PropNameMaxRayLength, false);
                ShaderProperty(me, mps, PropNameScales, false);
                ShaderProperty(me, mps, PropNameCalcSpace, false);
                var mpAssumeInside = FindAndDrawProperty(me, mps, PropNameAssumeInside, false);
                using (new EditorGUI.IndentLevelScope())
                using (new EditorGUI.DisabledScope(mpAssumeInside != null && mpAssumeInside.floatValue != 2.0f))
                {
                    ShaderProperty(me, mps, PropNameMaxInsideLength, false);
                }

                var mpStepMethod = FindAndDrawProperty(me, mps, PropNameStepMethod, false);
                using (new EditorGUI.IndentLevelScope())
                {
                    var stepMethodIndex = mpStepMethod == null ? 0 : (int)mpStepMethod.floatValue;
                    using (new EditorGUI.DisabledScope(stepMethodIndex != 0))
                    {
                        ShaderProperty(me, mps, PropNameMarchingFactor, false);
                    }
                    using (new EditorGUI.DisabledScope(stepMethodIndex != 1))
                    {
                        ShaderProperty(me, mps, PropNameOverRelaxFactor, false);
                    }
                    using (new EditorGUI.DisabledScope(stepMethodIndex != 2))
                    {
                        ShaderProperty(me, mps, PropNameAccelarationFactor, false);
                    }
                    using (new EditorGUI.DisabledScope(stepMethodIndex != 3))
                    {
                        ShaderProperty(me, mps, PropNameAutoRelaxFactor, false);
                    }
                }

                var mpDebugView = FindAndDrawProperty(me, mps, PropNameDebugView, false);
                using (new EditorGUI.IndentLevelScope())
                {
                    var debugViewIndex = mpDebugView == null ? 0 : (int)mpDebugView.floatValue;
                    using (new EditorGUI.DisabledScope(debugViewIndex != 1))
                    {
                        ShaderProperty(me, mps, PropNameDebugStepDiv, false);
                    }
                    using (new EditorGUI.DisabledScope(debugViewIndex != 2))
                    {
                        ShaderProperty(me, mps, PropNameDebugRayLengthDiv, false);
                    }
                }
            }

            EditorGUILayout.LabelField("Lighting Parameters", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            using (new EditorGUILayout.VerticalScope(GUI.skin.box))
            {
                ShaderProperty(me, mps, PropNameColor, false);

                var mpLighting = FindAndDrawProperty(me, mps, PropNameLighting, false);
                var lightingMethod = (LightingMethod)(mpLighting == null ? -1 : (int)mpLighting.floatValue);


                var isNeedGM = true;
                var mpEnableReflectionProbe = FindAndDrawProperty(me, mps, PropNameEnableReflectionProbe, false);
                if (mpEnableReflectionProbe != null)
                {
                    isNeedGM = ToBool(mpEnableReflectionProbe.floatValue);
                }

                using (new EditorGUI.IndentLevelScope())
                using (new EditorGUI.DisabledScope(lightingMethod == LightingMethod.UnityLambert || lightingMethod == LightingMethod.Unlit))
                {
                    var isCustomLit = lightingMethod == LightingMethod.Custom;
                    using (new EditorGUI.DisabledScope(!isNeedGM))
                    {
                        ShaderProperty(me, mps, PropNameGlossiness, false);
                    }
                    using (new EditorGUI.DisabledScope(!isNeedGM || !isCustomLit && (lightingMethod != LightingMethod.UnityStandard)))
                    {
                        ShaderProperty(me, mps, PropNameMetallic, false);
                    }
                    using (new EditorGUI.DisabledScope(!isCustomLit && lightingMethod != LightingMethod.UnityBlinnPhong && lightingMethod != LightingMethod.UnityStandardSpecular))
                    {
                        ShaderProperty(me, mps, PropNameSpecColor, false);
                    }
                    using (new EditorGUI.DisabledScope(!isCustomLit && lightingMethod != LightingMethod.UnityBlinnPhong))
                    {
                        ShaderProperty(me, mps, PropNameSpecPower, false);
                    }
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
                ShaderProperty(me, mps, PropNameNoDepth, false);
                ShaderProperty(me, mpNoForwardAdd);
                ShaderProperty(me, mps, PropNameCull, false);
                DrawRenderingMode(me, mps);
                ShaderProperty(me, mps, PropNameZTest, false);
                ShaderProperty(me, mps, PropNameZClip, false);
                DrawOffsetProperties(me, mps, PropNameOffsetFactor, PropNameOffsetUnit);
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
            var mpMMode = FindProperty(PropNameMode, mps, false);
            var mode = RenderingMode.Custom;
            if (mpMMode != null)
            {
                using (var ccScope = new EditorGUI.ChangeCheckScope())
                {
                    mode = (RenderingMode)EditorGUILayout.EnumPopup(mpMMode.displayName, (RenderingMode)mpMMode.floatValue);
                    mpMMode.floatValue = (float)mode;
                    if (ccScope.changed)
                    {
                        if (mode != RenderingMode.Custom)
                        {
                            ApplyRenderingMode(me, mps, mode);
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
        /// <para>Change rendeing mode.</para>
        /// <para>In other words, change following values.
        /// <list type="bullet">
        ///   <item>Value of material tag, "RenderType".</item>
        ///   <item>Value of render queue.</item>
        ///   <item>Shader property, "_AlphaTest" and related tag, "_ALPHATEST_ON".</item>
        ///   <item>Shader property, "_ZWrite".</item>
        ///   <item>Shader property, "_SrcBlend".</item>
        ///   <item>Shader property, "_DstBlend".</item>
        ///   <item>Shader property, "_SrcBlendAlpha".</item>
        ///   <item>Shader property, "_DstBlendAlpha".</item>
        ///   <item>Shader property, "_BlendOp".</item>
        ///   <item>Shader property, "_BlendOpAlpha".</item>
        /// </list>
        /// </para>
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/>.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        /// <param name="renderingMode">Rendering mode.</param>
        private static void ApplyRenderingMode(MaterialEditor me, MaterialProperty[] mps, RenderingMode renderingMode)
        {
            var config = new RenderingModeConfig(renderingMode);

            foreach (var material in me.targets.Cast<Material>())
            {
                // SetRenderTypeTag(material, config.RenderType);
                SetRenderQueue(material, config.RenderQueue);
            }

            var mpAlphaTest = FindProperty(PropNameAlphaTest, mps, false);
            if (mpAlphaTest != null)
            {
                mpAlphaTest.floatValue = ToFloat(config.IsAlphaTestEnabled);
                MaterialPropertyUtil.ToggleKeyword(((Material)me.target).shader, mpAlphaTest);
            }

            SetPropertyValue(PropNameZWrite, mps, config.IsZWriteEnabled, false);
            SetPropertyValue(PropNameSrcBlend, mps, config.SrcBlend, false);
            SetPropertyValue(PropNameDstBlend, mps, config.DstBlend, false);
            SetPropertyValue(PropNameSrcBlendAlpha, mps, config.SrcBlendAlpha, false);
            SetPropertyValue(PropNameDstBlendAlpha, mps, config.DstBlendAlpha, false);
            SetPropertyValue(PropNameBlendOp, mps, config.BlendOp, false);
            SetPropertyValue(PropNameBlendOp, mps, config.BlendOpAlpha, false);
        }

        /// <summary>
        /// Draw inspector items of "Blend".
        /// </summary>
        /// <param name="me">A <see cref="MaterialEditor"/></param>
        /// <param name="mps"><see cref="MaterialProperty"/> array</param>
        private void DrawBlendProperties(MaterialEditor me, MaterialProperty[] mps)
        {
            var mpMode = FindProperty(PropNameMode, mps, false);
            using (new EditorGUI.DisabledScope(mpMode != null && (RenderingMode)mpMode.floatValue != RenderingMode.Custom))
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
                PropNameStencilComp,
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
        /// Set render queue value if the value is differ from the default.
        /// </summary>
        /// <param name="material">Target material.</param>
        /// <param name="renderQueue"><see cref="RenderQueue"/> to set.</param>
        private static void SetRenderTypeTag(Material material, RenderType renderType)
        {
            // Set to default and get the default.
            material.SetOverrideTag(TagRenderType, string.Empty);
            var defaultTagval = material.GetTag(TagRenderType, false, "Transparent");

            // Set specified render type value if the value differs from the default.
            var renderTypeValue = renderType.ToString();
            if (renderTypeValue != defaultTagval)
            {
                material.SetOverrideTag(TagRenderType, renderTypeValue);
            }
        }

        /// <summary>
        /// Set render queue value if the value is differ from the default.
        /// </summary>
        /// <param name="material">Target material.</param>
        /// <param name="renderQueue"><see cref="RenderQueue"/> to set.</param>
        private static void SetRenderQueue(Material material, RenderQueue renderQueue)
        {
            // Set to default and get the default.
            material.renderQueue = -1;
            var defaultRenderQueue = material.renderQueue;

            // Set specified render queue value if the value differs from the default.
            var renderQueueValue = (int)renderQueue;
            if (defaultRenderQueue != renderQueueValue)
            {
                material.renderQueue = renderQueueValue;
            }
        }

        /// <summary>
        /// Set property value.
        /// </summary>
        /// <param name="propName">Names of shader property.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        /// <param name="val">Value to set. (true: 1.0f, false 0.0f).</param>
        /// <param name="isMandatory">
        /// If true then this method will throw an exception if property <paramref name="propName"/> is not found.
        /// Otherwise do nothing if property with <paramref name="propName"/> is not found.
        /// </param>
        private static void SetPropertyValue(string propName, MaterialProperty[] mps, bool val, bool isMandatory = true)
        {
            var prop = FindProperty(propName, mps, isMandatory);
            if (prop != null)
            {
                prop.floatValue = ToFloat(val);
            }
        }

        /// <summary>
        /// Set property value.
        /// </summary>
        /// <typeparam name="T">Type of enum.</typeparam>
        /// <param name="propName">Names of shader property.</param>
        /// <param name="mps"><see cref="MaterialProperty"/> array.</param>
        /// <param name="val">Value to set, which is cast to <see cref="float"/>.</param>
        /// <param name="isMandatory">
        /// If true then this method will throw an exception if property <paramref name="propName"/> was not found.
        /// Otherwise do nothing if property with <paramref name="propName"/> was not found.
        /// </param>
        private static void SetPropertyValue<T>(string propName, MaterialProperty[] mps, T val, bool isMandatory = true)
            where T : unmanaged, Enum
        {
            var prop = FindProperty(propName, mps, isMandatory);
            if (prop != null)
            {
                prop.floatValue = ToInt(val);
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

        /// <summary>
        /// Convert a <see cref="bool"/> value to <see cref="float"/> value.
        /// </summary>
        /// <param name="boolValue">Source <see cref="bool"/> value.</param>
        /// <returns>1.0f if <paramref name="boolValue"/> is true, otherwise 0.0f.</returns>
        private static float ToFloat(bool boolValue)
        {
            return boolValue ? 1.0f : 0.0f;
        }

        /// <summary>
        /// Cast generic enum to <see cref="int"/>.
        /// </summary>
        /// <typeparam name="T">Type of enum.</typeparam>
        /// <param name="val">Enum value.</param>
        /// <returns><see cref="int"/> value converted from <typeparamref name="T"/>.</returns>
        private static int ToInt<T>(T val)
            where T : unmanaged, Enum
        {
            unsafe
            {
                return sizeof(T) == 8 ? (int)*(long*)&val
                    : sizeof(T) == 4 ? *(int*)&val
                    : sizeof(T) == 2 ? (int)*(short*)&val
                    : (int)*(byte*)&val;
            }
        }
    }
}
