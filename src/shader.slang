[[vk::binding(0, 0)]] Sampler2D textures[];
[[vk::binding(0, 1)]] RWTexture2D targets[];

#define QUAD_BASE_SIZE 1

struct Data {
	Instance_Data* instances;
	float4x4 view;
}

struct Instance_Data {
	float4 position;
}


struct Vertex {
	float3 position;
}
	
struct VOut {
    float4 position : SV_Position;
}

static float3 vertices[] = {
	{0, 0, 0},
	{0, QUAD_BASE_SIZE, 0},
	{QUAD_BASE_SIZE, 0, 0},
	{QUAD_BASE_SIZE, QUAD_BASE_SIZE, 0},
};

[[vk::push_constant]] Data* data;
[shader("vertex")]
VOut v_main(uint vertex_index : SV_VertexID, uint instance_index : SV_InstanceID) {
	VOut vout;
	let vertex = vertices[vertex_index];
	let instance_data = data.instances[instance_index];

	
	float2 position = (vertex.xy * (instance_data.position.zw - instance_data.position.xy)) + instance_data.position.xy;
	vout.position = mul(float4(position, 0, 1), data.view);
	return vout;
}

[shader("fragment")]
float4 f_main(VOut input) : SV_Target {
    let color = float4(0, 1, 0, 1);
	return color;
}
