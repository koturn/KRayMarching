using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using UnityEditor;
using UnityEngine;
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
        /// Cache of reflection result of following lambda.
        /// </summary>
        /// <remarks><seealso cref="CreateToggleKeywordDelegate"/></remarks>
        private static Action<Shader, MaterialProperty, bool> _toggleKeyword;


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
                // material.SetOverrideTag(TagRenderType, config.RenderType.ToString());
                material.renderQueue = (int)config.RenderQueue;
            }

            var mpAlphaTest = FindProperty(PropNameAlphaTest, mps, false);
            if (mpAlphaTest != null)
            {
                mpAlphaTest.floatValue = ToFloat(config.IsAlphaTestEnabled);
                ToggleKeyword(((Material)me.target).shader, mpAlphaTest);
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
                unsafe
                {
                    prop.floatValue = *(int *)&val;
                }
            }
        }

        /// <summary>
        /// Enable or disable keyword of <see cref="MaterialProperty"/> which has MaterialToggleUIDrawer.
        /// </summary>
        /// <param name="shader">Target <see cref="Shader"/>.</param>
        /// <param name="prop">Target <see cref="MaterialProperty"/>.</param>
        private static void ToggleKeyword(Shader shader, MaterialProperty prop)
        {
            ToggleKeyword(shader, prop, ToBool(prop.floatValue));
        }

        /// <summary>
        /// Enable or disable keyword of <see cref="MaterialProperty"/> which has MaterialToggleUIDrawer.
        /// </summary>
        /// <param name="shader">Target <see cref="Shader"/>.</param>
        /// <param name="prop">Target <see cref="MaterialProperty"/>.</param>
        /// <param name="isOn">True to enable (define) keyword, false to disable (undefine) keyword.</param>
        private static void ToggleKeyword(Shader shader, MaterialProperty prop, bool isOn)
        {
            try
            {
                (_toggleKeyword ?? (_toggleKeyword = CreateSetKeywordDelegate()))(shader, prop, isOn);
            }
            catch (Exception ex)
            {
                Debug.LogError(ex.ToString());
            }
        }

        /// <summary>
        /// <para>Create delegate of reflection results about UnityEditor.MaterialToggleUIDrawer.</para>
        /// <code>
        /// (Shader shader, MaterialProperty prop, bool isOn) =>
        /// {
        ///     MaterialPropertyHandler mph = UnityEditor.MaterialPropertyHandler.GetHandler(shader, name);
        ///     if (mph is null)
        ///     {
        ///         throw new ArgumentException("Specified MaterialProperty does not have UnityEditor.MaterialPropertyHandler");
        ///     }
        ///     MaterialToggleUIDrawer mpud = mph.propertyDrawer as MaterialToggleUIDrawer;
        ///     if (mpud is null)
        ///     {
        ///         throw new ArgumentException("Specified MaterialProperty does not have UnityEditor.MaterialToggleUIDrawer");
        ///     }
        ///     mpud.SetKeyword(prop, isOn);
        /// }
        /// </code>
        /// </summary>
        private static Action<Shader, MaterialProperty, bool> CreateSetKeywordDelegate()
        {
            // Get assembly from public class.
            var asm = Assembly.GetAssembly(typeof(UnityEditor.MaterialPropertyDrawer));

            // Get type of UnityEditor.MaterialPropertyHandler which is the internal class.
            var typeMph = asm.GetType("UnityEditor.MaterialPropertyHandler")
                ?? throw new InvalidOperationException("Type not found: UnityEditor.MaterialPropertyHandler");
            var typeMtud = asm.GetType("UnityEditor.MaterialToggleUIDrawer")
                ?? throw new InvalidOperationException("Type not found: UnityEditor.MaterialToggleUIDrawer");

            var ciArgumentException = typeof(ArgumentException).GetConstructor(new[] {typeof(string)});

            var pShader = Expression.Parameter(typeof(Shader), "shader");
            var pMaterialPropertyHandler = Expression.Parameter(typeMph, "mph");
            var pMaterialToggleUIDrawer = Expression.Parameter(typeMtud, "mtud");
            var pMaterialProperty = Expression.Parameter(typeof(MaterialProperty), "mp");
            var pIsOn = Expression.Parameter(typeof(bool), "isOn");

            var cNull = Expression.Constant(null);

            return Expression.Lambda<Action<Shader, MaterialProperty, bool>>(
                Expression.Block(
                    new[]
                    {
                        pMaterialPropertyHandler,
                        pMaterialToggleUIDrawer
                    },
                    Expression.Assign(
                        pMaterialPropertyHandler,
                        Expression.Call(
                            typeMph.GetMethod(
                                "GetHandler",
                                BindingFlags.NonPublic
                                    | BindingFlags.Static)
                                ?? throw new InvalidOperationException("MethodInfo not found: UnityEditor.MaterialPropertyHandler.GetHandler"),
                            pShader,
                            Expression.Property(
                                pMaterialProperty,
                                typeof(MaterialProperty).GetProperty(
                                    "name",
                                    BindingFlags.GetProperty
                                        | BindingFlags.Public
                                        | BindingFlags.Instance)))),
                    Expression.IfThen(
                        Expression.Equal(
                            pMaterialPropertyHandler,
                            cNull),
                        Expression.Throw(
                            Expression.New(
                                ciArgumentException,
                                Expression.Constant("Specified MaterialProperty does not have UnityEditor.MaterialPropertyHandler")))),
                    Expression.Assign(
                        pMaterialToggleUIDrawer,
                        Expression.TypeAs(
                            Expression.Property(
                                pMaterialPropertyHandler,
                                typeMph.GetProperty(
                                    "propertyDrawer",
                                    BindingFlags.GetProperty
                                        | BindingFlags.Public
                                        | BindingFlags.Instance)
                                    ?? throw new InvalidOperationException("PropertyInfo not found: UnityEditor.MaterialPropertyHandler.propertyDrawer")),
                            typeMtud)),
                    Expression.IfThen(
                        Expression.Equal(
                            pMaterialToggleUIDrawer,
                            cNull),
                        Expression.Throw(
                            Expression.New(
                                ciArgumentException,
                                Expression.Constant("Specified MaterialProperty does not have UnityEditor.MaterialToggleUIDrawer")))),
                    Expression.Call(
                        pMaterialToggleUIDrawer,
                        typeMtud.GetMethod(
                            "SetKeyword",
                            BindingFlags.NonPublic
                                | BindingFlags.Instance)
                            ?? throw new InvalidOperationException("MethodInfo not found: UnityEditor.MaterialToggleUIDrawer.SetKeyword"),
                        pMaterialProperty,
                        pIsOn)),
                "ToggleKeyword",
                new []
                {
                    pShader,
                    pMaterialProperty,
                    pIsOn
                }).Compile();
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
    }
}
