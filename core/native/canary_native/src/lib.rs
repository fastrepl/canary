mod chunk;
mod html;

#[cfg(test)]
mod tests;

rustler::init!(
    "Elixir.Canary.Native",
    [chunk_text, chunk_markdown, html_to_md]
);

#[rustler::nif]
fn chunk_text<'a>(content: &'a str, max_tokens: usize) -> Vec<String> {
    chunk::chunk_text(content, max_tokens).unwrap()
}

#[rustler::nif]
fn chunk_markdown<'a>(content: &'a str, max_tokens: usize) -> Vec<String> {
    chunk::chunk_markdown(content, max_tokens).unwrap()
}

#[rustler::nif(schedule = "DirtyCpu")]
fn html_to_md<'a>(content: &'a str) -> String {
    html::to_md(content).unwrap()
}
