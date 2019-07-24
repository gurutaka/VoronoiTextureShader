Shader "Unlit/CellTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CellularFineness("CellularFineness", Range(0.0, 100.0)) = 50.0
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _CellularFineness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float2 st = i.uv;
                st *= _CellularFineness;

                // 歪みの計算
                float x = 2 * i.uv.y + sin(_Time.y * 5);
                float distort = sin(_Time.y * 10) * 0.1 *
                                        sin(5 * x) *
                                         (- (x - 1) * (x - 1) + 1);
                // st.x += distort;

                float2 ist = floor(st);//整数
                float2 fst = frac(st);//少数の右側

                float distance = 5;
                float2 p_min;
                float2 p_uv_min;

                for (int y = -1; y <= 1; y++)
                for (int x = -1; x <= 1; x++)
                {
                    float2 neighbor = float2(x, y);
                    float2 neighbor_uv = ist/st;
                    //pointのアニメーション
                    //必ず整数地点の箱が起点(ist)になる
                    float2 p = 0.5 + 0.5 * sin(_Time.y + 6.2831 * random2(ist + neighbor));

                    float2 diff = neighbor + p - fst;
                    // distance = min(distance, length(diff));
                    if(distance > length(diff)){
                        distance = length(diff) ;
                        p_min = p;
                        p_uv_min = (st + diff)/_CellularFineness;
                    }
                }


                fixed4 col = tex2D(_MainTex, p_uv_min) ;
                return col;
            }
            ENDCG
        }
    }
}
