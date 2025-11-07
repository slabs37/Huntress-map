// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/StarAdditive" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
    _Opacity ("Opacity", range(0, 1)) = 1.0
    _RotationSpeed ("Rotation Speed", Float) = 2.0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha One
	AlphaTest Greater .01
	ColorMask RGBA
	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles

			#include "UnityCG.cginc"
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Math.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
            float _Opacity;
            float _RotationSpeed;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
			
			float4 _MainTex_ST;
            float _Rotation;

			v2f vert (appdata_t v)
			{
				v2f o;
				//o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

                // Rotate Vertices
                v.vertex = rotatePoint(float3(0,_RotationSpeed*_Time.y,0), v.vertex.xyz).xyzz; // from Math.cginc

                // Output Rotated Vertex
                o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				
				fixed4 finalCol = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				return float4(finalCol.rgb, finalCol.a*_Opacity);
			}
			ENDCG 
		}
	}	
}
}