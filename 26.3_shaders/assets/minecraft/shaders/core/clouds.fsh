#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:oit.glsl>

in float vertexDistance;
in vec4 vertexColor;

#ifndef OIT_ALPHA_ONLY
out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    #endif
    return color;
}

void main() {
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    color.rgb *= mix(vertexColor.rgb, FogColor.rgb, total_fog_value(vertexDistance, vertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd));
    #ifndef OIT_DEPTH_BOUNDS
    color.a *= floor((1.0f - pow(linear_fog_value(vertexDistance, 1.0, FogCloudsEnd), 2)) * vertexColor.a * 255) /255;
    #endif

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}