gui_box :: (id: s64 = 0, loc := #caller_location){
	widget := create_widget(loc, 0);
}

#scope_module;

get_hash :: (loc: Source_Code_Location, identifier: s64) -> u64 {
    #import "Hash";
    name_hash := djb2_hash(loc.fully_pathed_filename);
    line_hash := knuth_hash(cast,no_check(u64) loc.line_number);
    identifier_hash := knuth_hash(cast,no_check(u64) identifier);

    result := combine_hashes(name_hash, combine_hashes(line_hash, identifier_hash));
    return result;
}

combine_hashes :: (a: u64, b: u64) -> u64 #no_aoc {
	KNUTH_GOLDEN_RATIO_64 :: 11400714819323198485;
    return a * KNUTH_GOLDEN_RATIO_64 + b;
}

create_widget :: (loc: Source_Code_Location, id: s64) -> *Widget {
	hash := get_hash(loc, id);
	found, ptr := table_find(*table, hash);
	if !found then ptr = table_add(*table, hash, get(*memory, Widget)).*;
	if !root then root = ptr;
	if last then last.next = ptr;
	last = ptr;
	
	return ptr;
}

Widget :: struct {
	next: *Widget;
}
