use std::collections::HashMap;

use crate::Error;

pub fn solve(input: &str) -> Result<(), Error> {
    let parsed_input = parse_input(input)?;
    parsed_input.solve();

    Ok(())
}

struct ParsedInput {
    must_be_before: HashMap<u8, Vec<u8>>,
    must_be_after: HashMap<u8, Vec<u8>>,
    pages: Vec<Vec<u8>>
}

impl ParsedInput {
    fn solve(&self) {
        let mut part1: usize = 0;
        let mut part2: usize = 0;

        self.pages.iter().enumerate().for_each(|(_, pages)| {
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

                    page_status &= status_a;
                }
                if let Some(befores) = self.must_be_after.get(&pages[cursor]) {
                    let order = &pages[cursor + 1..];
                    let order_doesnt_contains_befores = !befores.iter().any(|n| order.contains(n));
                    let order_can_be_after = if !order.is_empty() {
                        order.iter().any(|n| !befores.contains(n))
                    } else { true };

                    page_status &= order_doesnt_contains_befores & order_can_be_after;
                }
                cursor += 1 % pages.len();
            }

            if page_status {
                let idx = (pages.len() - 1) / 2;
                part1 += pages[idx] as usize;
            } else {
                reorder(&self.must_be_before, &self.must_be_after, pages, &mut part2);
            }
        });

        // 4957
        // 6938
        println!("part 1 = {part1}, part 2 = {part2}");
    }
}

fn reorder(
    must_be_before: &HashMap<u8, Vec<u8>>,
    must_be_after: &HashMap<u8, Vec<u8>>,
    pages: &Vec<u8>,
    accumulator: &mut usize
) {
    let mut buffer = vec![0; pages.len()];

    pages.iter().enumerate().for_each(|(idx, page)| {
        let mut cursor: usize = 0;
        let mut delta = 0;
        if let Some(befores) = must_be_after.get(page) {
            let orders = &pages[idx..];
            if !orders.is_empty() {
                orders.iter().for_each(|n| {
                    if befores.contains(n) {
                        delta += 1;
                    }
                })
            }
        }
        if let Some(afters) = must_be_before.get(page) {
            if idx > 0 {
                let back_orders = &pages[..idx];
                afters.iter().for_each(|n| {
                    if back_orders.contains(n) {
                        cursor += 1;
                    }
                });
            }
        }
        buffer[idx + delta - cursor] = pages[idx];
        // println!("[{}] -> {cursor} + {delta} - {inner_cursor}", pages[cursor]);
    });

    *accumulator += buffer[(pages.len() - 1) / 2] as usize;
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
        } else {
            must_be_after.insert(num2, vec![num1]);
        }

        Ok(())
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
