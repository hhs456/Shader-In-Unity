Shader "Tool-Kid/Track-Bend-Simulator"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_HorCurve("Horizontal Curve", Range(-0.003,0.003)) = 0.0
		_VerCurve("Vertical Curve", Range(-0.003,0.003)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;

				// Get UV
                float2 uv : TEXCOORD0;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_FOG_COORDS(4)
            };

			//Texture
            sampler2D _MainTex;
			float _HorCurve;
			float _VerCurve;
            v2f vert (appdata v)
            {
                v2f o;

                o.uv = v.uv;
				
				// Get Word Position
				float3 WordPos = mul(unity_ObjectToWorld, v.vertex);

				//左右左右坐标作为弯道 
				//依据Z坐标求平方获取弯曲曲线，越远离世界坐标原点，弯曲效果越明显。
				//最后乘以左右弯道弯曲方向，和弯曲强度
				WordPos.x +=pow(WordPos.z, 2)*_HorCurve;
				//方法与上面相同，改变Y轴，获得上下坡效果
				WordPos.y += pow(WordPos.z, 2)*_VerCurve;

				//修正模型位置，WordPos 不包含物体自身的空间位移
				WordPos -= mul(unity_ObjectToWorld, float4(0, 0, 0, 1));

				//修改世界顶点转回物体自身顶点。
				v.vertex = mul(unity_WorldToObject, WordPos);

				//转换为裁切空间
				o.vertex = UnityObjectToClipPos(v.vertex);
				
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// Get Texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}