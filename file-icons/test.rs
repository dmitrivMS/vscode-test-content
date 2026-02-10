use std::collections::HashMap;
use std::io::{self, BufRead};

fn word_frequency(text: &str) -> HashMap<String, usize> {
    let mut counts = HashMap::new();
    for word in text.split_whitespace() {
        let normalized = word
            .trim_matches(|c: char| !c.is_alphanumeric())
            .to_lowercase();
        if !normalized.is_empty() {
            *counts.entry(normalized).or_insert(0) += 1;
        }
    }
    counts
}

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut all_text = String::new();

    for line in stdin.lock().lines() {
        all_text.push_str(&line?);
        all_text.push(' ');
    }

    let mut freq: Vec<_> = word_frequency(&all_text).into_iter().collect();
    freq.sort_by(|a, b| b.1.cmp(&a.1));

    for (word, count) in freq.iter().take(20) {
        println!("{:>6} {}", count, word);
    }

    Ok(())
}
