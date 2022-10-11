///================================
/// Highlight Shader    111.07.19
///================================
Shader "Tool-Kid/Runtime-Highlighter" {
  Properties {
    [Enum(ToolKid.Shader.HighlightTiming)] _Highlight("Highlight", Float) = 0
    [Enum(ToolKid.Shader.HighlightType)] _TransparentMask("Performence", Float) = 0

    _Color("Color", Color) = (1, 1, 1, 1)
    _ShellSize("Shell Size", Range(0, 10)) = 2
  }
   
  SubShader {
    Tags {
      "Queue" = "Transparent+110"
      "RenderType" = "Transparent"
      "DisableBatching" = "True"
    }
     Pass {
      Name "TransparentMask"
      Cull Off
      ZTest [_TransparentMask]
      ZWrite Off
      ColorMask 0

      Stencil {
        Ref 1
        Pass Replace
      }
    }
    Pass {
      Name "Highlight"
      Cull Off
      ZTest [_Highlight]
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha
      ColorMask RGB

      Stencil {
        Ref 1
        Comp NotEqual
      }

      CGPROGRAM
      #include "UnityCG.cginc"

      #pragma vertex vert
      #pragma fragment frag

      struct appdata {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float3 smoothNormal : TEXCOORD3;
        UNITY_VERTEX_INPUT_INSTANCE_ID
      };

      struct v2f {
        float4 position : SV_POSITION;
        fixed4 color : COLOR;
        UNITY_VERTEX_OUTPUT_STEREO
      };

      uniform fixed4 _Color;
      uniform float _ShellSize;

      v2f vert(appdata input) {
        v2f output;

        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

        float3 normal = any(input.smoothNormal) ? input.smoothNormal : input.normal;
        float3 viewPosition = UnityObjectToViewPos(input.vertex);
        float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, normal));

        output.position = UnityViewToClipPos(viewPosition + viewNormal * -viewPosition.z * _ShellSize / 1000.0);
        output.color = _Color;

        return output;
      }

      fixed4 frag(v2f input) : SV_Target {
        return input.color;
      }
      ENDCG
    }
  }  
}
