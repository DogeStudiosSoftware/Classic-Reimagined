#version 460

#ifndef _FOG_CLASSIC_GLSL
#define _FOG_CLASSIC_GLSL

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    fogEnd *= 30.5 / 30.0; // Adjust for better visual match to original beta fog
    if (vertexDistance <= fogStart) {
        return 0.0;
    } else if (vertexDistance >= fogEnd) {
        return 1.0;
    }

    return (vertexDistance - fogStart) / (fogEnd - fogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd) {
    if(environmantalEnd > renderDistanceEnd) {
        // this is probably overworld atmosphere fog, if so only use render distance fog properties
        return mix(
        linear_fog_value(sphericalVertexDistance, renderDistanceEnd, renderDistanceEnd),
        linear_fog_value(sphericalVertexDistance, 0, renderDistanceEnd),
        linear_fog_value(sphericalVertexDistance, max(renderDistanceEnd / 16, 8), renderDistanceEnd));
    }
    // otherwise use the mix of environmental and render distance
    // in this case environmental fog would be other effects such as underwater, blindness, powder snow, etc fog
    return max(
        linear_fog_value(sphericalVertexDistance, environmentalStart, environmantalEnd),
        linear_fog_value(sphericalVertexDistance, environmentalStart / 4, environmantalEnd));
}

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmentalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

#endif // _FOG_CLASSIC_GLSL
