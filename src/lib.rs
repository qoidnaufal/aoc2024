#[no_mangle]
extern "C" fn process_in_rust(c_input: *const u8, len: usize) {
    let input = unsafe {
        std::str::from_utf8_unchecked(std::slice::from_raw_parts(c_input, len))
    };
    parse_input(input);
}

fn parse_input(input: &str) {
    let mut sections = input.split("\n\n");
    let Some(rules) = sections.next() else { return };
    let Some(page_order) = sections.next() else { return };

    println!("{}", rules);
    println!("{}", page_order);
}
