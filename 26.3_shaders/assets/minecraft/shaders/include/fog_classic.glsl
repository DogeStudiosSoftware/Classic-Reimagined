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
    float fogValue = sqrt(1.0f - pow(linear_fog_value(vertexDistance, 0, fogEnd), 2.0));
    float shortFogValue = smoothstep(0, fogEnd * 1.5, vertexDistance);
    float smoothFogValue = pow(shortFogValue, 1.0f - shortFogValue);
    float smootherFogValue = pow(pow(pow(pow(smoothFogValue, 1.0f - smoothFogValue), 1.0f - smoothFogValue), 1.0f - smoothFogValue), 1.0f - smoothFogValue);
    float envFogValue = sqrt(linear_fog_value(vertexDistance, 0, fogEnd * 4.0));
    return pow(pow(envFogValue * smootherFogValue, fogValue), sqrt(1.0f - pow(linear_fog_value(vertexDistance, fogStart, fogEnd), 2.0))); 
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(environmentalEnd, renderDistanceEnd) * (32 + sqrt(2.0) / 3.0f) / 32.0f;
    float classicStart = classicEnd * 0.75;
    return mix(
        classic_fog_value(sphericalVertexDistance, classicStart, classicEnd),
        1.0,
        clamp((0.0 - environmentalStart) / (environmentalEnd - environmentalStart), 0.0, 1.0)
    );
};

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmentalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

#endif // _FOG_CLASSIC_GLSL
