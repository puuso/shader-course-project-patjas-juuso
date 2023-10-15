Shader "Custom/Blinn-Phong"
{
    Properties{
     _Color("Object Color", Color) = (1, 1, 1, 1)
     _Shininess("Shininess", Range(1, 1000)) = 32
    }
        SubShader
    {
        Tags {
               "RenderType" = "Opaque"
               "RenderPipeline" = "UniversalPipeline"
               "Queue" = "Geometry"
        }
        LOD 200


        Pass
        {
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/lighting.hlsl"

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
            float _Shininess;
            CBUFFER_END


            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalWS = normalize(mul(float4(input.normalOS, 0), unity_WorldToObject));

                return output;
            }

            float4 BlinnPhong(Varyings input) {
                Light mainLight = GetMainLight();

                float3 viewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                float3 halfVector = normalize(mainLight.direction + viewDirection);

                float3 ambient = 0.1 * mainLight.color;
                float diffuse = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
                float specular = pow(saturate(dot(input.normalWS, halfVector)), _Shininess) * mainLight.color;

                float4 result = float4((ambient + diffuse + specular) * _Color, 1);
                return result;
            }

            half4 Frag(Varyings input) : SV_Target{
                half4 output = BlinnPhong(input);
                return output;
            }

            ENDHLSL
        }


    }
}
