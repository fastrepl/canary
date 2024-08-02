use keyword_extraction::yake::{Yake, YakeParams};
use stop_words::{get, LANGUAGE};

pub fn extract<'a>(text: &'a str, n: usize) -> anyhow::Result<Vec<String>> {
    let stop_words = get(LANGUAGE::English);
    let yake = Yake::new(YakeParams::WithDefaults(text, &stop_words));

    let keywords: Vec<String> = yake.get_ranked_keywords(n);
    Ok(keywords)
}
