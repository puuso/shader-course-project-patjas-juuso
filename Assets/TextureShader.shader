Shader "Custom/TextureShader"
{
    Properties{
        _Tex1("Texture", 2D) = "white" {}
        _Tex2("Texture", 2D) = "white" {}
        _Tiling("Tiling", Range(0.1, 10)) = 1
        _Offset("Offset", Range(0, 10)) = 0
        _Lerpp("Lerp parameter", range(0,1))=0.5
    }
        SubShader{
            Tags {"Queue" = "Transparent" "RenderType" = "Opaque"}
            LOD 100

            Pass {
                HLSLPROGRAM
                #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"


            struct Attributes {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _Tex1;
            sampler2D _Tex2;
            float _Tiling;
            float _Offset;
            float _Lerpp;
            CBUFFER_END

            Varyings Vert(Attributes input) {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.uv = input.uv * _Tiling + _Offset;
                return output;
            }

            half4 Frag(Varyings input) : SV_Target {
                float2 uv = input.uv;
                uv.x = (uv.x + _Offset) / _Lerpp    ; // Adjust offset and interval as needed

                // Check if the current row is even or odd
                half4 texColor = floor(uv.x) % 2 == 0 ? tex2D(_Tex1, input.uv) : tex2D(_Tex2, input.uv);

                return texColor;

            }
                ENDHLSL
            }
    }
}