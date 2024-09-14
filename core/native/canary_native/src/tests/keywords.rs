use crate::html;
use crate::keywords;

use include_uri::include_str_from_url;
use insta::assert_debug_snapshot;

#[test]
fn extract() {
    let html = include_str_from_url!("https://docs.litellm.ai/docs/budget_manager");
    let md = html::to_md(&html).unwrap();
    let mut words = keywords::extract(&md, 30).unwrap();
    words.sort();

    assert_debug_snapshot!(words, @r###"
    [
        "api",
        "apis",
        "berriai",
        "budget",
        "budgetmanager",
        "calling",
        "class",
        "code",
        "complete",
        "completion",
        "def",
        "gpt",
        "hey",
        "hosted",
        "import",
        "litellm",
        "llm",
        "manager",
        "messages",
        "monthly",
        "name",
        "project",
        "proxy",
        "python",
        "response",
        "returns",
        "server",
        "str",
        "total",
        "user",
    ]
    "###);
}
