Shader "Path/Name"
{
    Properties  //即宣告
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        // 常見的宣告內容
        // Color            顏色，由RGBA（紅綠藍和透明度）四個量來定義
        // 2D               尺寸為2次方倍的貼圖（256，512等）取樣UV並顯示其每個像素的顏色
        // Rect             尺寸非2次方倍的貼圖 ~
        // Cube             Cube map texture（立方體紋理）,可作反射效果（Skybox與Reflection）或取樣點
        // Range(min, max)  限定範圍的浮點數,一般用來調整Shader某些特性的參數（e.g.透明度渲染從0至1）
        // Float            浮點數
        // Vector           四維向量
        //_Name("Display Name", type) = defaultValue[{options}]
        //{option}只對2D,Rect,Cube有效，至少要有一個空白{}，需要時將選擇填入{}內，複數時以空格區分
        // 選項有ObjectLinear, EyeLinear, SphereMap, CubeReflect, CubeNormal (OpenGL中TexGen的模式)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        // 標籤用於判斷何時取用這段程式碼
        // 常見標籤
        // "RenderType" = "Transparent"     渲染透明
        // "IgnoreProjector"="True"         不被Projectors影響
        // "ForceNoShadowCasting"="True"    強制無陰影覆蓋
        // "Queue"="xxx"                    渲染序列
        //  Background      1000            最早被調用的渲染,用來渲染天空盒或者背景
        //  Geometry        2000            預設值,用來渲染非透明物體（普通情況下,場景中的絕大多數物體應該是非透明的）
        //  AlphaTest       2450            用來渲染經過Alpha Test的像素,單獨為AlphaTest設定一個Queue是出於對效率的考慮
        //  Transparent     3000            以從後往前的順序渲染透明物體
        //  Overlay         4000            用來渲染疊加的效果,是渲染的最後階段（比如鏡頭光暈等特效）
        // "Queue"="Transparent+100"        表調用於Transparent後100之Queue
        LOD 200
        // 細節級距(Level Of Detail),小於該值則不調用此著色器
        // VertexLit (頂點)及其系列 = 100
        // Decal, Reflective VertexLit = 150 (貼花,反射頂點)
        // Diffuse = 200 (漫反射)
        // Diffuse Detail, Reflective Bumped Unlit, Reflective Bumped VertexLit = 250 (漫反射細節,反射凹凸不亮,反射凹凸頂點)
        // Bumped, Specular = 300 (碰撞,鏡面反射)
        // Bumped Specular = 400 (凹凸高光)
        // Parallax = 500 (視差)
        // Parallax Specular = 600 (視差鏡面反射)        

        CGPROGRAM
        // 計算機圖學程序,使用 Cg/HLSL 語言
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        //#pragma surface surfaceFunction lightModel [optionalparams]
        //#指令 表面 函式名稱 光照模式 [指令代碼]
        
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        // sampler2D HLSL中的貼圖形別,其他還有1D,3D,Cube等
        // 不同於Property是Unity可以使用的ShaderLab,此處宣告是用於本CG程序,需與Property中變數名稱相同,才可以進行連結

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        //      struct SurfaceOutput {
        //          half3 Albedo;     //像素的顏色
        //          half3 Normal;     //像素的法向值
        //          half3 Emission;   //像素的發散顏色
        //          half Specular;    //像素的鏡面高光
        //          half Gloss;       //像素的發光強度
        //          half Alpha;       //像素的透明度
        //      };

        ENDCG
    }
    FallBack "Diffuse"
}
