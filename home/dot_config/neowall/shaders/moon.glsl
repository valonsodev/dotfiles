// By Nikos Papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// https://www.shadertoy.com/view/4tlXzr

#define EPS          0.001
#define PI           3.14159265359
#define RADIAN       (180.0 / PI)
#define SPEED        25.0
#define ENABLE_STARS 1
#define TWOPI        6.2831853

float hash(vec2 p)
{
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

mat2 rot2(float a) 
{
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

vec2 octaMap(vec3 n) 
{
    n /= (abs(n.x) + abs(n.y) + abs(n.z) + 1e-6);
    vec2 p = n.xz;
    return (n.y < 0.0) ? (1.0 - abs(p.yx)) * sign(p) : p;
}

float starLayer(vec2 p, float density, float sparsity, float rMin, float rMax, float intensity, float seed)
{
    vec2 gv = p * density;
    vec2 cell = floor(gv);
    vec2 f = fract(gv) - 0.5;

    float id = hash(cell + seed);
    float on = smoothstep(sparsity, 1.0, id);

    vec2 jitter = vec2(
        hash(cell + vec2(13.37, 7.17) + seed),
        hash(cell + vec2(91.13, 53.31) - seed)
    ) - 0.5;

    float r = mix(rMin, rMax, hash(cell + vec2(101.7, 19.3) + seed));

    vec2 d = f - jitter * 0.35;
    vec2 jx = dFdx(gv);
    vec2 jy = dFdy(gv);
    float det = jx.x * jy.y - jx.y * jy.x;

    float safeDet = (abs(det) < 1e-6) ? (sign(det) * 1e-6 + 1e-6) : det;
    vec2 dPx = mat2(jy.y, -jx.y, -jy.x, jx.x) * d / safeDet;
    float distPx = length(dPx);

    float gvPerPixel = max(1e-4, sqrt(0.5 * (dot(jx, jx) + dot(jy, jy))));
    float radiusPx = max(r / gvPerPixel, 0.60);

    float aa = fwidth(distPx) + 1e-6;
    float star = 1.0 - smoothstep(radiusPx, radiusPx + aa, distPx);

    float twSpeed = mix(0.8, 2.8, hash(cell + vec2(7.7, 3.3) + seed));
    float tw = 0.86 + 0.14 * sin(iTime * twSpeed + id * TWOPI);

    return star * on * tw * intensity;
}

float stars(vec3 rayOrigin, vec3 rayDir)
{
    vec2 p = octaMap(rayDir);
    p += rayOrigin.xz * 0.0008;
    p += vec2(0.00015 * iTime, -0.00008 * iTime);

    float s = 0.0;
    s += starLayer(rot2(0.35) * p + vec2(0.11, -0.07), 260.0, 0.9964, 0.012, 0.040, 0.80, 1.0);
    s += starLayer(rot2(1.10) * p + vec2(-0.23, 0.19), 450.0, 0.9979, 0.010, 0.030, 0.60, 2.0);
    s += starLayer(rot2(2.25) * p + vec2(0.31, 0.27), 150.0, 0.9915, 0.018, 0.060, 0.35, 3.0);

    return s * 1.15;
}

float noise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p); 
    f *= f * (3.0 - 2.0 * f);
    
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x),
               mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p)
{
    return 0.5000 * noise(p)
         + 0.2500 * noise(p * 2.0)
         + 0.1250 * noise(p * 4.0)
         + 0.0625 * noise(p * 8.0);
}

float dst(vec3 p)
{
    vec2 xz = p.xz;
    return p.y
         + 0.45 * fbm(p.zx)
         + 2.55 * noise(0.1 * xz)
         + 0.83 * noise(0.4 * xz)
         + 3.33 * noise(0.001 * xz)
         + 3.59 * noise(0.0005 * (xz + 132.453));
}

vec3 nrm(vec3 p, float d)
{
    return normalize(
        vec3(dst(vec3(p.x + EPS, p.y, p.z)),
             dst(vec3(p.x, p.y + EPS, p.z)),
             dst(vec3(p.x, p.y, p.z + EPS))) - d);
}

bool rmarch(vec3 rayOrigin, vec3 rayDir, out vec3 surfacePos, out vec3 surfaceNormal)
{
    vec3 pos = rayOrigin;
    float d;

    for (int i = 0; i < 64; i++) {
        d = dst(pos);
        if (d < EPS) break;
        pos += d * rayDir;
    }
    
    surfacePos = pos;
    surfaceNormal = nrm(pos, d);
    return d < EPS;
}

vec4 render(vec2 uv)
{
    float t = iTime;
    vec2 uvn = uv * vec2(iResolution.x / iResolution.y, 1.0);
    float vel = SPEED * t;
    
    vec3 cameraUp = vec3(2.0 * noise(vec2(0.3 * t)) - 1.0, 1.0, fbm(vec2(0.8 * t)));
    vec3 cameraPos = vec3(0.0, 3.1, vel);
    vec3 cameraTarget = vec3(1.5 * sin(t), -2.0 + cos(t), 13.0 + vel);
        
    vec3 rayDir = normalize(vec3(uvn, 1.0 / tan(60.0 * RADIAN)));
    
    vec3 forward = normalize(cameraTarget - cameraPos);
    vec3 right = normalize(cross(forward, cameraUp));
    vec3 up = normalize(cross(right, forward));

    rayDir = normalize(mat3(right, up, forward) * rayDir);
    
    vec3 surfacePos, surfaceNormal;
    bool hit = rmarch(cameraPos, rayDir, surfacePos, surfaceNormal);

    vec3 col = vec3(0.01, 0.01, 0.02);

    if (hit) {
        float diff = max(0.0, dot(surfaceNormal, normalize(vec3(cameraPos.x, cameraPos.y + 0.5, cameraPos.z) - surfacePos)));
        col = vec3(0.6 * diff);
    } else {
        #if ENABLE_STARS
        col += stars(cameraPos, rayDir);
        #endif
    }
    
    return vec4(col, length(cameraPos - surfacePos));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
    vec3 col = render(uv).xyz;
    col *= 1.75 * smoothstep(length(uv) * 0.22, 0.75, 0.4);
    fragColor = vec4(col, 1.0);
}