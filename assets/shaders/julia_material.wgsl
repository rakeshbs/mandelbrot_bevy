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

fn compute_color(z0: vec2<f32>, c: vec2<f32>, iterations: u32, threshold: f32) -> vec2<f32> {
    var z = z0;
    var color = vec2<f32>(0.0, 0.0);

    // Iterate z = z^2 + c until it diverges or we reach max iterations
    for (var i = 0u; i < iterations; i = i + 1u) {
        z = vec2<f32>(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        let lsquared = z.x * z.x + z.y * z.y;
        if lsquared > threshold {
            // The pixel is outside the Julia set, so color it based on the number of iterations
            var t = f32(i) / f32(iterations);
            color.x = color.x + t;
            color.y = color.y + t;
            break;
        }
    }
    // The pixel is inside the Julia set, so color it black
    return color;
}

@fragment
fn fragment(
    #import bevy_pbr::mesh_vertex_output
) -> @location(0) vec4<f32> {
    var c = material.c;
    var iterations = 300u; // Number of iterations for the fractal
    var threshold = 4.0; // Threshold for determining divergence
    var samples = 2; // Number of samples to average over
    var sum = vec2<f32>(0.0, 0.0); // Accumulator for samples
    var count = 0; // Number of samples accumulated

    let uvx = (uv.x - 0.5) / zoom;
    let uvy = (uv.y - 0.5) / zoom;
    // Iterate over nearby z coordinates and accumulate samples
    for (var i = -samples / 2; i < samples / 2; i = i + 1) {
        for (var j = -samples / 2; j < samples / 2; j = j + 1) {
            var z = vec2<f32>(uvx + f32(i) / 10000.0, uvy + f32(j) / 10000.0); // Adjust z coordinates
            sum = sum + compute_color(z, c, iterations, threshold); // Compute color for each sample and accumulate
            count = count + 1;
        }
    }

    // Compute the average color and return as the output color
    var avg = sum / f32(count);
    return vec4(avg.x, avg.y, avg.x + avg.y, 1.0);
}

