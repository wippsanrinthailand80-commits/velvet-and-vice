# Hentai Game Kit - Blender bpy builder
# Run: blender --background --python build_kit.py
# Produces glTF 2.0 .glb files under ../assets/models/

import bpy
import os
import math

BASE = "/root/hentai_game"
ASSETS = os.path.join(BASE, "assets", "models")

scene = bpy.context.scene
scene.unit_settings.system = 'METRIC'
scene.unit_settings.scale_length = 1.0

EXPORTS = []  # (filepath, [objects])

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for c in list(bpy.data.collections):
        bpy.data.collections.remove(c)

def make_material(name, base_color, roughness=0.5, metallic=0.0, specular=0.5):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    try:
        bsdf.inputs["Specular IOR Level"].default_value = specular
    except KeyError:
        pass
    return mat

def make_collection(name):
    col = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(col)
    return col

def add_part(name, primitive, location, scale, material, collection, rotation=(0,0,0)):
    primitive(location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.rotation_euler = rotation
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if material is not None:
        obj.data.materials.append(material)
    for c in list(obj.users_collection):
        c.objects.unlink(obj)
    collection.objects.link(obj)
    return obj

def join_parts(parts, name):
    if len(parts) == 1:
        obj = parts[0]
        obj.name = name
        mesh = obj.data
        min_z = min(v.co.z for v in mesh.vertices)
        for v in mesh.vertices:
            v.co.z -= min_z
        mesh.update()
        return obj
    bpy.ops.object.select_all(action='DESELECT')
    for p in parts:
        p.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = name
    mesh = obj.data
    min_z = min(v.co.z for v in mesh.vertices)
    for v in mesh.vertices:
        v.co.z -= min_z
    mesh.update()
    return obj

def join_parts_center(parts, name):
    if len(parts) == 1:
        obj = parts[0]
        obj.name = name
        mesh = obj.data
        xs = [v.co.x for v in mesh.vertices]; ys=[v.co.y for v in mesh.vertices]; zs=[v.co.z for v in mesh.vertices]
        cx = (min(xs)+max(xs))/2; cy=(min(ys)+max(ys))/2; cz=(min(zs)+max(zs))/2
        for v in mesh.vertices:
            v.co.x -= cx; v.co.y -= cy; v.co.z -= cz
        mesh.update()
        return obj
    bpy.ops.object.select_all(action='DESELECT')
    for p in parts:
        p.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = name
    mesh = obj.data
    xs = [v.co.x for v in mesh.vertices]; ys=[v.co.y for v in mesh.vertices]; zs=[v.co.z for v in mesh.vertices]
    cx = (min(xs)+max(xs))/2; cy=(min(ys)+max(ys))/2; cz=(min(zs)+max(zs))/2
    for v in mesh.vertices:
        v.co.x -= cx; v.co.y -= cy; v.co.z -= cz
    mesh.update()
    return obj

def create_armature(name, bone_defs, collection):
    arm_data = bpy.data.armatures.new(name)
    arm_obj = bpy.data.objects.new(name, arm_data)
    collection.objects.link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='EDIT')
    bones = {}
    for bname, parent, loc in bone_defs:
        b = arm_data.edit_bones.new(bname)
        b.head = loc
        b.tail = (loc[0], loc[1], loc[2] + 0.08) if bname != "root" else (0, 0, 0.1)
        if parent:
            b.parent = bones[parent]
        bones[bname] = b
    bpy.ops.object.mode_set(mode='OBJECT')
    return arm_obj

def register_export(filepath, objects):
    EXPORTS.append((filepath, list(objects)))

# ---------- Scene setup ----------
clear_scene()
col_chars = make_collection("Characters")
col_props = make_collection("Props")
col_furn  = make_collection("Furniture")
col_env   = make_collection("Environment")
col_mod   = make_collection("Modular")
col_rigs  = make_collection("Rigs")
col_decal = make_collection("Decals")

# ---------- Materials ----------
mat_body    = make_material("mat_body", (0.85, 0.68, 0.55), 0.45)
mat_body_m  = make_material("mat_body", (0.80, 0.62, 0.50), 0.45)
mat_hair    = make_material("mat_hair", (0.12, 0.08, 0.05), 0.6)
mat_hair_b  = make_material("mat_hair", (0.55, 0.40, 0.20), 0.6)
mat_eyes    = make_material("mat_eyes", (0.95, 0.95, 0.98), 0.1)
mat_genitals= make_material("mat_genitals", (0.78, 0.55, 0.48), 0.5)
mat_nails   = make_material("mat_nails", (0.9, 0.75, 0.7), 0.25)
mat_lips    = make_material("mat_lips", (0.75, 0.35, 0.35), 0.35)
mat_skin2   = make_material("mat_body", (0.70, 0.50, 0.40), 0.45)

mat_wood    = make_material("mat_wood", (0.45, 0.28, 0.12), 0.7)
mat_metal   = make_material("mat_metal", (0.62, 0.62, 0.68), 0.3, 0.9)
mat_mattress= make_material("mat_mattress", (0.85, 0.85, 0.88), 0.9)
mat_rubber  = make_material("mat_rubber", (0.15, 0.15, 0.15), 0.85)
mat_fabric  = make_material("mat_fabric", (0.75, 0.20, 0.25), 0.9)
mat_plastic = make_material("mat_plastic", (0.9, 0.9, 0.9), 0.4)
mat_glass   = make_material("mat_glass", (0.8, 0.9, 0.95), 0.05, 0.0, 0.9)
mat_concrete= make_material("mat_concrete", (0.6, 0.6, 0.58), 0.9)
mat_floor   = make_material("mat_floor", (0.55, 0.40, 0.25), 0.6)
mat_door    = make_material("mat_door", (0.40, 0.25, 0.10), 0.6)
mat_rug     = make_material("mat_rug", (0.6, 0.15, 0.15), 0.95)

BONE_DEFS = [
    ("root", None, (0, 0, 0)),
    ("spine", "root", (0, 0, 0.9)),
    ("chest", "spine", (0, 0, 1.5)),
    ("neck", "chest", (0, 0, 1.62)),
    ("head", "neck", (0, 0, 1.72)),
    ("leg_l", "root", (-0.1, 0, 0.45)),
    ("leg_r", "root", (0.1, 0, 0.45)),
    ("arm_l", "chest", (-0.2, 0, 1.35)),
    ("arm_r", "chest", (0.2, 0, 1.35)),
]

def build_character(name, body_mat, hair_mat, is_aroused=False, col=col_chars):
    parts = []
    parts.append(add_part("leg_l", bpy.ops.mesh.primitive_cylinder_add, (-0.1, 0, 0.45), (0.055, 0.055, 0.45), body_mat, col))
    parts.append(add_part("leg_r", bpy.ops.mesh.primitive_cylinder_add, ( 0.1, 0, 0.45), (0.055, 0.055, 0.45), body_mat, col))
    parts.append(add_part("pelvis", bpy.ops.mesh.primitive_uv_sphere_add, (0, 0, 0.92), (0.16, 0.13, 0.11), body_mat, col))
    g_scale = (0.035, 0.03, 0.03) if is_aroused else (0.025, 0.02, 0.02)
    g_loc = (0, 0.16, 0.86) if is_aroused else (0, 0.13, 0.86)
    parts.append(add_part("genitals", bpy.ops.mesh.primitive_uv_sphere_add, g_loc, g_scale, mat_genitals, col))
    parts.append(add_part("torso", bpy.ops.mesh.primitive_cylinder_add, (0, 0, 1.28), (0.15, 0.12, 0.28), body_mat, col))
    parts.append(add_part("chest_l", bpy.ops.mesh.primitive_uv_sphere_add, (-0.1, 0.06, 1.5), (0.1, 0.1, 0.09), body_mat, col))
    parts.append(add_part("chest_r", bpy.ops.mesh.primitive_uv_sphere_add, ( 0.1, 0.06, 1.5), (0.1, 0.1, 0.09), body_mat, col))
    parts.append(add_part("neck", bpy.ops.mesh.primitive_cylinder_add, (0, 0, 1.62), (0.04, 0.04, 0.06), body_mat, col))
    parts.append(add_part("head", bpy.ops.mesh.primitive_uv_sphere_add, (0, 0, 1.72), (0.09, 0.09, 0.1), body_mat, col))
    parts.append(add_part("hair", bpy.ops.mesh.primitive_uv_sphere_add, (0, -0.02, 1.78), (0.1, 0.1, 0.09), hair_mat, col))
    parts.append(add_part("eye_l", bpy.ops.mesh.primitive_uv_sphere_add, (-0.03, 0.08, 1.73), (0.012, 0.012, 0.012), mat_eyes, col))
    parts.append(add_part("eye_r", bpy.ops.mesh.primitive_uv_sphere_add, ( 0.03, 0.08, 1.73), (0.012, 0.012, 0.012), mat_eyes, col))
    parts.append(add_part("lips", bpy.ops.mesh.primitive_uv_sphere_add, (0, 0.09, 1.69), (0.025, 0.01, 0.008), mat_lips, col))
    parts.append(add_part("arm_l", bpy.ops.mesh.primitive_cylinder_add, (-0.2, 0, 1.35), (0.03, 0.03, 0.22), body_mat, col, rotation=(0, math.radians(10), 0)))
    parts.append(add_part("arm_r", bpy.ops.mesh.primitive_cylinder_add, ( 0.2, 0, 1.35), (0.03, 0.03, 0.22), body_mat, col, rotation=(0, math.radians(-10), 0)))
    parts.append(add_part("hand_l", bpy.ops.mesh.primitive_uv_sphere_add, (-0.22, 0.05, 1.12), (0.025, 0.025, 0.02), body_mat, col))
    parts.append(add_part("hand_r", bpy.ops.mesh.primitive_uv_sphere_add, ( 0.22, 0.05, 1.12), (0.025, 0.025, 0.02), body_mat, col))
    parts.append(add_part("nails_l", bpy.ops.mesh.primitive_cube_add, (-0.22, 0.07, 1.10), (0.012, 0.005, 0.008), mat_nails, col))
    parts.append(add_part("nails_r", bpy.ops.mesh.primitive_cube_add, ( 0.22, 0.07, 1.10), (0.012, 0.005, 0.008), mat_nails, col))
    char = join_parts(parts, name)
    # subsurf
    sub = char.modifiers.new("Subsurf", 'SUBSURF')
    sub.levels = 1
    sub.render_levels = 2
    # armature
    arm = create_armature("rig_" + name, BONE_DEFS, col_rigs)
    char.parent = arm
    char.matrix_parent_inverse = arm.matrix_world.inverted()
    return char, arm

# Characters
char_f_base, rig_f_base = build_character("char_female_nude_base", mat_body, mat_hair, False)
char_f_aroused, rig_f_aroused = build_character("char_female_nude_aroused", mat_body, mat_hair, True)

# Male character (simpler, no breasts; genitals)
parts = []
parts.append(add_part("leg_l", bpy.ops.mesh.primitive_cylinder_add, (-0.1, 0, 0.45), (0.06, 0.06, 0.45), mat_body_m, col_chars))
parts.append(add_part("leg_r", bpy.ops.mesh.primitive_cylinder_add, ( 0.1, 0, 0.45), (0.06, 0.06, 0.45), mat_body_m, col_chars))
parts.append(add_part("pelvis", bpy.ops.mesh.primitive_uv_sphere_add, (0, 0, 0.92), (0.17, 0.14, 0.12), mat_body_m, col_chars))
parts.append(add_part("genitals", bpy.ops.mesh.primitive_cylinder_add, (0, 0.17, 0.86), (0.025, 0.025, 0.06), mat_genitals, col_chars, rotation=(math.radians(90),0,0)))
parts.append(add_part("torso", bpy.ops.mesh.primitive_cylinder_add, (0, 0, 1.32), (0.17, 0.14, 0.32), mat_body_m, col_chars))
parts.append(add_part("chest", bpy.ops.mesh.primitive_cylinder_add, (0, 0, 1.62), (0.16, 0.14, 0.12), mat_body_m, col_chars))
parts.append(add_part("neck", bpy.ops.mesh.primitive_cylinder_add, (0, 0, 1.72), (0.045, 0.045, 0.06), mat_body_m, col_chars))
parts.append(add_part("head", bpy.ops.mesh.primitive_uv_sphere_add, (0, 0, 1.82), (0.1, 0.1, 0.105), mat_body_m, col_chars))
parts.append(add_part("hair", bpy.ops.mesh.primitive_uv_sphere_add, (0, -0.02, 1.88), (0.105, 0.105, 0.095), mat_hair_b, col_chars))
parts.append(add_part("eye_l", bpy.ops.mesh.primitive_uv_sphere_add, (-0.035, 0.09, 1.83), (0.012, 0.012, 0.012), mat_eyes, col_chars))
parts.append(add_part("eye_r", bpy.ops.mesh.primitive_uv_sphere_add, ( 0.035, 0.09, 1.83), (0.012, 0.012, 0.012), mat_eyes, col_chars))
parts.append(add_part("arm_l", bpy.ops.mesh.primitive_cylinder_add, (-0.22, 0, 1.4), (0.035, 0.035, 0.24), mat_body_m, col_chars, rotation=(0, math.radians(10), 0)))
parts.append(add_part("arm_r", bpy.ops.mesh.primitive_cylinder_add, ( 0.22, 0, 1.4), (0.035, 0.035, 0.24), mat_body_m, col_chars, rotation=(0, math.radians(-10), 0)))
parts.append(add_part("hand_l", bpy.ops.mesh.primitive_uv_sphere_add, (-0.25, 0.05, 1.15), (0.028, 0.028, 0.022), mat_body_m, col_chars))
parts.append(add_part("hand_r", bpy.ops.mesh.primitive_uv_sphere_add, ( 0.25, 0.05, 1.15), (0.028, 0.028, 0.022), mat_body_m, col_chars))
char_m_base = join_parts(parts, "char_male_nude_base")
sub = char_m_base.modifiers.new("Subsurf", 'SUBSURF'); sub.levels=1; sub.render_levels=2
rig_m_base = create_armature("rig_male_base", BONE_DEFS, col_rigs)
char_m_base.parent = rig_m_base
char_m_base.matrix_parent_inverse = rig_m_base.matrix_world.inverted()

# ---------- Props (sexual) ----------
# dildo
parts = []
parts.append(add_part("shaft", bpy.ops.mesh.primitive_cylinder_add, (0,0,0), (0.022,0.022,0.12), mat_rubber, col_props, rotation=(math.radians(90),0,0)))
parts.append(add_part("tip", bpy.ops.mesh.primitive_uv_sphere_add, (0,0,0.13), (0.022,0.022,0.022), mat_rubber, col_props))
parts.append(add_part("base", bpy.ops.mesh.primitive_cylinder_add, (0,0,-0.13), (0.03,0.03,0.02), mat_plastic, col_props))
prop_dildo = join_parts_center(parts, "prop_dildo_realistic_a")

# vibrator wand
parts = []
parts.append(add_part("handle", bpy.ops.mesh.primitive_cylinder_add, (0,0,0), (0.018,0.018,0.15), mat_plastic, col_props))
parts.append(add_part("head", bpy.ops.mesh.primitive_uv_sphere_add, (0,0,0.17), (0.025,0.025,0.02), mat_rubber, col_props))
prop_vibrator = join_parts_center(parts, "prop_vibrator_wand_a")

# handcuffs
parts = []
for x in (-0.06, 0.06):
    bpy.ops.mesh.primitive_torus_add(location=(x,0,0), major_radius=0.03, minor_radius=0.006)
    o = bpy.context.object
    o.name = "cuff"
    o.data.materials.append(mat_metal)
    for c in list(o.users_collection): c.objects.unlink(o)
    col_props.objects.link(o)
    parts.append(o)
parts.append(add_part("chain", bpy.ops.mesh.primitive_cylinder_add, (0,0,0), (0.004,0.004,0.06), mat_metal, col_props, rotation=(0,math.radians(90),0)))
prop_handcuffs = join_parts_center(parts, "prop_handcuffs_metal_a")

# blindfold
parts = []
parts.append(add_part("band", bpy.ops.mesh.primitive_cube_add, (0,0,0), (0.18,0.02,0.015), mat_fabric, col_props))
prop_blindfold = join_parts_center(parts, "prop_blindfold_cloth_a")

# rope coil
parts = []
bpy.ops.mesh.primitive_torus_add(location=(0,0,0), major_radius=0.08, minor_radius=0.012)
o = bpy.context.object; o.name="rope"; o.data.materials.append(mat_rubber)
for c in list(o.users_collection): c.objects.unlink(o)
col_props.objects.link(o)
parts.append(o)
prop_rope = o
prop_rope.name = "prop_rope_coil_a"

# lubricant bottle
parts = []
parts.append(add_part("body", bpy.ops.mesh.primitive_cylinder_add, (0,0,0), (0.025,0.025,0.1), mat_plastic, col_props))
parts.append(add_part("cap", bpy.ops.mesh.primitive_cylinder_add, (0,0,0.11), (0.018,0.018,0.015), mat_plastic, col_props))
parts.append(add_part("label", bpy.ops.mesh.primitive_cube_add, (0.026,0,0), (0.001,0.02,0.06), mat_fabric, col_props))
prop_lube = join_parts_center(parts, "prop_lubricant_bottle_a")

# condom box
parts = []
parts.append(add_part("box", bpy.ops.mesh.primitive_cube_add, (0,0,0), (0.06,0.04,0.025), mat_plastic, col_props))
prop_condom = join_parts_center(parts, "prop_condom_box_a")

# ---------- Furniture ----------
# nightstand
parts = []
parts.append(add_part("top", bpy.ops.mesh.primitive_cube_add, (0,0,0.5), (0.25,0.2,0.02), mat_wood, col_furn))
parts.append(add_part("leg_fl", bpy.ops.mesh.primitive_cube_add, (-0.2,0.15,0.25), (0.02,0.02,0.25), mat_wood, col_furn))
parts.append(add_part("leg_fr", bpy.ops.mesh.primitive_cube_add, (0.2,0.15,0.25), (0.02,0.02,0.25), mat_wood, col_furn))
parts.append(add_part("leg_bl", bpy.ops.mesh.primitive_cube_add, (-0.2,-0.15,0.25), (0.02,0.02,0.25), mat_wood, col_furn))
parts.append(add_part("leg_br", bpy.ops.mesh.primitive_cube_add, (0.2,-0.15,0.25), (0.02,0.02,0.25), mat_wood, col_furn))
furn_nightstand = join_parts(parts, "furn_nightstand_wood_01")

# table lamp
parts = []
parts.append(add_part("base", bpy.ops.mesh.primitive_cylinder_add, (0,0,0.02), (0.08,0.08,0.02), mat_metal, col_furn))
parts.append(add_part("stem", bpy.ops.mesh.primitive_cylinder_add, (0,0,0.25), (0.01,0.01,0.23), mat_metal, col_furn))
parts.append(add_part("shade", bpy.ops.mesh.primitive_cone_add, (0,0,0.55), (0.12,0.12,0.18), mat_fabric, col_furn))
furn_lamp = join_parts(parts, "furn_lamp_table_01")

# chair
parts = []
parts.append(add_part("seat", bpy.ops.mesh.primitive_cube_add, (0,0,0.45), (0.22,0.22,0.03), mat_wood, col_furn))
parts.append(add_part("back", bpy.ops.mesh.primitive_cube_add, (0,-0.2,0.7), (0.22,0.02,0.25), mat_wood, col_furn))
for x in (-0.18,0.18):
    for y in (-0.18,0.18):
        parts.append(add_part("leg", bpy.ops.mesh.primitive_cylinder_add, (x,y,0.22), (0.02,0.02,0.22), mat_wood, col_furn))
furn_chair = join_parts(parts, "furn_chair_wood_01")

# bed (from prop example)
parts = []
for x in (-0.9, 0.9):
    for y in (-1.0, 1.0):
        parts.append(add_part("post", bpy.ops.mesh.primitive_cylinder_add, (x, y, 0.2), (0.025, 0.025, 0.2), mat_metal, col_furn))
for y in (-1.0, 1.0):
    parts.append(add_part("rail", bpy.ops.mesh.primitive_cube_add, (0, y, 0.38), (0.9, 0.025, 0.02), mat_metal, col_furn))
parts.append(add_part("mattress", bpy.ops.mesh.primitive_cube_add, (0, 0, 0.5), (0.85, 0.95, 0.09), mat_mattress, col_furn))
parts.append(add_part("headboard", bpy.ops.mesh.primitive_cube_add, (0, -1.05, 0.7), (0.9, 0.025, 0.3), mat_metal, col_furn))
furn_bed = join_parts(parts, "furn_bed_metal_01")

# ---------- Environment ----------
# wall module (2m wide, 2.5m high)
parts = []
parts.append(add_part("panel", bpy.ops.mesh.primitive_cube_add, (0,0,1.25), (1.0,0.05,1.25), mat_concrete, col_env))
env_wall = join_parts(parts, "env_wall_concrete_modular_a")

# floor tile (2x2)
parts = []
parts.append(add_part("tile", bpy.ops.mesh.primitive_cube_add, (0,0,0.01), (1.0,1.0,0.01), mat_floor, col_env))
env_floor = join_parts(parts, "env_floor_wood_modular_a")

# door
parts = []
parts.append(add_part("door", bpy.ops.mesh.primitive_cube_add, (0,0,1.05), (0.45,0.04,1.05), mat_door, col_env))
parts.append(add_part("frame_t", bpy.ops.mesh.primitive_cube_add, (0,0,2.15), (0.5,0.06,0.05), mat_wood, col_env))
parts.append(add_part("frame_l", bpy.ops.mesh.primitive_cube_add, (-0.48,0,1.05), (0.02,0.06,1.05), mat_wood, col_env))
parts.append(add_part("frame_r", bpy.ops.mesh.primitive_cube_add, (0.48,0,1.05), (0.02,0.06,1.05), mat_wood, col_env))
env_door = join_parts(parts, "env_door_wood_01")

# window
parts = []
parts.append(add_part("frame", bpy.ops.mesh.primitive_cube_add, (0,0,1.2), (0.6,0.04,0.7), mat_wood, col_env))
parts.append(add_part("glass", bpy.ops.mesh.primitive_cube_add, (0,0.02,1.2), (0.5,0.01,0.65), mat_glass, col_env))
env_window = join_parts(parts, "env_window_01")

# ---------- Decal ----------
parts = []
parts.append(add_part("rug", bpy.ops.mesh.primitive_plane_add, (0,0,0.001), (1.0,0.75,1.0), mat_rug, col_decal))
decal_rug = [o for o in col_decal.objects][-1]
decal_rug.name = "decal_rug_01"

# ---------- Animations ----------
def add_idle_animation(arm_obj, name="idle"):
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='POSE')
    action = bpy.data.actions.new(name=name)
    arm_obj.animation_data_create()
    arm_obj.animation_data.action = action
    bones = arm_obj.pose.bones
    # 24 frames idle loop
    frames = [1, 12, 24]
    # spine sway
    for f in frames:
        bpy.context.scene.frame_set(f)
        if "spine" in bones:
            bones["spine"].rotation_euler = (0, 0, 0.02 * (1 if f == 12 else 0))
            bones["spine"].keyframe_insert(data_path="rotation_euler", index=-1)
        if "chest" in bones:
            bones["chest"].rotation_euler = (0, 0, -0.02 * (1 if f == 12 else 0))
            bones["chest"].keyframe_insert(data_path="rotation_euler", index=-1)
        if "head" in bones:
            bones["head"].rotation_euler = (0, 0, 0.01 * (1 if f == 12 else 0))
            bones["head"].keyframe_insert(data_path="rotation_euler", index=-1)
    # keyframe at frame 1 for all bones rest
    bpy.context.scene.frame_set(1)
    for bname in ["root","spine","chest","neck","head","leg_l","leg_r","arm_l","arm_r"]:
        if bname in bones:
            bones[bname].keyframe_insert(data_path="rotation_euler", index=-1)
            bones[bname].keyframe_insert(data_path="location", index=-1)
    bpy.context.scene.frame_set(24)
    for bname in ["root","spine","chest","neck","head","leg_l","leg_r","arm_l","arm_r"]:
        if bname in bones:
            bones[bname].keyframe_insert(data_path="rotation_euler", index=-1)
            bones[bname].keyframe_insert(data_path="location", index=-1)
    bpy.ops.object.mode_set(mode='OBJECT')
    action.use_fake_user = True
    return action

def add_walk_animation(arm_obj, name="walk"):
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode='POSE')
    action = bpy.data.actions.new(name=name)
    arm_obj.animation_data.action = action
    bones = arm_obj.pose.bones
    # 24 frames walk cycle
    for f in range(1, 25):
        bpy.context.scene.frame_set(f)
        t = (f - 1) / 24.0 * 2 * math.pi
        if "leg_l" in bones:
            bones["leg_l"].rotation_euler = (math.sin(t) * 0.4, 0, 0)
            bones["leg_l"].keyframe_insert(data_path="rotation_euler", index=-1)
        if "leg_r" in bones:
            bones["leg_r"].rotation_euler = (math.sin(t + math.pi) * 0.4, 0, 0)
            bones["leg_r"].keyframe_insert(data_path="rotation_euler", index=-1)
        if "arm_l" in bones:
            bones["arm_l"].rotation_euler = (math.sin(t + math.pi) * 0.3, 0, 0)
            bones["arm_l"].keyframe_insert(data_path="rotation_euler", index=-1)
        if "arm_r" in bones:
            bones["arm_r"].rotation_euler = (math.sin(t) * 0.3, 0, 0)
            bones["arm_r"].keyframe_insert(data_path="rotation_euler", index=-1)
        if "spine" in bones:
            bones["spine"].location = (0, 0, 0.02 * abs(math.sin(t * 2)))
            bones["spine"].keyframe_insert(data_path="location", index=-1)
    bpy.ops.object.mode_set(mode='OBJECT')
    action.use_fake_user = True
    return action

# Apply idle to female rig
add_idle_animation(rig_f_base, "idle")
# Apply walk to female rig
add_walk_animation(rig_f_base, "walk")
# Apply idle to male rig
add_idle_animation(rig_m_base, "idle")
add_walk_animation(rig_m_base, "walk")

# ---------- Export ----------
os.makedirs(os.path.join(ASSETS, "characters"), exist_ok=True)
os.makedirs(os.path.join(ASSETS, "props"), exist_ok=True)
os.makedirs(os.path.join(ASSETS, "furniture"), exist_ok=True)
os.makedirs(os.path.join(ASSETS, "environment"), exist_ok=True)
os.makedirs(os.path.join(ASSETS, "decals"), exist_ok=True)

def export_one(filepath, objects):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.export_scene.gltf(
        filepath=filepath,
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials='EXPORT',
        export_animations=True,
    )
    print("Exported:", filepath)

# characters (mesh + armature)
export_one(os.path.join(ASSETS, "characters", "char_female_nude_base.glb"), [char_f_base, rig_f_base])
export_one(os.path.join(ASSETS, "characters", "char_female_nude_aroused.glb"), [char_f_aroused, rig_f_aroused])
export_one(os.path.join(ASSETS, "characters", "char_male_nude_base.glb"), [char_m_base, rig_m_base])

# props
for o, fn in [(prop_dildo,"prop_dildo_realistic_a.glb"),(prop_vibrator,"prop_vibrator_wand_a.glb"),(prop_handcuffs,"prop_handcuffs_metal_a.glb"),(prop_blindfold,"prop_blindfold_cloth_a.glb"),(prop_rope,"prop_rope_coil_a.glb"),(prop_lube,"prop_lubricant_bottle_a.glb"),(prop_condom,"prop_condom_box_a.glb")]:
    export_one(os.path.join(ASSETS, "props", fn), [o])

# furniture
for o, fn in [(furn_nightstand,"furn_nightstand_wood_01.glb"),(furn_lamp,"furn_lamp_table_01.glb"),(furn_chair,"furn_chair_wood_01.glb"),(furn_bed,"furn_bed_metal_01.glb")]:
    export_one(os.path.join(ASSETS, "furniture", fn), [o])

# environment
for o, fn in [(env_wall,"env_wall_concrete_modular_a.glb"),(env_floor,"env_floor_wood_modular_a.glb"),(env_door,"env_door_wood_01.glb"),(env_window,"env_window_01.glb")]:
    export_one(os.path.join(ASSETS, "environment", fn), [o])

# decal
export_one(os.path.join(ASSETS, "decals", "decal_rug_01.glb"), [decal_rug])

print("=== KIT BUILD COMPLETE ===")
print("Characters: char_female_nude_base, char_female_nude_aroused, char_male_nude_base")
print("Props: prop_dildo_realistic_a, prop_vibrator_wand_a, prop_handcuffs_metal_a, prop_blindfold_cloth_a, prop_rope_coil_a, prop_lubricant_bottle_a, prop_condom_box_a")
print("Furniture: furn_nightstand_wood_01, furn_lamp_table_01, furn_chair_wood_01, furn_bed_metal_01")
print("Environment: env_wall_concrete_modular_a, env_floor_wood_modular_a, env_door_wood_01, env_window_01")
print("Decal: decal_rug_01")
print("Exported glb files under", ASSETS)
