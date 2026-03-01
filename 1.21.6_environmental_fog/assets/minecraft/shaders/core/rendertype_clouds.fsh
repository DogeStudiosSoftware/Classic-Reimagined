#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    // fog color calculation
    color.rgb = 
    mix(color.rgb, FogColor.rgb, total_fog_value(vertexDistance, vertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd));
    // alpha calculation
    color.a *= 1.0f - mix(0.0,
    linear_fog_value(vertexDistance, 0, FogCloudsEnd),
    linear_fog_value(vertexDistance, min(FogCloudsEnd, FogRenderDistanceEnd) / 16, FogCloudsEnd));
    fragColor = color;
}
    