use crate::html;
use crate::keywords;

use include_uri::include_str_from_url;
use insta::assert_debug_snapshot;

#[test]
fn exstract() {
    let html = include_str_from_url!("https://docs.litellm.ai/docs/budget_manager");
    let md = html::to_md(&html).unwrap();
    let words = keywords::extract(&md, 15).unwrap();
    assert_debug_snapshot!(words, @r###"
    [
        "calling llm apis",
        "llm apis",
        "litellm import budgetmanager",
        "litellm proxy server",
        "import budgetmanager",
        "litellm proxy",
        "budget manager",
        "calling llm",
        "proxy server",
        "budgetmanager completion",
        "messages",
        "api",
        "litellm import",
        "response",
        "hey",
    ]
    "###);
}
