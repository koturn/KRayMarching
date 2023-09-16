using System;
using UnityEngine.Rendering;
using Koturn.KRayMarching.Enums;


namespace Koturn.KRayMarching.Inspectors
{
    /// <summary>
    /// Configuration structure of Rendering Mode.
    /// </summary>
    public struct RenderingModeConfig
    {
        /// <summary>
        /// Value of tag, "RenderType".
        /// </summary>
        public RenderType RenderType { get; }
        /// <summary>
        /// Value of "RenderQueue".
        /// </summary>
        public RenderQueue RenderQueue { get; }
        /// <summary>
        /// Value of property, "_AlphaTest".
        /// </summary>
        public bool IsAlphaTestEnabled { get; }
        /// <summary>
        /// Value of property, "_ZWrite".
        /// </summary>
        public bool IsZWriteEnabled { get; }
        /// <summary>
        /// Value of property, "_SrcBlend".
        /// </summary>
        public BlendMode SrcBlend { get; }
        /// <summary>
        /// Value of property, "_DstBlend".
        /// </summary>
        public BlendMode DstBlend { get; }
        /// <summary>
        /// Value of property, "_SrcBlendAlpha".
        /// </summary>
        public BlendMode SrcBlendAlpha { get; }
        /// <summary>
        /// Value of property, "_DstBlendAlpha".
        /// </summary>
        public BlendMode DstBlendAlpha { get; }
        /// <summary>
        /// Value of property, "_SrcBlendOp".
        /// </summary>
        public BlendOp BlendOp { get; }
        /// <summary>
        /// Value of property, "_DstBlendOp".
        /// </summary>
        public BlendOp BlendOpAlpha { get; }

        /// <summary>
        /// Initialize all member variables according to <paramref name="renderingMode"/>.
        /// </summary>
        /// <param name="renderingMode">Rendering mode.</param>
        public RenderingModeConfig(RenderingMode renderingMode)
        {
            switch (renderingMode)
            {
                case RenderingMode.Opaque:
                    RenderType = RenderType.Opaque;
                    RenderQueue = RenderQueue.Geometry;
                    IsAlphaTestEnabled = false;
                    IsZWriteEnabled = true;
                    SrcBlend = BlendMode.One;
                    DstBlend = BlendMode.Zero;
                    SrcBlendAlpha = BlendMode.One;
                    DstBlendAlpha = BlendMode.Zero;
                    BlendOp = BlendOp.Add;
                    BlendOpAlpha = BlendOp.Add;
                    break;
                case RenderingMode.Cutout:
                    RenderType = RenderType.TransparentCutout;
                    RenderQueue = RenderQueue.AlphaTest;
                    IsAlphaTestEnabled = true;
                    IsZWriteEnabled = true;
                    SrcBlend = BlendMode.One;
                    DstBlend = BlendMode.Zero;
                    SrcBlendAlpha = BlendMode.One;
                    DstBlendAlpha = BlendMode.Zero;
                    BlendOp = BlendOp.Add;
                    BlendOpAlpha = BlendOp.Add;
                    break;
                case RenderingMode.Fade:
                    RenderType = RenderType.Transparent;
                    RenderQueue = RenderQueue.Transparent;
                    IsAlphaTestEnabled = false;
                    IsZWriteEnabled = false;
                    SrcBlend = BlendMode.SrcAlpha;
                    DstBlend = BlendMode.OneMinusSrcAlpha;
                    SrcBlendAlpha = BlendMode.SrcAlpha;
                    DstBlendAlpha = BlendMode.OneMinusSrcAlpha;
                    BlendOp = BlendOp.Add;
                    BlendOpAlpha = BlendOp.Add;
                    break;
                case RenderingMode.Transparent:
                    RenderType = RenderType.Transparent;
                    RenderQueue = RenderQueue.Transparent;
                    IsAlphaTestEnabled = false;
                    IsZWriteEnabled = false;
                    SrcBlend = BlendMode.One;
                    DstBlend = BlendMode.OneMinusSrcAlpha;
                    SrcBlendAlpha = BlendMode.One;
                    DstBlendAlpha = BlendMode.OneMinusSrcAlpha;
                    BlendOp = BlendOp.Add;
                    BlendOpAlpha = BlendOp.Add;
                    break;
                case RenderingMode.Additive:
                    RenderType = RenderType.Transparent;
                    RenderQueue = RenderQueue.Transparent;
                    IsAlphaTestEnabled = false;
                    IsZWriteEnabled = false;
                    SrcBlend = BlendMode.SrcAlpha;
                    DstBlend = BlendMode.One;
                    SrcBlendAlpha = BlendMode.SrcAlpha;
                    DstBlendAlpha = BlendMode.One;
                    BlendOp = BlendOp.Add;
                    BlendOpAlpha = BlendOp.Add;
                    break;
                case RenderingMode.Multiply:
                    RenderType = RenderType.Transparent;
                    RenderQueue = RenderQueue.Transparent;
                    IsAlphaTestEnabled = false;
                    IsZWriteEnabled = false;
                    SrcBlend = BlendMode.DstColor;
                    DstBlend = BlendMode.Zero;
                    SrcBlendAlpha = BlendMode.DstColor;
                    DstBlendAlpha = BlendMode.Zero;
                    BlendOp = BlendOp.Add;
                    BlendOpAlpha = BlendOp.Add;
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(renderingMode), renderingMode, null);
            }
        }
    }
}
