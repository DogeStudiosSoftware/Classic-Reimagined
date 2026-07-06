#version 460

layout(std140) uniform Fog {
    vec4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
};

#moj_import <fog_classic.glsl>

float fog_cylindrical_distance(vec3 pos) {
  float distXZ = length(pos.xz);
  float distY = abs(pos.y);
  return max(distXZ, distY);
}

float fog_spherical_distance(vec3 pos) {
    return length(pos);
}
