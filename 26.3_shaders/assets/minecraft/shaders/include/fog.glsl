layout(std140) uniform Fog {
    vec4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
};

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(renderDistanceEnd, environmentalEnd);
    float classicStart = classicEnd * 0.25;
    if (environmentalStart == -8.0 && environmentalEnd <= 96.0) {
        // classic water fog, uses exponential fog properties
        float density = 0.05;
        float exponential_fog_factor = 1.0 - clamp(exp(-density * sphericalVertexDistance), 0.0, 1.0);
        return pow(exponential_fog_factor, 1.0f - linear_fog_value(sphericalVertexDistance, 0, renderDistanceEnd));
    }
    if (environmentalStart == 0.25 && environmentalEnd == 1.0) {
        // classic lava fog, uses exponential fog properties
        float density = 2.0;
        float exponential_fog_factor = 1.0 - clamp(exp(-density * sphericalVertexDistance), 0.0, 1.0);
        return pow(exponential_fog_factor, 1.0f - linear_fog_value(sphericalVertexDistance, 0, renderDistanceEnd));
    }
    if (environmentalStart == 10.0 && environmentalEnd == 96.0) {
        // classic nether fog, use render distance fog properties
        classicEnd = renderDistanceStart;
        classicStart = 0.0;
    }
    return linear_fog_value(sphericalVertexDistance, classicStart, classicEnd);
}

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmentalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float fog_spherical_distance(vec3 pos) {
    return length(pos);
}

float fog_cylindrical_distance(vec3 pos) {
    float distXZ = length(pos.xz);
    float distY = abs(pos.y);
    return max(distXZ, distY);
}
