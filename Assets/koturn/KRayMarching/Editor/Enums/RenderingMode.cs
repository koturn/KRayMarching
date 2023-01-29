namespace Koturn.KRayMarching.Enums
{
    /// <summary>
    /// Rendering Mode.
    /// </summary>
    public enum RenderingMode
    {
        /// <summary>
        /// Suitable for normal solid objects with no transparent areas.
        /// </summary>
        Opaque,
        /// <summary>
        /// Allows you to create a transparent effect that has hard edges between the opaque and transparent areas.
        /// </summary>
        Cutout,
        /// <summary>
        /// Allows the transparency values to entirely fade an object out, including any specular highlights or reflections it may have.
        /// </summary>
        Fade,
        /// <summary>
        /// Suitable for rendering realistic transparent materials such as clear plastic or glass.
        /// </summary>
        Transparent,
        /// <summary>
        /// Suitable for additive rendering.
        /// </summary>
        Additive,
        /// <summary>
        /// Suitable for multiply rendering.
        /// </summary>
        Multiply,
        /// <summary>
        /// Custom rendering mode.
        /// </summary>
        Custom
    }
}
