#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    color.a *= 1.0f - max(max(
        linear_fog_value(vertexDistance, FogCloudsEnd / 4, FogCloudsEnd),
        linear_fog_value(vertexDistance, FogRenderDistanceStart / 4, FogRenderDistanceEnd)),
        linear_fog_value(vertexDistance, FogEnvironmentalEnd / 4, FogEnvironmentalEnd * 31.0 / 30.0));
    fragColor = color;
}
    