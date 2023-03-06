//! A shader and a material that uses it.

use bevy::{
    core_pipeline::bloom::BloomSettings,
    prelude::*,
    reflect::TypeUuid,
    render::render_resource::{AsBindGroup, ShaderRef},
};

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugin(MaterialPlugin::<CustomMaterial>::default())
        .add_startup_system(setup)
        .add_system(update_material)
        .run();
}

/// set up a simple 3D scene
fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<CustomMaterial>>,
    asset_server: Res<AssetServer>,
) {
    // cube
    commands.spawn(MaterialMeshBundle {
        mesh: meshes.add(Mesh::from(shape::Plane { size: 1.0 })),
        transform: Transform::from_xyz(0.0, 0.0, 0.0),
        material: materials.add(CustomMaterial {
            c: Vec2::new(-0.8, 0.156),
            zoom: 0.3,
            alpha_mode: AlphaMode::Blend,
        }),
        ..default()
    });
    // camera
    commands.spawn((
        Camera3dBundle {
            transform: Transform::from_xyz(0.0, 1.0, 0.0001).looking_at(Vec3::ZERO, Vec3::Y),
            ..default()
        },
        BloomSettings {
            intensity: 0.9,
            ..default()
        },
    ));
}

// change material properties of the mesh on key press.
fn update_material(
    keyboard_input: Res<Input<KeyCode>>,
    mut materials: ResMut<Assets<CustomMaterial>>,
    mut query: Query<(&Handle<CustomMaterial>, &mut Transform)>,
) {
    for (material_handle, mut transform) in query.iter_mut() {
        let mut material = materials.get_mut(material_handle).unwrap();
        let z = material.zoom;
        let inc = (1. / (z * 10000.0)) * 5.;
        if keyboard_input.pressed(KeyCode::A) {
            material.c.x += inc;
        }
        if keyboard_input.pressed(KeyCode::S) {
            material.c.x -= inc;
        }
        if keyboard_input.pressed(KeyCode::Q) {
            material.c.y += inc;
        }
        if keyboard_input.pressed(KeyCode::W) {
            material.c.y -= inc;
        }
        if keyboard_input.pressed(KeyCode::Z) {
            material.zoom += inc * 100.;
        }
        if keyboard_input.pressed(KeyCode::X) {
            material.zoom -= inc * 100.;
        }
    }
}

/// You only need to implement functions for features that need non-default behavior. See the Material api docs for details!
impl Material for CustomMaterial {
    fn fragment_shader() -> ShaderRef {
        "shaders/julia_material.wgsl".into()
    }

    fn alpha_mode(&self) -> AlphaMode {
        self.alpha_mode
    }
}

// This is the struct that will be passed to your shader
#[derive(AsBindGroup, TypeUuid, Debug, Clone)]
#[uuid = "f690fdae-d598-45ab-8225-97e2a3f056e0"]
pub struct CustomMaterial {
    #[uniform(0)]
    c: Vec2,
    #[uniform(1)]
    zoom: f32,
    alpha_mode: AlphaMode,
}
