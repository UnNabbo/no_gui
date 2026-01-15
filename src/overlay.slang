[[vk::binding(0, 0)]] Sampler2D textures[];
[[vk::binding(0, 1)]] RWTexture2D targets[];

struct VOut {
    float4 position : SV_Position;
	float2 uv;
}


[shader("vertex")]
VOut v_main(uint id : SV_VertexID) {
	VOut vout;
	vout.uv = float2((id << 1) & 2, id & 2);
	vout.position = float4(vout.uv * float2(2, -2) + float2(-1, 1), 0, 1);
	return vout;
}

[shader("fragment")] 
float4 f_main(VOut input) : SV_Target {
    float4 o = textures[0].Sample(input.uv * float2(1, -1));
	return o;
}
