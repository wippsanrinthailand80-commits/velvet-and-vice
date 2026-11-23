# Material Enhancer - improves materials at runtime with better colors and properties
extends Node

func _ready():
    # Enhance all materials in the scene
    call_deferred("_enhance_scene")

func _enhance_scene():
    var root = get_tree().current_scene
    if root == null:
        return
    _enhance_node(root)

func _enhance_node(node: Node):
    if node is MeshInstance3D:
        for i in range(node.get_surface_override_material_count()):
            var mat = node.get_surface_override_material(i)
            if mat == null:
                mat = node.mesh.surface_get_material(i) if node.mesh else null
            if mat is StandardMaterial3D:
                # Improve material properties
                mat.roughness = clamp(mat.roughness, 0.3, 0.9)
                if mat.albedo_color == Color.WHITE:
                    mat.albedo_color = Color(0.8, 0.7, 0.6)
    for child in node.get_children():
        _enhance_node(child)