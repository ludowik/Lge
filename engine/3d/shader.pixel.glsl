#pragma language glsl3

uniform float border = 0.;

uniform highp float useColor;
uniform highp float useTexCoord;
uniform highp float useNormal;
uniform highp float useLight;
uniform highp float useLightAmbient;
uniform highp float useLightDiffuse;
uniform highp float useLightSpecular;

uniform highp float useInstanced;

uniform vec3 cameraPos;

varying vec3 vertexPos;
varying vec3 fragmentPos;
varying vec3 normal;

varying vec4 vertexProjection;

struct Light {
    float lightType;

    vec4 lightColor;
    vec3 lightPos;
    
    float ambientStrength;
    float diffuseStrength;
    float specularStrength;
};

uniform Light lights[32];
uniform int lightsCount;

vec4 ambient(Light light) {
    return light.ambientStrength * light.lightColor;
}

vec4 diffuse(Light light) {
//    vec3 lightDir = normalize(light.lightPos - fragmentPos);  
    vec3 lightDir = normalize(light.lightPos);  
    float diff = max(dot(normal, lightDir), 0.0);    
    return light.diffuseStrength * diff * light.lightColor;
}

vec4 specular(Light light) {
    vec3 lightDir = normalize(light.lightPos - fragmentPos);  
    vec3 viewDir = normalize(cameraPos - fragmentPos);
    vec3 reflectDir = reflect(-lightDir, normal);  
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.);
    return light.specularStrength * spec * vec4(1., 0., 0., 1.); 
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 finalColor = vec4(1., 1., 1., 1.);
    
    if (border == 0.) {
        if (useColor == 1.) {
            finalColor = color;
        }
        
        if (useTexCoord == 1.) {
            vec4 texturecolor = Texel(tex, texture_coords);
            finalColor = texturecolor * finalColor;
        }
        
        if (useLight == 1.) {
            vec4 composition = vec4(0., 0., 0., 0.);

            for (int i=0; i<lightsCount; ++i) {
                Light light = lights[i];
                if (light.lightType == 0. && useLightAmbient == 1.) {
                    composition += ambient(light);
                }

                if (useLightDiffuse == 1. && useNormal == 1.) {
                    composition += diffuse(light);
                }

                if (useLightSpecular == 1. && useNormal == 1.) {
                    composition += specular(light);
                }
            }

            finalColor = vec4(composition.rgb, 1.) * finalColor;
        }

        return finalColor;
    }

    float size = 0.002 * vertexProjection.z;
    if (texture_coords.x >= size &&
        texture_coords.x <= 1.-size &&
        texture_coords.y >= size &&
        texture_coords.y <= 1.-size)
    {
        discard;
    }

    return finalColor;
}
