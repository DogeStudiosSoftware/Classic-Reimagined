#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    color.a *= 1.0f - mix(
        mix(
            linear_fog_value(vertexDistance, 0, 2048),
            linear_fog_value(vertexDistance, 0, FogCloudsEnd),
            linear_fog_value(vertexDistance, FogCloudsEnd / 16, FogCloudsEnd)
        ),
        linear_fog_value(vertexDistance, 0, min(FogRenderDistanceEnd, FogCloudsEnd)),
        mix(
            linear_fog_value(vertexDistance, 0, 521),
            linear_fog_value(vertexDistance, 0, FogRenderDistanceEnd),
            linear_fog_value(vertexDistance, FogRenderDistanceEnd / 256, FogRenderDistanceEnd)
        )
    );
    fragColor = color;
}
    