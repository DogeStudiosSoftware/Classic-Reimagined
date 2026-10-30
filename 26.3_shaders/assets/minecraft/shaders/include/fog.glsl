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
    return 1.0f - exp(-density * vertexDistance);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(environmentalEnd, renderDistanceEnd);
    float classicStart = classicEnd * 0.25f;
    float waterDensity = 0.1f;
    float lavaDensity = 2.0f;
    if (environmentalStart == -8.0) { // thick fog in spectator (lava, powdered snow) and water fog at 96 blocks
        float thickFogDensity = 0.4 - (classicEnd / 320);
        return exponential_fog_value(sphericalVertexDistance, thickFogDensity);
    }
    if (environmentalStart == 0.25 && environmentalEnd == 1.0) { // lava fog in classic exponential fog mode
        return exponential_fog_value(sphericalVertexDistance, lavaDensity);
    }
    if (environmentalStart == 0.0 && environmentalEnd == 5.0) { // lava with fire resistance fog in classic exponential fog mode
        lavaDensity /= 5.0f;
        return exponential_fog_value(sphericalVertexDistance, lavaDensity);
    }
    if (environmentalStart == 0.0 && environmentalEnd == 2.0) { // powder snow fog in classic exponential fog mode
        float powderSnowDensity = 1.0f;
        return exponential_fog_value(sphericalVertexDistance, powderSnowDensity);
    }
    // ####################################################################################################################
    if (environmentalStart == 10.0 && environmentalEnd == 96.0) { // nether fog in classic linear fog mode
        float dimDistance = 1.0 / renderDistanceEnd;
        float dimFog = clamp(exponential_fog_value(sphericalVertexDistance, dimDistance) / (1.0f - exp(-1.0f)), 0.0f, 1.0f);
        return dimFog;
    } else { // overworld fog in classic linear fog mode -------------------------
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
