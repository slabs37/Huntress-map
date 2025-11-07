Shader "Custom/FogMB"
{
	Properties
	{
	   _Color("Main Color", Color) = (1, 1, 1, .5)
       _Opacity("Opacity", float) = 1
	   _IntersectionThresholdMax("Intersection Threshold Max", float) = 1
       _Pow("Fog to power of", float) = 3
       _SecondDepth("Second Depth Disable", float) = 0
       [Toggle(HEIGHT_FOG)] _HeightEnabled ("Height Enabled", Int) = 0
        _HeightFogStart ("Height Fog Start", Float) = 0
        _HeightFogEnd ("Height Fog End", Float) = 10

	}
		SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent"  }

		Pass
		{
		   Blend SrcAlpha OneMinusSrcAlpha
		   ZWrite Off
           Cull Off
           ColorMask RGB
		   CGPROGRAM
		   #pragma vertex vert
		   #pragma fragment frag
           #pragma shader_feature HEIGHT_FOG
		   #pragma multi_compile_fog
		   #include "UnityCG.cginc"
           #include "Assets/VivifyTemplate/Utilities/Shader Functions/Math.cginc"

		   struct appdata
		   {
			   float4 vertex : POSITION;
               
		   };

		   struct v2f
		   {
			   float4 scrPos : TEXCOORD0;
               float3 worldPosition : TEXCOORD1;
			   UNITY_FOG_COORDS(1)
			   float4 vertex : SV_POSITION;
		   };

		   sampler2D _CameraDepthTexture;
		   float4 _Color;
		   float4 _IntersectionColor;
		   float _IntersectionThresholdMax;
           float _Opacity;
           float _Pow;
           float _SecondDepth;
           float _HeightFogStart;
            float _HeightFogEnd;

		   v2f vert(appdata v)
		   {
			   v2f o;
			   o.vertex = UnityObjectToClipPos(v.vertex);
			   o.scrPos = ComputeScreenPos(o.vertex);
               o.worldPosition = localToWorld(v.vertex); // from Math.cginc
			   UNITY_TRANSFER_FOG(o,o.vertex);
			   return o;
		   }


			half4 frag(v2f i) : SV_TARGET
			{
			   float depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
               #if HEIGHT_FOG
                float heightFog = smoothstep(_HeightFogStart, _HeightFogEnd, i.worldPosition.y);
                heightFog = pow(heightFog, 10);
                depth *= heightFog;
               #endif
			   float diff = saturate(_IntersectionThresholdMax * (depth - i.scrPos.w));
               float diff2 = saturate(_IntersectionThresholdMax * (depth*_SecondDepth - i.scrPos.w)) ;
			   fixed4 col = lerp(fixed4(_Color.rgb, 0.0), _Color, pow(diff, _Pow) - diff2);
               fixed4 colo = col*fixed4(1, 1, 1, _Opacity);

			   UNITY_APPLY_FOG(i.fogCoord, colo);
			   return colo;
			}

			ENDCG
		}
	}
}