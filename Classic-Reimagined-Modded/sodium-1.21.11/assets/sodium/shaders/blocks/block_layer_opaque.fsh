#version 460 core

#import <sodium:include/fog.glsl>
#import <sodium:include/chunk_material.glsl>

in vec4 v_Color; // The interpolated vertex color
in vec2 v_TexCoord; // The interpolated block texture coordinates
in vec2 v_FragDistance; // The fragment's distance from the camera (cylindrical and spherical)
in float fadeFactor;

flat in uint v_Material;

uniform sampler2D u_BlockTex; // The block texture

uniform vec4 u_FogColor; // The color of the shader fog
uniform vec2 u_EnvironmentFog; // The start and end position for environmental fog
uniform vec2 u_RenderFog; // The start and end position for border fog
uniform vec2 u_TexelSize;
uniform bool u_UseRGSS;

out vec4 fragColor; // The output fragment for the color framebuffer

// Snap UV to nearest texel center
vec2 snapUV(vec2 uv, vec2 pixelSize, ivec2 texSize) {
    ivec2 i = clamp(ivec2(uv / pixelSize), ivec2(0), texSize - 1);
    return (vec2(i) + 0.5) * pixelSize;
}

// Nearest texel sampling
vec4 sampleNearest(sampler2D sourcer, vec2 uv, vec2 pixelSize) {
    return textureGrad(sourcer, snapUV(uv, pixelSize, textureSize(sourcer, 0)), dFdx(uv), dFdy(uv));
}

// Rotated Grid Super-Sampling
vec4 sampleRGSS(sampler2D sourcer, vec2 uv, vec2 pixelSize) {
    vec2 du = dFdx(uv), dv = dFdy(uv);
    float minPix   = min(pixelSize.x, pixelSize.y);
    float mipExact = max(0.0, log2(sqrt(length(du) * length(dv)) / minPix));
    int   mipLow   = int(mipExact);
    float blend    = smoothstep(minPix, minPix * 2.0, max(length(du), length(dv)));
    float mipBlend = fract(mipExact);

    const vec2 offs[4] = vec2[](vec2(0.0, 0.0), vec2(0.0, 0.0), vec2(0.0, 0.0), vec2(0.0, 0.0));

    vec4 low = vec4(0), high = vec4(0);
    for (int i=0;i<4;++i) {
        ivec2 sizeL = textureSize(sourcer, mipLow), sizeH = textureSize(sourcer, mipLow+1);
        low  += textureLod(sourcer, snapUV(uv + offs[i]*pixelSize, 1.0/vec2(sizeL), sizeL), float(mipLow));
        high += textureLod(sourcer, snapUV(uv + offs[i]*pixelSize, 1.0/vec2(sizeH), sizeH), float(mipLow+1));
    }

    return mix(sampleNearest(sourcer, uv, pixelSize), mix(low, high, mipBlend) * 0.25, blend);
}

void main() {
    vec4 color = u_UseRGSS ? sampleRGSS(u_BlockTex, v_TexCoord, u_TexelSize) : sampleNearest(u_BlockTex, v_TexCoord, u_TexelSize);
    color *= v_Color; // Apply per-vertex color modulator
    color = _linearFog(color, v_FragDistance, u_FogColor, u_EnvironmentFog, u_RenderFog, fadeFactor);

#ifdef USE_FRAGMENT_DISCARD
    if (color.a < _material_alpha_cutoff(v_Material)) {
        discard;
    }
#endif

    if (color.rgb == u_FogColor.rgb) {
        discard;
    } else {
        fragColor = color;
    }
}
