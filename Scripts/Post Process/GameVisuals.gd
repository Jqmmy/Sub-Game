@tool
extends CompositorEffect
class_name SobelFilter

@export_range(0.0, 3, 0.001) var edge_sharpness:float = 0.3
@export_range(0.0, 3, 0.001) var edge_dampness:float = 0.3

var rd:RenderingDevice
var shader:RID
var pipeline:RID

func _init() -> void:
	RenderingServer.call_on_render_thread(initialize_compute_shader)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and shader.is_valid():
		RenderingServer.free_rid(shader)

func _render_callback(effect_callback_type: int, render_data: RenderData) -> void:
	if not rd: return
	
	var scene_buffers:RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	if not scene_buffers: return
	
	var size :Vector2i = scene_buffers.get_internal_size()
	if size.x == 0 or size.y == 0: return
	
	var x_groups:int = size.x / 16 + 1
	var y_groups:int = size.y / 16 + 1
	var z_groups:int = 1
	
	var push_constants:PackedFloat32Array = PackedFloat32Array()
	push_constants.append(size.x)
	push_constants.append(size.y)
	push_constants.append(edge_sharpness)
	push_constants.append(edge_dampness)
	
	for view in scene_buffers.get_view_count():
		var screen_tex:RID = scene_buffers.get_color_layer(view)
		var out_tex:RID = scene_buffers.get_color_layer(view)
		
		var out_uniform:RDUniform = RDUniform.new()
		out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		out_uniform.binding = 0
		out_uniform.add_id(out_tex)
		
		var in_uniform:RDUniform = RDUniform.new()
		in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		in_uniform.binding = 0
		in_uniform.add_id(screen_tex)
		
		var image_uniform_set:RID = UniformSetCacheRD.get_cache(shader, 0, [in_uniform])
		var out_image_uniform_set:RID = UniformSetCacheRD.get_cache(shader, 1, [out_uniform])
		
		var compute_list:int = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, image_uniform_set, 0)
		rd.compute_list_bind_uniform_set(compute_list, out_image_uniform_set, 1)
		rd.compute_list_set_push_constant(compute_list, push_constants.to_byte_array(), push_constants.size() * 4)
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
		rd.compute_list_end()

func initialize_compute_shader() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd: return
	
	var glsl_file:RDShaderFile = load("res://Scripts/Post Process/GameVisuals.glsl")
	shader = rd.shader_create_from_spirv(glsl_file.get_spirv())
	pipeline = rd.compute_pipeline_create(shader)
	
