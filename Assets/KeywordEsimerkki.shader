Shader "Custom/KeywordEsimerkki"
{
    Properties
    {
        [KeywordEnum(Red, Green, Blue, Black)]
        _ColorKeyword("Color", Float) = 0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

            Pass {
                Name "Forward Lit"
                Tags { "LightMode" = "UniversalForward" }

                HLSLPROGRAM

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                #pragma vertex Vertex
                #pragma fragment Fragment

                #pragma shader_feature_local_fragment _COLORKEYWORD_RED _COLORKEYWORD_GREEN _COLORKEYWORD_BLUE _COLORKEYWORD_BLACK

                float4 Vertex(float3 positionOS : POSITION) : SV_POSITION {
                    return TransformObjectToHClip(positionOS);
                }

                float4 Fragment() : SV_TARGET {

                    float4 col = 1;

                    #if _COLORKEYWORD_RED
                    col = float4(1, 0, 0, 1);
                    #elif _COLORKEYWORD_GREEN
                    col = float4(0, 1, 0, 1);
                    #elif _COLORKEYWORD_BLUE
                    col = float4(0, 0, 1, 1);
                    #elif _COLORKEYWORD_BLACK
                    col = float4(0, 0, 0, 1);
                    #endif

                    return col;
                }

                ENDHLSL
            }
        }
}