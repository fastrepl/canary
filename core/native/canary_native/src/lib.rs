use ::glob_match as glob;

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
        clone_depth,
        extract_keywords,
        glob_match,
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



#[rustler::nif]
fn glob_match<'a>(pattern: &'a str, path: &'a str) -> bool {
    glob::glob_match(pattern, path)
}
