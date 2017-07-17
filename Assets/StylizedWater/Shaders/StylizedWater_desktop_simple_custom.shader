// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.30 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
Shader "StylizedWater/Desktop_Simple_Custom" {
    Properties {
		_CustomLightColor0 ("Custom Light Color", Color) = (1,1,1,1)
		_CustomLightColorIntensity("Custom Light Color Intensity", Float) = 1
		_CustomAmbientColor("Custom Ambient Color", Color) = (1,1,1,1)
		_CustomLightDirection("Custom Light Direction", Vector) = (0,0,1,1)
        _WaterColor ("Water Color", Color) = (0,0.503546,1,1)
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,0.5019608)
        _Fresnelexponent ("Fresnel exponent", Float ) = 4
        _Transparency ("Transparency", Range(0, 1)) = 0.75
        _SurfaceHighlight ("Surface Highlight", Range(0, 1)) = 0.05
        _Surfacehightlightsize ("Surface hightlight size", Range(0, 1)) = 0
        _SurfaceHightlighttiling ("Surface Hightlight tiling", Float ) = 0.25
        _Depth ("Depth", Range(0, 30)) = 30
        _Depthdarkness ("Depth darkness", Range(0, 1)) = 0.5
        _RimSize ("Rim Size", Range(0, 4)) = 2
        _Rimfalloff ("Rim falloff", Range(0, 5)) = 0.25
        [MaterialToggle] _Worldspacetiling ("Worldspace tiling", Float ) = 0
        _Tiling ("Tiling", Range(0.1, 1)) = 0.9
        _Rimtiling ("Rim tiling", Float ) = 2
        _Wavesspeed ("Waves speed", Range(0, 10)) = 0.75
        _Wavesstrength ("Waves strength", Range(0, 1)) = 0.66
        [NoScaleOffset][Normal]_Normals ("Normals", 2D) = "bump" {}
        [NoScaleOffset]_Shadermap ("Shadermap", 2D) = "black" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            //#pragma glsl
            //uniform float4 _LightColor0;
			uniform float4 _CustomAmbientColor;
			uniform float _CustomLightColorIntensity;
			uniform float4 _CustomLightColor0;
			uniform float4 _CustomLightDirection;
            uniform sampler2D _CameraDepthTexture;
            uniform float4 _TimeEditor;
            uniform fixed _RimSize;
            uniform fixed4 _WaterColor;
            uniform fixed4 _RimColor;
            uniform sampler2D _Shadermap;
            uniform fixed _Tiling;
            uniform float _Transparency;
            uniform sampler2D _Normals;
            uniform fixed _Wavesspeed;
            uniform float _Wavesstrength;
            uniform fixed _Depth;
            uniform fixed _Depthdarkness;
            uniform fixed _Rimtiling;
            uniform fixed _Worldspacetiling;
            uniform fixed _Rimfalloff;
            uniform float _SurfaceHighlight;
            uniform float _Surfacehightlightsize;
            uniform float _SurfaceHightlighttiling;
            uniform float _Fresnelexponent;
            uniform float4 _FresnelColor;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                float4 projPos : TEXCOORD5;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                float4 node_8305 = _Time + _TimeEditor;
                float WaveSpeed = (node_8305.g*(_Wavesspeed*0.1));
                fixed mWaveSpeed = WaveSpeed;
                fixed2 Tiling = (lerp( ((-20.0)*o.uv0), mul(unity_ObjectToWorld, v.vertex).rgb.rb, _Worldspacetiling )*(1.0 - _Tiling));
                fixed2 mTiling = Tiling;
                fixed2 WavePanningV = (mTiling+mWaveSpeed*float2(0,1));
                fixed3 node_4911 = UnpackNormal(tex2Dlod(_Normals,float4(WavePanningV,0.0,0)));
                v.vertex.xyz += (v.normal*node_4911.r*_Wavesstrength);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _CustomLightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float4 node_8305 = _Time + _TimeEditor;
                float WaveSpeed = (node_8305.g*(_Wavesspeed*0.1));
                fixed mWaveSpeed = WaveSpeed;
                fixed2 Tiling = (lerp( ((-20.0)*i.uv0), i.posWorld.rgb.rb, _Worldspacetiling )*(1.0 - _Tiling));
                fixed2 mTiling = Tiling;
                fixed2 WavePanningV = (mTiling+mWaveSpeed*float2(0,1));
                fixed3 node_4911 = UnpackNormal(tex2D(_Normals,WavePanningV));
                fixed2 WavePanningU = (mTiling+mWaveSpeed*float2(0.9,0));
                fixed3 node_49111 = UnpackNormal(tex2D(_Normals,WavePanningU));
                float3 node_3950_nrm_base = node_4911.rgb + float3(0,0,1);
                float3 node_3950_nrm_detail = node_49111.rgb * float3(-1,-1,1);
                float3 node_3950_nrm_combined = node_3950_nrm_base*dot(node_3950_nrm_base, node_3950_nrm_detail)/node_3950_nrm_base.z - node_3950_nrm_detail;
                float3 node_3950 = node_3950_nrm_combined;
                float3 Normals = node_3950;
                float3 normalLocal = Normals;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
                //float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 lightDirection = normalize(_CustomLightDirection.xyz);
                float3 lightColor = _CustomLightColor0.rgb * _CustomLightColorIntensity;
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * lightColor;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                //indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
				indirectDiffuse += _CustomAmbientColor.rgb; // Ambient Light
                float depth = saturate((sceneZ-partZ)/_Depth);
                float RimAllphaMultiply = ((1.0 - pow(saturate((sceneZ-partZ)/_RimSize),_Rimfalloff))*_RimColor.a);
                fixed node_7911 = WaveSpeed;
                fixed2 rimTiling = (Tiling*_Rimtiling);
                fixed2 rimPanningU = (rimTiling+node_7911*float2(1,0));
                float4 rimTexR = tex2D(_Shadermap,rimPanningU);
                fixed2 rimPanningV = (rimTiling+node_7911*float2(0,1));
                float4 rimTexB = tex2D(_Shadermap,rimPanningV);
                float AddRimTextureToMask = (RimAllphaMultiply+(RimAllphaMultiply*(1.0 - (rimTexR.b*rimTexB.b))*_RimColor.a));
                float node_4005 = 1.0;
                float2 HighlightPanningV = (WavePanningV*_SurfaceHightlighttiling);
                float4 node_5469 = tex2D(_Shadermap,HighlightPanningV);
                float2 HightlightPanningU = (WavePanningU*_SurfaceHightlighttiling);
                float4 node_8808 = tex2D(_Shadermap,HightlightPanningU);
                float ClampHighlight = saturate((step(_Surfacehightlightsize,(node_5469.r-node_8808.r))*_SurfaceHighlight));
                float3 diffuseColor = lerp(lerp(_FresnelColor.rgb,lerp(lerp(_WaterColor.rgb,(_WaterColor.rgb*(1.0 - _Depthdarkness)),depth),_RimColor.rgb,saturate(AddRimTextureToMask)),(1.0 - (pow((1.0-max(0,dot(i.normalDir, viewDirection))),_Fresnelexponent)*_FresnelColor.a))),float3(node_4005,node_4005,node_4005),ClampHighlight);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
                return fixed4(finalColor,(saturate(( lerp(_Transparency,1.0,AddRimTextureToMask) > 0.5 ? (1.0-(1.0-2.0*(lerp(_Transparency,1.0,AddRimTextureToMask)-0.5))*(1.0-depth)) : (2.0*lerp(_Transparency,1.0,AddRimTextureToMask)*depth) ))+ClampHighlight));
            }
            ENDCG
        }
		/*
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            #pragma glsl
            uniform float4 _TimeEditor;
            uniform fixed _Tiling;
            uniform sampler2D _Normals;
            uniform fixed _Wavesspeed;
            uniform float _Wavesstrength;
            uniform fixed _Worldspacetiling;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_8305 = _Time + _TimeEditor;
                float WaveSpeed = (node_8305.g*(_Wavesspeed*0.1));
                fixed mWaveSpeed = WaveSpeed;
                fixed2 Tiling = (lerp( ((-20.0)*o.uv0), mul(unity_ObjectToWorld, v.vertex).rgb.rb, _Worldspacetiling )*(1.0 - _Tiling));
                fixed2 mTiling = Tiling;
                fixed2 WavePanningV = (mTiling+mWaveSpeed*float2(0,1));
                fixed3 node_4911 = UnpackNormal(tex2Dlod(_Normals,float4(WavePanningV,0.0,0)));
                v.vertex.xyz += (v.normal*node_4911.r*_Wavesstrength);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
		*/
    }
    FallBack "Diffuse"
    //CustomEditor "ShaderForgeMaterialInspector"
}
