#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} VertexOut;

vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
    float2 textureCoordinates[] = { float2(0, 1), float2(0, 0), float2(1, 1), float2(1, 0) };
    float4 position[] = { float4(-1, 1, 0, 1), float4(-1, -1, 0, 1), float4(1, 1, 0, 1), float4(1, -1, 0, 1) };
    
    VertexOut outVertex;
    outVertex.position = position[vertexID];
    outVertex.textureCoordinate = textureCoordinates[vertexID];
    
    return outVertex;
}

fragment half4 fragmentShader(VertexOut inFrag [[stage_in]], texture2d<half> yTexture [[texture(0)]], texture2d<half> uvTexture [[texture(1)]]) {
    constexpr sampler colorSampler(mip_filter::none, mag_filter::linear, min_filter::linear);
    
    half y = yTexture.sample(colorSampler, inFrag.textureCoordinate).r;
    half2 uv = uvTexture.sample(colorSampler, inFrag.textureCoordinate).rg;
    half3 yuv = half3(y, uv);
    half3 rgb = yuv - half3(0.0625, 0.5, 0.5);
    rgb.r = rgb.r * 1.164 + rgb.g * 0.000 - rgb.b * 1.793;
    rgb.g = rgb.r * 1.164 - rgb.g * 0.213 - rgb.b * 0.533;
    rgb.b = rgb.r * 1.164 + rgb.g * 2.112 - rgb.b * 0.000;
    
    return half4(rgb, 1.0);
}
