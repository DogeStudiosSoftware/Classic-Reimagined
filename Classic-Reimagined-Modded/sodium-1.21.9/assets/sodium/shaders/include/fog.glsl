const int FOG_SHAPE_SPHERICAL = 0;
const int FOG_SHAPE_CYLINDRICAL = 1;

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    fogEnd *= 30.5 / 30.0; // Adjust for better visual match to original beta fog
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return mix(
        mix(
            linear_fog_value(sphericalVertexDistance, environmentalStart * 2, environmentalEnd * 2),
            linear_fog_value(sphericalVertexDistance, 0, environmentalEnd),
            linear_fog_value(sphericalVertexDistance, environmentalEnd / 16, environmentalEnd)
        ),
        linear_fog_value(sphericalVertexDistance, 0, min(renderDistanceEnd, environmentalEnd)),
        mix(
            linear_fog_value(sphericalVertexDistance, 0, 521),
            linear_fog_value(sphericalVertexDistance, 0, renderDistanceEnd),
            linear_fog_value(sphericalVertexDistance, renderDistanceEnd / 256, renderDistanceEnd)
        )
    );
}

vec4 _linearFog(vec4 fragColor, vec2 fragDistance, vec4 fogColor, vec2 environmentFog, vec2 renderFog) {
#ifdef USE_FOG
    float fogValue = total_fog_value(fragDistance.y, fragDistance.x, environmentFog.x, environmentFog.y, renderFog.x, renderFog.y);
    return vec4(mix(fragColor.rgb, fogColor.rgb, fogValue * fogColor.a), fragColor.a);
#else
    return fragColor;
#endif
}

vec2 getFragDistance(vec3 position) {
    return vec2(max(length(position.xz), abs(position.y)), length(position));
}