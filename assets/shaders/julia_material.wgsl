struct CustomMaterial {
    c: vec2<f32>,
};

@group(1) @binding(0)
var<uniform> material: CustomMaterial;
@group(1) @binding(1)
var<uniform> zoom: f32;


fn hsv_to_rgb(c: vec3<f32>) -> vec3<f32> {
    let K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    let p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, vec3(0.0), vec3(1.0)), c.y);
}

@fragment
fn fragment(
    #import bevy_pbr::mesh_vertex_output
) -> @location(0) vec4<f32> {
    var sat = 1.0;
    var val = 1.0;

    var z = vec2<f32>((uv.x - 0.5f) / zoom, (uv.y - 0.5f) / zoom);
    var c = material.c;
    var iterations = 500u; // Number of iterations for the fractal
    var threshold = 2.0; // Threshold for determining divergence

    for (var i = 0u; i < iterations; i = i + 1u) {
        z = vec2<f32>(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (length(z) > threshold) {
            // The pixel is outside the Julia set, so color it based on the number of iterations
            var h = ((f32(i) + 1.0) / f32(iterations));
            let rgb = hsv_to_rgb(vec3(h, sat, val));
            return vec4<f32>(rgb, 1.0);
        }
    }

    // The pixel is inside the Julia set, so color it black
    let rgb = hsv_to_rgb(vec3(1.0, sat, val));
    return vec4<f32>(rgb, 1.0);
}
