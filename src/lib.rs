mod day5;

#[derive(Debug)]
pub enum Error {
    InvalidInput,
    ParseError
}

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self)
    }
}

impl std::error::Error for Error {}

pub enum Day {
    Day5,
    NotYet(usize)
}

impl From<usize> for Day {
    fn from(value: usize) -> Self {
        match value {
            5 => Self::Day5,
            n => Self::NotYet(n)
        }
    }
}

#[no_mangle]
extern "C" fn process_in_rust(c_input: *const u8, len: usize, day: usize) {
    let input = unsafe {
        std::str::from_utf8_unchecked(std::slice::from_raw_parts(c_input, len))
    };

    match Day::from(day) {
        Day::Day5 => day5::solve(input).unwrap(),
        Day::NotYet(d) => println!("Day {d} is not available yet!!!"),
    }
    
}
