Shader "koturn/KRayMarching/Misc/StandardVertexColor"
{
    Properties
    {
        _Glossiness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 5.0

        /*!
         * @brief Input of surface shader function.
         */
        struct Input
        {
            fixed4 color;
        };

        //! Smoothness.
        uniform half _Glossiness;
        //! Metallic.
        uniform half _Metallic;

        /*!
         * Part of vertex shader function.
         * @param [in,out] v  Input of vertex shader.
         * @param [out] o  Input of surface shader function.
         */
		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.color = v.color;
		}

        /*!
         * @brief Part of fragment shader function.
         * @param [in] IN  Input of surface shader function.
         * @param [out] o  Lighting parameters.
         */
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            const fixed4 c = IN.color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
