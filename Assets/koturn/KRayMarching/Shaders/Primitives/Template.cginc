#ifndef PRIMITIVE_TEMPLATE_INCLUDED
#define PRIMITIVE_TEMPLATE_INCLUDED


#define RAYMARCHING_SDF map
#define RAYMARCHING_GET_BASE_COLOR getBaseColor

float map(float3 p);
half4 getBaseColor(float3 rayOrigin, float3 rayDir, float rayLength);

#include "../RayMarchingCore.cginc"


//! Main texture.
UNITY_DECLARE_TEX2D(_MainTex);
//! Tint color for main texture.
uniform half4 _Color;


/*!
 * @brief Get color of the object.
 * @param [in] rayOrigin  Object/World space ray origin.
 * @param [in] rayDir  Object/World space ray direction.
 * @param [in] rayLength  Object/World space Ray length.
 * @return Base color of the object.
 */
half4 getBaseColor(float3 rayOrigin, float3 rayDir, float rayLength)
{
    return _Color;
    // return SAMPLE_TEX2D_TRIPLANAR(_MainTex, worldFinalPos, worldNormal) * _Color;
}


#endif  // PRIMITIVE_TEMPLATE_INCLUDED
