gui_render_frame :: (command_buffer: Command_Buffer, dst: *Texture) {
	using frame := *frames[frame_counter % Frame_Data.IN_FLIGHT];
	defer frame_counter += 1;

	{
		render_pass := Render_Pass_Descriptor.{
			color_targets = .[{*backbuffer, .CLEAR, .STORE, .[0,0,0,0]}]
		};
		
		gpu_scoped_render_pass(command_buffer, render_pass);
		gpu_bind_pipeline(*command_buffer, *pipeline);
		
		gpu_draw_indexed(command_buffer, gpu_host_to_device_address(data), gpu_host_to_device_address(data), indices, 6, instance_counter);
	}
	
	gpu_barrier(command_buffer, .FRAGMENT_SHADER, .FRAGMENT_SHADER, .DESCRIPTORS);

	#if true {
		render_pass := Render_Pass_Descriptor.{
			color_targets = .[{dst, .LOAD, .STORE, .[0,0,0,0]}]
		};
		
		gpu_scoped_render_pass(command_buffer, render_pass);
		gpu_bind_pipeline(*command_buffer, *overlay_pipeline);
		gpu_bind_texture_heap(command_buffer, texture_heap);
		
		gpu_draw_indexed(command_buffer, null, null, indices, 3);
	}
	
	instance_counter = 0;
}

gui_resize :: (width: s32, height: s32){
	//TODO Only resize up, no reason to size down.
	gpu_destroy_texture(*backbuffer);
	backbuffer = gpu_create_texture({xx width, xx height, .R8G8B8A8_UNORM, .STORAGE | .COLOR_ATTACHMENT | .TRANSFER_SRC | .TRANSFER_DST | .SAMPLED});
	gpu_create_texture_view_descriptor(texture_heap, 0, backbuffer);

	for * frames {
		using it;
		data.view = orthographic_projection_matrix(0.0, cast(f32, width), 0.0, cast(f32, height), 100000000, 0.1,  true);
	}
}

draw_rect :: (left: s32, top: s32, right: s32, bottom: s32){
	using frame := *frames[frame_counter % Frame_Data.IN_FLIGHT];
	instances[instance_counter] = .{{xx left, xx top, xx right, xx bottom}};
	instance_counter += 1;
}

#scope_module;

gui_rendering_init :: (window: Window_Type) {
	width, height := get_window_size(window);
	
	blend_state: Blending_State;
	rasterizer_descriptor: Rasterizer_Descriptor = .{
		blend_state = *blend_state,
		color_targets = .[
			.{format = .R8G8B8A8_UNORM}
		]
	};
	
	{
		vertex_ir := gpu_create_shader(shader, "v_main");
		fragment_ir := gpu_create_shader(shader, "f_main");
		pipeline = gpu_create_graphic_pipeline(vertex_ir, fragment_ir, rasterizer_descriptor);
	}
	
	{
		vertex_ir := gpu_create_shader(overlay_shader, "v_main");
		fragment_ir := gpu_create_shader(overlay_shader, "f_main");
		overlay_pipeline = gpu_create_graphic_pipeline(vertex_ir, fragment_ir, rasterizer_descriptor);
	}
	
	texture_heap = gpu_create_texture_heap();
	backbuffer = gpu_create_texture({xx width, xx height, .R8G8B8A8_UNORM, .STORAGE | .COLOR_ATTACHMENT | .TRANSFER_SRC | .TRANSFER_DST | .SAMPLED});
	gpu_create_texture_view_descriptor(texture_heap, 0, backbuffer);
	frame_semaphore = gpu_create_semaphore();

	for * frames {
		using it;
		
		data =  gpu_malloc(1, Rendering_Data);
		instances.count = 1024;
		instances.data = gpu_malloc(instances.count, Instance_Data);
		data.instances = gpu_host_to_device_address(instances.data);
		data.view = orthographic_projection_matrix(0.0, cast(f32, width), 0.0, cast(f32, height), 100000000, 0.1,  true);
	}
	
	indices = gpu_malloc(u32.[0, 1, 2, 2, 3, 1]);
}

Gui_Rendering_Context :: struct {
	pipeline: Pipeline;
	overlay_pipeline: Pipeline;
	backbuffer: Texture;
	
	frame_semaphore: Semaphore;
	frame_counter: u64;
	frames: [Frame_Data.IN_FLIGHT] Frame_Data;

	texture_heap: *Texture_Descriptor;
	
	instances: [..] Instance_Data;

	indices: *u32;
}

Instance_Data :: struct {
	position: Vector4;
}

Rendering_Data :: struct{
	instances: *Instance_Data;
	view: Matrix4;
}

Frame_Data :: struct {
	IN_FLIGHT :: 2;

	instance_counter: s64;
	instances: [] Instance_Data;
	data: *Rendering_Data;
}


_, shader :: #run gpu_compile_shader("src/shader.slang");
_, overlay_shader :: #run gpu_compile_shader("src/overlay.slang");
