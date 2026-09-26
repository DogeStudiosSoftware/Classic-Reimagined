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

float classic_fog_value(float vertexDistance, float fogStart, float fogEnd) {
        float denom = fogEnd - fogStart;
        float fogFactor = clamp((fogEnd - vertexDistance) / (denom + 0.001), 0.0, 1.0);
    return mix(1.0, 0.0, fogFactor); 
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    float classicEnd = min(renderDistanceEnd, environmentalEnd);
    float classicStart = min(classicEnd * 0.25, (environmentalStart / environmentalEnd) * classicEnd);
    if (environmentalEnd > renderDistanceEnd) {
        float fogExp = -(1.0 / (sqrt(linear_fog_value(0.0, environmentalStart, environmentalEnd)) - 1.0));
        classicStart = classicEnd / pow(4.0, fogExp);
        return mix(
            classic_fog_value(sphericalVertexDistance, classicStart, classicEnd),
            classic_fog_value(sphericalVertexDistance, -classicStart, classicEnd),
            clamp(fogExp - 1.0, 0.0, 1.0)
        );
    }
    if (environmentalStart == 10.0 && environmentalEnd == 96.0) {
        // classic nether fog, use render distance fog properties
        classicEnd = renderDistanceStart;
    }
    return classic_fog_value(sphericalVertexDistance, classicStart, classicEnd);
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
