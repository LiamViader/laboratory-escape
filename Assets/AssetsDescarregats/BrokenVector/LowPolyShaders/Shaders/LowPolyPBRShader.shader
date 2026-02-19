Shader "Custom/LowPolyPBRShader_Lit"
{
    Properties
    {
        _MainTex("Color Scheme", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _Color;
            float _Glossiness;
            float _Metallic;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv = IN.uv;
                return OUT;
            }

            void InitializeSurfaceData(float3 albedo, half metallic, half smoothness, half alpha, out SurfaceData surfaceData)
            {
                surfaceData.albedo = albedo;
                surfaceData.metallic = metallic;
                surfaceData.specular = 0.5;
                surfaceData.smoothness = smoothness;
                surfaceData.normalTS = float3(0, 0, 1);
                surfaceData.emission = 0;
                surfaceData.occlusion = 1;
                surfaceData.alpha = alpha;
                surfaceData.clearCoatMask = 0;
                surfaceData.clearCoatSmoothness = 0;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;

                SurfaceData surfaceData;
                InitializeSurfaceData(texColor.rgb, _Metallic, _Glossiness, 1.0, surfaceData);

                // 👇 Aquí manualment fem l'InputData
                InputData inputData = (InputData)0;
                inputData.positionWS = TransformWorldToObject(IN.positionCS).xyz;
                inputData.normalWS = normalize(IN.normalWS);
                inputData.viewDirectionWS = SafeNormalize(_WorldSpaceCameraPos - inputData.positionWS);
                inputData.shadowCoord = float4(1, 1, 1, 1); // sense shadows aquí

                // Renderitza amb PBR de Universal
                half4 color = UniversalFragmentPBR(inputData, surfaceData);

                return color;
            }

            ENDHLSL
        }
    }
}
