use std::path::Path;

pub fn clone_depth<'a>(repo_url: &'a str, dest_path: &'a str, depth: i32) -> anyhow::Result<()> {
    let mut fo = git2::FetchOptions::new();
    fo.depth(depth);

    let mut builder = git2::build::RepoBuilder::new();
    builder.fetch_options(fo);
    builder.clone(repo_url, Path::new(dest_path))?;

    Ok(())
}
