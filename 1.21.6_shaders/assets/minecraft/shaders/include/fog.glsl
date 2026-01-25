#version 460
#moj_import <dynamictransforms.glsl>
// code by MrGlitchDogePE
// OpenGL Shading Language (GLSL) code for Minecraft shaders
// This code runs with OpenGL version 4.6
layout(std140) uniform Fog {
    vec4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
};
const int shape = 0; // 0 = spherical, 1 = cylindrical, 2 = planar, 3 = experimental
// Calculate the fog value based on the distance from the camera
#moj_import <fog_classic.glsl>

// Calculate the distance for fog based on the shape
// Terrain shape is fog_cylindrical_distance
float fog_cylindrical_distance(vec3 pos) {
  if (shape == 0) {
    // Spherical fog distance calculation
    return length(pos);
    } else if (shape == 1) {
      // Cylindrical fog distance calculation
      float distXZ = length(pos.xz);
      float distY = abs(pos.y);
      return max(distXZ, distY);
      } else if (shape == 2) {
        // Planar fog distance calculation
        return abs((ModelViewMat * vec4(pos, 1.0)).z);
        } else if (shape == 3) {
          // Experimental fog(Extra)
          return max(abs((ModelViewMat * vec4(pos, 1.0)).z), length(pos.zx));
        }
}

float fog_spherical_distance(vec3 pos) {
  return length((ModelViewMat * vec4(pos, 1.0)));
}

float fog_planar_distance(vec3 pos) {
  // Experimental fog distance calculation
  return abs((ModelViewMat * vec4(pos, 1.0)).z);
}