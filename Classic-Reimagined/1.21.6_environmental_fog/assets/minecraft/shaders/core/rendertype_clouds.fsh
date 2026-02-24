#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    // fog color calculation
    color.rgb = 
    mix(color.rgb, FogColor.rgb,
    mix(
        mix(
            linear_fog_value(vertexDistance, 0, 2048),
            linear_fog_value(vertexDistance, 0, 1024),
            linear_fog_value(vertexDistance, 64, 1024)
        ),
        linear_fog_value(vertexDistance, 0, min(FogRenderDistanceEnd, 1024)),
        mix(
            linear_fog_value(vertexDistance, 0, 521),
            linear_fog_value(vertexDistance, 0, FogRenderDistanceEnd),
            linear_fog_value(vertexDistance, FogRenderDistanceEnd / 256, FogRenderDistanceEnd)
        )
    ));
    // alpha calculation
    color.a *= 1.0f - mix(0.0,
    linear_fog_value(vertexDistance, 0, FogCloudsEnd),
    linear_fog_value(vertexDistance, min(FogCloudsEnd, FogRenderDistanceEnd) / 16, FogCloudsEnd));
    fragColor = color;
}
    