Shader "koturn/KRayMarching/Misc/UnlitVertexColor"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull ("Cull", Int) = 2  // Default: Back
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Cull [_Cull]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            /*!
             * @brief Input data type for vertex shader function
             */
            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
            };

            /*!
             * @brief Input data type for fragment shader function
             */
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : TEXCOORD0;
                UNITY_FOG_COORDS(2)
            };

            /*!
             * @brief Vertex shader function
             * @param [in] v  Input data
             * @return Input data source for fragment shader.
             */
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            /*!
             * @brief Fragment shader function
             * @param [in] i  Input data from vertex shader
             * @return Color of the fragment.
             */
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = i.color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
