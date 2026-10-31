#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;

layout(location = 0) out vec4 fragColor;

void main() {
    float squaredSky = clamp(floor(cylindricalVertexDistance / ((512.0) / sqrt(2.0))), 0.0, 1.0); // FogColor
    float spherical_fog = clamp((1.0 - exp(-sphericalVertexDistance * (1.0 / (max(FogRenderDistanceEnd - 32.0, 0.0) / sqrt(2.0))))) / (1.0 - exp(-1.0)), 0.0, 1.0);
    fragColor = mix(ColorModulator, FogColor, max(spherical_fog, squaredSky));
}
