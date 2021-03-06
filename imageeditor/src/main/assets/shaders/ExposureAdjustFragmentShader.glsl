/**
 * RGB to HSV convert algorithm is from Sam Hocevar: http://lolengine.net/blog/2013/01/13/fast-rgb-to-hsv
 * and glsl impl(also from Sam Hocevar): http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
 */

uniform sampler2D u_InputTexture;
varying highp vec2 v_TextureCoordinates;

uniform lowp float u_Exposure;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    vec4 textureColor = texture2D(u_InputTexture, v_TextureCoordinates);
    vec3 hsvColor = rgb2hsv(textureColor.rgb);
    vec3 adjustedHsvColor = vec3(hsvColor.xy, hsvColor.z * pow(2.0, u_Exposure));
    gl_FragColor = vec4(hsv2rgb(adjustedHsvColor), textureColor.a);
}