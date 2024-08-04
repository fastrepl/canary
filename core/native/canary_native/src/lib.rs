mod chunk;
mod git;
mod html;
mod keywords;

#[cfg(test)]
mod tests;

rustler::init!(
    "Elixir.Canary.Native",
    [
        chunk_text,
        chunk_markdown,
        html_to_md,
        html_to_md_with_marker,
        clone_depth,
        extract_keywords
    ]
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

#[rustler::nif(schedule = "DirtyCpu")]
fn html_to_md_with_marker<'a>(content: &'a str) -> String {
    html::to_md_with_marker(content).unwrap()
}

#[rustler::nif(schedule = "DirtyIo")]
fn clone_depth<'a>(repo_url: &'a str, dest_path: &'a str, depth: i32) -> bool {
    match git::clone_depth(repo_url, dest_path, depth) {
        Ok(_) => true,
        Err(_) => false,
    }
}

#[rustler::nif]
fn extract_keywords<'a>(content: &'a str, n: usize) -> Vec<String> {
    keywords::extract(content, n).unwrap()
}
