[[vk::binding(0, 0)]] Sampler2D textures[];
[[vk::binding(0, 1)]] RWTexture2D targets[];

struct VOut {
    float4 position : SV_Position;
}

[shader("fragment")] 
float4 f_main(VOut input) : SV_Target {
	float3 msd = texture(msdf, texCoord).rgb;
    float sd = median(msd.r, msd.g, msd.b);
    float screenPxDistance = screenPxRange()*(sd - 0.5);
    float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);
    float4 color = lerp(bgColor, fgColor, opacity);
	return color;
}
