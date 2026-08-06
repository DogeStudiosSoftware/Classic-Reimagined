// Integer-snapped nearest sampling using floor
vec4 sampleNearest(sampler2D source, vec2 uv, vec2 pixelSize, vec2 du, vec2 dv, vec2 texelScreenSize) {
    // Snap UV to integer texel coordinates using floor
    ivec2 texelCoords = ivec2(floor(uv / pixelSize));
    vec2 texelCenter = (vec2(texelCoords) - 0.5) * pixelSize;

    // Offset correction based on screen size
    vec2 texelOffset = (uv - texelCenter) / texelScreenSize;
    texelOffset = clamp(texelOffset + 0.5, 0.0, 1.0);

    // Reconstruct snapped UV
    vec2 snappedUV = texelCenter + texelOffset * pixelSize;

    return textureGrad(source, snappedUV, du, dv);
}

vec4 sampleNearest(sampler2D source, vec2 uv, vec2 pixelSize) {
    vec2 du = dFdx(uv);
    vec2 dv = dFdy(uv);
    vec2 texelScreenSize = sqrt(du * du + dv * dv);
    return sampleNearest(source, uv, pixelSize, du, dv, texelScreenSize);
}

// Rotated Grid Super-Sampling with floor-based integer snapping
vec4 sampleRGSS(sampler2D source, vec2 uv, vec2 pixelSize) {
    vec2 du = dFdx(uv);
    vec2 dv = dFdy(uv);

    vec2 texelScreenSize = sqrt(du * du + dv * dv);
    float maxTexelSize = max(texelScreenSize.x, texelScreenSize.y);

    float minPixelSize = min(pixelSize.x, pixelSize.y);

    float transitionStart = minPixelSize * 1.0;
    float transitionEnd = minPixelSize * 2.0;
    float blendFactor = smoothstep(transitionStart, transitionEnd, maxTexelSize);

    float duLength = length(du);
    float dvLength = length(dv);
    float minDerivative = min(duLength, dvLength);
    float maxDerivative = max(duLength, dvLength);

    float effectiveDerivative = sqrt(minDerivative * maxDerivative);

    float mipLevelExact = max(0.0, log2(effectiveDerivative / minPixelSize));

    float mipLevelLow = floor(mipLevelExact);
    float mipLevelHigh = mipLevelLow + 1.0;
    float mipBlend = fract(mipLevelExact);

    const vec2 offsets[4] = vec2[](
        vec2(0.125, 0.375),
        vec2(-0.125, -0.375),
        vec2(0.375, -0.125),
        vec2(-0.375, 0.125)
    );

    vec4 rgssColorLow = vec4(0.0);
    vec4 rgssColorHigh = vec4(0.0);

    // Floor-based integer snapping applied to RGSS offsets
    for (int i = 0; i < 4; ++i) {
        vec2 sampleUV = uv + offsets[i] * pixelSize;
        ivec2 texelCoords = ivec2(floor(sampleUV / pixelSize));
        vec2 texelCenter = (vec2(texelCoords) + 0.5) * pixelSize;

        rgssColorLow += textureLod(source, texelCenter, mipLevelLow);
        rgssColorHigh += textureLod(source, texelCenter, mipLevelHigh);
    }

    rgssColorLow *= 0.25;
    rgssColorHigh *= 0.25;

    vec4 rgssColor = mix(rgssColorLow, rgssColorHigh, mipBlend);

    vec4 nearestColor = sampleNearest(source, uv, pixelSize, du, dv, texelScreenSize);

    return mix(nearestColor, rgssColor, blendFactor);
}
