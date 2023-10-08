Shader "Custom/TestShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { 
               "RenderType"="Opaque" 
               "RenderPipeline" = "UniversalPipeline"
               "Queue" = "Geometry"
        }
        LOD 200


        Pass
        {
            Name "OmaPass"
            Tags
            {
                "LightMode"= "UniversalForward"
            }

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag
    
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;   
                float3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END

            
            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalWS = normalize(mul(float4(input.normalOS, 0), unity_WorldToObject));

                return output;
            }

            float4 Frag(const Varyings input) : SV_TARGET
            {
                float3 normalColor = (input.normalWS + float3(1, 1, 1)) * 0.5;
                return _Color * float4(normalColor,1);
            }

            ENDHLSL
        }

        
    }
}
