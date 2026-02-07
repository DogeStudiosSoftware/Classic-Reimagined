#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    color.a *= 1.0f - max(mix(
        linear_fog_value(vertexDistance, FogCloudsEnd, FogCloudsEnd),
        linear_fog_value(vertexDistance, 0, FogCloudsEnd),
        linear_fog_value(vertexDistance, max(FogCloudsEnd / 16, 8), FogCloudsEnd)),
        mix(
        linear_fog_value(vertexDistance, FogRenderDistanceStart, FogRenderDistanceStart),
        linear_fog_value(vertexDistance, 0, FogRenderDistanceStart),
        linear_fog_value(vertexDistance, max(FogRenderDistanceStart / 16, 8), FogRenderDistanceEnd)));
    fragColor = color;
}
    