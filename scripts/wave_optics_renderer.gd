# Wave Optics Renderer - uses Godot's RenderingDevice to run Raxter's wave optics compute shader
extends Node

@export var resolution: Vector2i = Vector2i(512, 512)
@export var wavelength_nm: float = 550.0
@export var slit_separation: float = 1e-4
@export var screen_distance: float = 1.0
@export var num_slits: int = 2

var rd: RenderingDevice = null
var shader: RID = RID()
var pipeline: RID = RID()
var params_buffer: RID = RID()
var output_texture: RID = RID()
var output_image: ImageTexture = null
var compute_list: int = -1

var time: float = 0.0

func _ready():
    rd = RenderingServer.get_rendering_device()
    if rd == null:
        push_error("RenderingDevice not available")
        return
    _setup_compute()

func _setup_compute():
    # Load shader
    var shader_file = load("res://shaders/wave_optics.glsl")
    if shader_file == null:
        push_error("Failed to load wave_optics.glsl")
        return
    var shader_spirv = shader_file.get_spirv()
    shader = rd.shader_create_from_spirv(shader_spirv)
    if not shader.is_valid():
        push_error("Failed to create shader")
        return
    
    # Create pipeline
    pipeline = rd.compute_pipeline_create(shader)
    if not pipeline.is_valid():
        push_error("Failed to create pipeline")
        return
    
    # Create params uniform buffer
    var params_data = PackedByteArray()
    params_data.resize(32)  # enough for our params struct
    # resolution (ivec2 = 8 bytes)
    params_data.encode_s32(0, resolution.x)
    params_data.encode_s32(4, resolution.y)
    # wavelength_nm (float)
    params_data.encode_float(8, wavelength_nm)
    # slit_separation (float)
    params_data.encode_float(12, slit_separation)
    # screen_distance (float)
    params_data.encode_float(16, screen_distance)
    # num_slits (uint)
    params_data.encode_u32(20, num_slits)
    # time (float)
    params_data.encode_float(24, time)
    
    params_buffer = rd.uniform_buffer_create(params_data.size(), params_data)
    
    # Create output texture
    var tex_format = RDTextureFormat.new()
    tex_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
    tex_format.width = resolution.x
    tex_format.height = resolution.y
    tex_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
    
    var tex_view = RDTextureView.new()
    output_texture = rd.texture_create(tex_format, tex_view)
    
    # Create output image (Godot 4.7 uses image2D binding)
    # The shader binds output_image at set 0, binding 1
    
    print("WaveOpticsRenderer ready")

func _process(delta):
    if rd == null or not pipeline.is_valid():
        return
    time += delta
    
    # Update params
    var params_data = PackedByteArray()
    params_data.resize(32)
    params_data.encode_s32(0, resolution.x)
    params_data.encode_s32(4, resolution.y)
    params_data.encode_float(8, wavelength_nm)
    params_data.encode_float(12, slit_separation)
    params_data.encode_float(16, screen_distance)
    params_data.encode_u32(20, num_slits)
    params_data.encode_float(24, time)
    
    rd.buffer_update(params_buffer, 0, params_data.size(), params_data)
    
    # Create uniform set
    var uniform_params = RDUniform.new()
    uniform_params.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
    uniform_params.binding = 0
    uniform_params.add_id(params_buffer)
    
    var uniform_image = RDUniform.new()
    uniform_image.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
    uniform_image.binding = 1
    uniform_image.add_id(output_texture)
    
    var uniform_set = rd.uniform_set_create([uniform_params, uniform_image], shader, 0)
    
    # Dispatch
    compute_list = rd.compute_list_begin()
    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
    rd.compute_list_dispatch(compute_list, resolution.x / 16, resolution.y / 16, 1)
    rd.compute_list_end()
    
    # Read back to texture
    _update_display_texture()

func _update_display_texture():
    if output_image == null:
        output_image = ImageTexture.new()
    var image = rd.texture_get_data(output_texture, 0)
    if image:
        var img = Image.create_from_data(resolution.x, resolution.y, false, Image.FORMAT_RGBA8, image)
        output_image.set_image(img)

func get_texture() -> ImageTexture:
    return output_image

func _exit_tree():
    if rd:
        if params_buffer.is_valid():
            rd.free_rid(params_buffer)
        if output_texture.is_valid():
            rd.free_rid(output_texture)
        if pipeline.is_valid():
            rd.free_rid(pipeline)
        if shader.is_valid():
            rd.free_rid(shader)