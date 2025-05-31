#ifndef PRIMITIVE_TEMPLATE_INCLUDED
#define PRIMITIVE_TEMPLATE_INCLUDED


#define RAYMARCHING_SDF map
#define RAYMARCHING_GET_BASE_COLOR getBaseColor

float map(float3 p);
half4 getBaseColor(float3 p, float3 normal, float rayLength);

#include "../RayMarchingCore.cginc"


//! Main texture.
UNITY_DECLARE_TEX2D(_MainTex);

UNITY_INSTANCING_BUFFER_START(TemplateProps)
//! Tint color for main texture.
UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
UNITY_INSTANCING_BUFFER_END(TemplateProps)


/*!
 * @brief Get color of the object.
 * @param [in] p  Object/World space position.
 * @param [in] normal  Object/World space normal.
 * @param [in] rayLength  Ray length.
 * @return Base color of the object.
 */
half4 getBaseColor(float3 p, float3 normal, float rayLength)
{
    return UNITY_ACCESS_INSTANCED_PROP(TemplateProps, _Color);
    // return SAMPLE_TEX2D_TRIPLANAR(_MainTex, worldFinalPos, worldNormal) * UNITY_ACCESS_INSTANCED_PROP(TemplateProps, _Color);
}


#endif  // !defined(PRIMITIVE_TEMPLATE_INCLUDED)
