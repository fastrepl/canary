use crate::git;

use nanoid::nanoid;
use std::env::temp_dir;

#[test]
fn clone() {
    let repo_url = "https://github.com/fastrepl/canary.git";
    let dest_path = temp_dir().join(nanoid!()).to_str().unwrap().to_string();

    git::clone_depth(repo_url, &dest_path, 1).unwrap();
}
