#load "src/utils.jai";
#load "src/widget.jai";
#load "src/rendering.jai";

gui_init :: (window: Window_Type) #expand {
	`__gpu_context := gpu_context;
	gpu_context = __gpu_context;
	assert(gpu_context != null, "GPU Context was not intialized, this procedure needs to be called with an initialized context.");
	
	_gui_init(window);
}

#scope_module;

#import "no_api";
#import "Basic";
#import "Math";
#import "Flat_Pool";
#import "Hash_Table";

_gui_init :: (window: Window_Type) {
	gui_context = new(Gui_Context);
	
	gui_rendering_init(window);
}

gui_context: *Gui_Context;

using gui_context;

Gui_Context :: struct {
	using rendering_context: Gui_Rendering_Context;

	root: *Widget;
	last: *Widget;

	table: Table(u64, *Widget);
	memory: Flat_Pool;
}

WT :: #import "Window_Type"; 
Window_Type :: WT.Window_Type;
