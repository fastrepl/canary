use crate::chunk;

use include_uri::include_str_from_url;
use insta::assert_debug_snapshot;

const MAX_TOKENS: usize = 20;

#[test]
fn chunk_text() {
    let result = chunk::chunk_text(include_str_from_url!("https://raw.githubusercontent.com/BerriAI/litellm/b7eb2527ff5e21885e1886c825c3e97d53972bc8/docs/my-website/docs/completion/message_trimming.md"), MAX_TOKENS).unwrap();

    assert_debug_snapshot!(result, @r###"
    [
        "# Trimming Input Messages",
        "**Use litellm.trim_messages() to ensure messages does not exceed a model's token limit or",
        "specified `max_tokens`**",
        "## Usage \n```python\nfrom litellm import completion",
        "from litellm.utils import trim_messages",
        "response = completion(\n    model=model,",
        "messages=trim_messages(messages, model) # trim_messages ensures tokens(messages) < max_tokens(model)",
        ") \n```",
        "## Usage - set max_tokens\n```python\nfrom litellm import completion",
        "from litellm.utils import trim_messages",
        "response = completion(\n    model=model,",
        "messages=trim_messages(messages, model, max_tokens=10), # trim_messages ensures tokens(messages)",
        "< max_tokens\n) \n```\n\n## Parameters\n\nThe function uses the following parameters:",
        "- `messages`:[Required] This should be a list of input messages",
        "- `model`:[Optional] This is the LiteLLM model being used.",
        "This parameter is optional, as you can alternatively specify the `max_tokens` parameter.",
        "- `max_tokens`:[Optional] This is an int, manually set upper limit on messages",
        "- `trim_ratio`:[Optional] This represents the target ratio of tokens to use following trimming.",
        "It's default value is 0.75, which implies that messages will be trimmed to utilise about",
        "75%",
    ]
    "###);
}

#[test]
fn chunk_markdown() {
    let result = chunk::chunk_markdown(include_str_from_url!("https://raw.githubusercontent.com/BerriAI/litellm/b7eb2527ff5e21885e1886c825c3e97d53972bc8/docs/my-website/docs/completion/message_trimming.md"), MAX_TOKENS).unwrap();

    assert_debug_snapshot!(result, @r###"
    [
        "# Trimming Input Messages",
        "**Use litellm.trim_messages() to ensure messages does not exceed a model's token limit or",
        "specified `max_tokens`**",
        "## Usage",
        "```python",
        "from litellm import completion\nfrom litellm.utils import trim_messages\n\nresponse = completion(",
        "model=model,",
        "messages=trim_messages(messages, model) # trim_messages ensures tokens(messages) < max_tokens(model)",
        ") \n```",
        "## Usage - set max_tokens",
        "```python",
        "from litellm import completion\nfrom litellm.utils import trim_messages\n\nresponse = completion(",
        "model=model,",
        "messages=trim_messages(messages, model, max_tokens=10), # trim_messages ensures tokens(messages)",
        "< max_tokens\n) \n```",
        "## Parameters\n\nThe function uses the following parameters:",
        "- `messages`:[Required] This should be a list of input messages",
        "- `model`:[Optional]",
        "This is the LiteLLM model being used.",
        "This parameter is optional, as you can alternatively specify the `max_tokens` parameter.",
        "- `max_tokens`:[Optional] This is an int, manually set upper limit on messages",
        "- `trim_ratio`:[Optional]",
        "This represents the target ratio of tokens to use following trimming. It'",
        "s default value is 0.75, which implies that messages will be trimmed to utilise about",
        "75%",
    ]
    "###);
}
