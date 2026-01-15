#import "no_api";
#import,file "../module.jai";

#import "Window_Creation";
#import "stb_image";
#import "Input";

#import "Math";

#import "Basic";
#import "File";


Vertex :: struct {
	pos: Vector3 ;
	col: Vector3 ;
	uvs: Vector2 ;
}

get_window_size :: (window: Window_Type) -> s32, s32{
	_ ,_, w, h := get_dimensions(window, false);
	return w, h;
}

main :: (){
	set_working_directory(#filepath);
	window := create_window(1280, 720, "Window Creation");
	quit := false;

	gpu_init(16, {.GENERAL, 2});
	gpu_create_swapchain(window, 1280, 720, .FIFO);
	queue := gpu_create_queue(.GENERAL);
	
	gui_init(window);

	_, shader := gpu_compile_shader("res/shader");
	vertex_ir := gpu_create_shader(shader, "v_main");
	fragment_ir := gpu_create_shader(shader, "f_main");
	rasterizer_descriptor: Rasterizer_Descriptor = .{
		color_targets = .[
			.{format = .R8G8B8A8_UNORM}
		]
	};
	
	pipeline := gpu_create_graphic_pipeline(vertex_ir, fragment_ir, rasterizer_descriptor);
	backbuffer := gpu_create_texture({2560, 1440, .R8G8B8A8_UNORM, .STORAGE | .COLOR_ATTACHMENT | .TRANSFER_SRC | .TRANSFER_DST | .SAMPLED });

	vertex := gpu_malloc(3, Vertex);
	vertex[0] = .{{0, -0.5, 0}, {0, 0, 1}, {-1, -1}};
	vertex[1] = .{{0.5, 0.5, 0}, {0, 0, 1},   {1, 1}};
	vertex[2] = .{{-0.5, 0.5, 0}, {0, 0, 1},  {-1, 1}};
	
	indices := gpu_malloc(3, u32);
	indices[0] = 0;
	indices[1] = 1;
	indices[2] = 2;

	t: float = 0;
	while !quit {
		t += 0.1;
		update_window_events();
		for get_window_resizes() {
            gpu_resize_swapchain(it.width, it.height);
			gui_resize(it.width, it.height);
		}

		get_window_size(window);
		
		command_buffer := gpu_start_command_recording(*queue);
		{
			render_pass := Render_Pass_Descriptor.{
				color_targets = .[{*backbuffer, .CLEAR, .STORE, .[1, 0, 0, 1]}]
			};
			gpu_scoped_render_pass(command_buffer, render_pass);
			gpu_bind_pipeline(*command_buffer, *pipeline);
			gpu_draw_indexed(command_buffer, gpu_host_to_device_address(vertex), null, indices, 3);
		}

		w, h := get_window_size(window);
		draw_rect(0,  0, w / 2, h);

		gui_box();

		gui_render_frame(command_buffer, *backbuffer);
		
		if gpu_present(command_buffer, *queue, *backbuffer) then break;
		gpu_end_command_recording(command_buffer);
		
		gpu_submit(*queue, command_buffer);
    }
}
