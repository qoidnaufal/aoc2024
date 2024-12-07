use std::collections::HashMap;

use crate::Error;

pub fn solve(input: &str) -> Result<(), Error> {
    let parsed_input = parse_input(input).unwrap();
    parsed_input.solve_part1();

    Ok(())
}

struct ParsedInput {
    must_be_before: HashMap<u8, Vec<u8>>,
    must_be_after: HashMap<u8, Vec<u8>>,
    pages: Vec<Vec<u8>>
}

impl ParsedInput {
    fn solve_part1(&self) {
        println!("bfr | {:?}", self.must_be_before);
        println!("aft | {:?}", self.must_be_after);
        println!("pgs | {:?}\n", self.pages);

        let mut accumulator: usize = 0;

        self.pages.iter().enumerate().for_each(|(line, pages)| {
            let mut page_status = true;
            let mut cursor = 0;
            for page in pages {
                if let Some(afters) = self.must_be_before.get(page) {
                    let orders = &pages[cursor + 1..];
                    let status_a = if !orders.is_empty() {
                        orders.iter().any(|order| {
                            let rule_b = if let Some(befores) = self.must_be_after.get(order) {
                                befores.contains(page)
                            } else {
                                true
                            };
                            afters.contains(order) & rule_b
                        })
                    } else { true };
                    println!(">> line {line}, cursor {cursor}, [{page}]");
                    println!("   [{page}] must be before {afters:?}");
                    println!("   can [{page}] be before {:?} => {status_a}\n", orders);

                    page_status &= status_a;
                }
                if let Some(befores) = self.must_be_after.get(&pages[cursor]) {
                    let order = &pages[cursor + 1..];
                    let order_doesnt_contains_befores = !befores.iter().any(|n| order.contains(n));
                    let order_can_be_after = if !order.is_empty() {
                        order.iter().any(|n| !befores.contains(n))
                    } else { true };
                    println!(">> line {line}, cursor {cursor}, [{}],", pages[cursor]);
                    println!("   is {order:?} not inside {befores:?} => {order_can_be_after}");
                    println!("   can {order:?} be after [{}] => {order_doesnt_contains_befores}\n", pages[cursor]);

                    page_status &= order_doesnt_contains_befores & order_can_be_after;
                }

                if !page_status { break };
                cursor += 1 % pages.len();
            }

            if page_status {
                let idx = (pages.len() - 1) / 2;
                accumulator += pages[idx] as usize;
            }
            println!("-- line {line} => {page_status}\n");
        });

        println!("part 1 = {accumulator}");
    }
}

fn parse_input(input: &str) -> Result<ParsedInput, Error> {
    let mut sections = input.split("\n\n");
    let Some(rule_section) = sections.next() else { return Err(Error::InvalidInput) };
    let Some(pages_section) = sections.next() else { return Err(Error::InvalidInput) };

    let mut must_be_before = HashMap::<u8, Vec<u8>>::new();
    let mut must_be_after = HashMap::<u8, Vec<u8>>::new();
    rule_section.lines().try_for_each(|token| {
        let Ok(num1) = token[..2].parse::<u8>() else { return Err(Error::ParseError) };
        let Ok(num2) = token[3..].parse::<u8>() else { return Err(Error::ParseError) };

        if let Some(entry) = must_be_before.get_mut(&num1) {
            entry.push(num2);
        } else {
            must_be_before.insert(num1, vec![num2]);
        }
        
        if let Some(entry) = must_be_after.get_mut(&num2) {
            entry.push(num1);
            Ok(())
        } else {
            must_be_after.insert(num2, vec![num1]);
            Ok(())
        }
    })?;

    let pages = pages_section
        .lines()
        .map(|line| {
            line.split(",")
                .filter_map(|token| token.parse::<u8>().ok())
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();

    Ok(ParsedInput { must_be_before, must_be_after, pages })
}
