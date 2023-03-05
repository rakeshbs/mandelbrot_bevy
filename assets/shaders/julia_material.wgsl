struct CustomMaterial {
    c: vec2<f32>,
};

@group(1) @binding(0)
var<uniform> material: CustomMaterial;
@group(1) @binding(1)
var<uniform> zoom: f32;


@fragment
fn fragment(
    #import bevy_pbr::mesh_vertex_output
) -> @location(0) vec4<f32> {

    var z = vec2<f32>((uv.x - 0.5f) / zoom, (uv.y - 0.5f) / zoom);
    var c = material.c;
    var iterations = 500u; // Number of iterations for the fractal
    var threshold = 2.0; // Threshold for determining divergence

    for (var i = 0u; i < iterations; i = i + 1u) {
        z = vec2<f32>(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        if (length(z) > threshold) {
            // The pixel is outside the Julia set, so color it based on the number of iterations
            var t = (f32(i) / f32(iterations));
            return vec4<f32>(t, t, t, 1.0);
        }
    }

    // The pixel is inside the Julia set, so color it black
    return vec4<f32>(0.0, 0.0, 0.0, 1.0);
}
