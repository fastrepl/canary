mod chunk;

#[cfg(test)]
mod tests;

rustler::init!("Elixir.Canary.Native", [chunk_text, chunk_markdown]);

#[rustler::nif]
fn chunk_text<'a>(content: &'a str, max_tokens: usize) -> Vec<String> {
    chunk::chunk_text(content, max_tokens).unwrap()
}

#[rustler::nif]
fn chunk_markdown<'a>(content: &'a str, max_tokens: usize) -> Vec<String> {
    chunk::chunk_markdown(content, max_tokens).unwrap()
}
