Shader "Custom/NormalShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalTex("Normal Texture", 2D) = "bump" {}
        _Shininess("Shininess", Range(1, 32)) = 32
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalTex);
            SAMPLER(sampler_NormalTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;            
            float4 _NormalTex_ST;
            float _Shininess;
            CBUFFER_END


            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangentOS : TANGENT;
                float3 normalOS : NORMAL;
            };
            
            
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                
            };
            

            Varyings vert (Attributes input)
            {
                Varyings output;
            
                const VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS.xyz);
                const VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionHCS = posInputs.positionCS;
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;
                output.positionWS = posInputs.positionWS;

                output.uv = input.uv;

                return output;
            }

            float4 BlinnPhong(Varyings input, float4 color) {
                Light mainLight = GetMainLight();

                float3 viewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                float3 halfVector = normalize(mainLight.direction + viewDirection);

                float3 ambient = 0.1 * mainLight.color;
                float diffuse = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
                float specular = pow(saturate(dot(input.normalWS, halfVector)), _Shininess) * mainLight.color;

                float4 result = float4((ambient + diffuse + specular * 5) * color, 1);
                return result;
            }

            float4 frag (Varyings input) : SV_TARGET
            {
                const float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
                const float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, TRANSFORM_TEX(input.uv, _NormalTex)));                
                const float3x3 TangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);

                const float3 normalWS = TransformTangentToWorld(normalTS,TangentToWorld, true);

                input.normalWS = normalWS;

                return BlinnPhong(input, texColor);
            }

            ENDHLSL
        }
        Pass
        {
            Name "Depth"
            Tags { "LightMode" = "DepthOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R
            
            HLSLPROGRAM
            
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
            #include "DepthPass.hlsl"
            
            ENDHLSL
        }
        Pass
        {
            Name "Normals"
            Tags { "LightMode" = "DepthNormalsOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag
            #include "DepthNormalsPass.hlsl"
            
            ENDHLSL
        }
    }
}