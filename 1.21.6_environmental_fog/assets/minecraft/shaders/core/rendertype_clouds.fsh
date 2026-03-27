#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    color.rgb *= mix(vertexColor.rgb, FogColor.rgb, total_fog_value(vertexDistance, vertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd));
    color.a *= floor((1.0f - pow(linear_fog_value(vertexDistance, 1.0, FogCloudsEnd), 2)) * vertexColor.a * 255) /255;
    // fog color calculation
    // alpha calculation
    // if the fog is fully opaque, use the fog color, otherwise use the vertex color
    fragColor = color;
}
    