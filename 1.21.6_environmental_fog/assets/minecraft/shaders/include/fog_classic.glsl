#version 460

#ifndef _FOG_CLASSIC_GLSL
#define _FOG_CLASSIC_GLSL

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float classic_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    float fogFactor = 1.0f - sqrt(1.0f - pow(linear_fog_value(vertexDistance, 0, fogEnd), 2.0));
    float fogValue = sqrt(max(linear_fog_value(vertexDistance, fogStart, fogEnd), fogFactor));
    float fogValue2 = linear_fog_value(vertexDistance, 0, fogEnd) - 0.375 * (1 - linear_fog_value(vertexDistance, 0, fogEnd));
    return clamp(min(fogValue, fogValue2), 0.0, 1.0);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return mix(
        max(classic_fog_value(sphericalVertexDistance, renderDistanceStart, renderDistanceEnd),
        classic_fog_value(sphericalVertexDistance, environmentalStart, environmentalEnd)),
        1.0,
        clamp((0.0 - environmentalStart) / (environmentalEnd - environmentalStart), 0.0, 1.0)
    );
};

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmentalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

#endif // _FOG_CLASSIC_GLSL
