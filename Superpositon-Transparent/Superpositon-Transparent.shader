Shader "Tool-Kid/Superpositon-Transparent"
{
    Properties
    {
		_MainTex("Color Texture", 2D) = "white" {}		
		_FogNear("Near Boundary", Range(0, 50)) = 0		
		_FogFar("Far Boundary", Range(0, 50)) = 50

		_FogTop("Top Height", Range(0, 20)) = 1
		_FogBot("Bottom Height", Range(-10, 10)) = -5
    }
    SubShader
    {
		Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				// Define Vertax Value
				float3 WordPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
            };
			float4 _Color;
			sampler2D _MainTex;
			sampler2D _AoTex;
			float _FogNear;
			float _FogFar;

			float _FogTop;
			float _FogBot;
            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv1;
				o.uv.zw = v.uv2;
				// Convert object vertex to screen position
				o.screenPos = ComputeScreenPos(o.vertex);
				// Convert vertex position from object to world
				o.WordPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy);


			// Get Distance Between Camera and Object Vertax
			float DistanceRamp = distance(i.WordPos, _WorldSpaceCameraPos.xyz);
			// Use smoothstep, _FogNear and _FogFar to limit value 0-1
			DistanceRamp = smoothstep(_FogNear, _FogFar, DistanceRamp);

			// Define Dither Matrix
			// Dither Matrix: https://en.wikipedia.org/wiki/Ordered_dithering
			float4x4 thresholdMatrix =
			{ 1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
			  13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
			   4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
			  16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
			};
			float4x4 _RowAccess = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };

			// Get Screen Position (0-1) while 'w' is varitary for zoom in/out
			float2 pos = i.screenPos.xy / i.screenPos.w;

			// 0-1 * Screen Pixel Count
			pos *= _ScreenParams.xy;
			// Height Calculating
			float HightRamp = 1 - smoothstep(_FogBot, _FogTop, i.WordPos.y);
			// Reserving Ground
			DistanceRamp = saturate( DistanceRamp + HightRamp);
			// Set Near Shadow
			col.rgb *= pow(DistanceRamp,1);


			// Calculating transparent by ordered dithering
			clip( step(0.5, col.a) *DistanceRamp - thresholdMatrix[fmod(pos.x, 4)] * _RowAccess[fmod(pos.y, 4)]);
			// Output
                return col;
            }
            ENDCG
        }
    }
}