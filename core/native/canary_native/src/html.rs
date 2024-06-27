use htmd::HtmlToMarkdown;

pub fn to_md<'a>(content: &'a str) -> anyhow::Result<String> {
    let converter = HtmlToMarkdown::builder()
        .skip_tags(vec!["script", "style", "nav", "header", "footer"])
        .add_handler(vec!["div"], handle_div_aria_label)
        .build();

    converter.convert(content).map_err(anyhow::Error::from)
}

fn handle_div_aria_label(element: htmd::Element) -> Option<String> {
    if let Some(aria_label) = element
        .attrs
        .iter()
        .find(|attr| attr.name.local.as_ref() == "aria-label")
    {
        if aria_label.value == "Skip to main content".into() {
            return Some(String::new());
        }
    }

    Some(element.content.to_string())
}
