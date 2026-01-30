#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    color.a *= 1.0f - max(
        linear_fog_value(vertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd),
        linear_fog_value(vertexDistance, clamp(FogCloudsEnd, min(FogCloudsEnd, FogRenderDistanceStart), FogRenderDistanceStart),
        clamp(FogCloudsEnd, min(FogCloudsEnd, FogRenderDistanceEnd), FogRenderDistanceEnd)));
    fragColor = color;
}
    