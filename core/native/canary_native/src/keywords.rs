use std::collections::HashSet;

use keyword_extraction::yake::{Yake, YakeParams};
use stop_words::{get, LANGUAGE};
use tokenizers::{normalizers::BertNormalizer, NormalizedString, Normalizer};

pub fn extract<'a>(text: &'a str, n: usize) -> anyhow::Result<Vec<String>> {
    let stop_words = get(LANGUAGE::English);
    let yake = Yake::new(YakeParams::WithDefaults(text, &stop_words));

    let ret: Vec<String> = yake
        .get_ranked_keywords(n)
        .into_iter()
        .flat_map(|word| {
            word.split(|c: char| c.is_whitespace() || c == '_' || c == '-')
                .map(String::from)
                .collect::<Vec<_>>()
        })
        .map(|word| remove_emoji(&word))
        .map(|word| bert_normalize(&word))
        .filter(|word| word.len() >= 3 && word.len() <= 18)
        .collect::<HashSet<String>>()
        .into_iter()
        .collect::<Vec<String>>();

    Ok(ret)
}

fn remove_emoji(string: &str) -> String {
    use unicode_segmentation::UnicodeSegmentation;
    let graphemes = string.graphemes(true);

    let not_emoji = |x: &&str| emojis::get(x).is_none();
    graphemes.filter(not_emoji).collect()
}

pub fn bert_normalize(text: &str) -> String {
    let mut text = NormalizedString::from(text);
    let bert_normalizer = BertNormalizer::new(true, false, Some(true), true);
    let _ = bert_normalizer.normalize(&mut text);

    text.get().to_string()
}
