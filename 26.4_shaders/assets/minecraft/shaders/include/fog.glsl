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

float classic_fog_value(float vertexDistance, float density) {
    return linear_fog_value(vertexDistance, 0.0, 1.0 / density);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(renderDistanceEnd, environmentalEnd);
    float classicStart = classicEnd * 0.25;
    // water fog
    float water_mixel = clamp((classicEnd - 24.0) / 72.0, 0.0, 1.0);
    float WaterFogDensity = mix(0.1, 0.03, water_mixel);
    float WaterEnvironmentalFogValue = pow(classic_fog_value(sphericalVertexDistance, WaterFogDensity), 1.0 / 1.5);
    // lava fog
    float lavaDensity = 2.0;
    float LavaEnvironmentalFogValue = 1.0f - exp(-lavaDensity * sphericalVertexDistance);
    // nether fog
    float NetherFogDensity = 1.0 / renderDistanceEnd;
    float NetherEnvironmentalFogValue = classic_fog_value(sphericalVertexDistance, NetherFogDensity);
    if (environmentalStart == -8.0 && environmentalEnd <= 96.0) {
        // water fog
        return WaterEnvironmentalFogValue;
    }
    if (environmentalStart == 0.25 && environmentalEnd <= 1.0) {
        // lava fog
        return LavaEnvironmentalFogValue;
    }
    if (environmentalStart == 10.0 && environmentalEnd == 96.0) {
        // nether fog
        return NetherEnvironmentalFogValue;
    } else {
        return linear_fog_value(sphericalVertexDistance, classicStart, classicEnd);
    }
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
