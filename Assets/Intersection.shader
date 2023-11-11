Shader "Custom/Intersection"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode" = "SRPDefaultUnlit" }

            Cull Back
            Blend One Zero
            ZTest GEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/declaredepthtexture.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _IntersectionColor;
            CBUFFER_END

            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                return output;
            }

            float4 Frag(const Varyings input) : SV_TARGET
            {
                float2 screenUV = GetNormalizedScreenSpaceUV(input.positionHCS);

                float sceneDepth = SampleSceneDepth(screenUV);
                float DepthTexture = LinearEyeDepth(sceneDepth, _ZBufferParams);

                float DepthObject = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);

                float lerpValue = pow(1 - saturate(DepthObject - DepthTexture), 15);

                float4 colObject = _Color;
                float4 colIntersection = _IntersectionColor;
                return lerp(colObject, colIntersection, lerpValue);
            }
            ENDHLSL
        }
    }
}