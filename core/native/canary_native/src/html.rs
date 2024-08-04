use htmd::HtmlToMarkdown;

pub fn to_md<'a>(content: &'a str) -> anyhow::Result<String> {
    let converter = HtmlToMarkdown::builder()
        .skip_tags(vec!["script", "style", "nav", "header", "footer"])
        .add_handler(vec!["div"], handle_div_aria_label)
        .add_handler(vec!["a"], handle_internal_link)
        .build();

    converter.convert(content).map_err(anyhow::Error::from)
}

pub fn to_md_with_marker<'a>(content: &'a str) -> anyhow::Result<String> {
    let converter = HtmlToMarkdown::builder()
        .skip_tags(vec!["script", "style", "nav", "header", "footer"])
        .add_handler(vec!["div"], handle_div_aria_label)
        .add_handler(vec!["a"], handle_internal_link)
        .add_handler(vec!["h2"], handle_h2)
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

fn handle_internal_link(element: htmd::Element) -> Option<String> {
    if let Some(href) = element
        .attrs
        .iter()
        .find(|attr| attr.name.local.as_ref() == "href")
    {
        if href.value.starts_with("#") {
            return Some(String::new());
        } else {
            return format!("[{}]({})", element.content, href.value).into();
        }
    }

    Some(element.content.to_string())
}

fn handle_h2(element: htmd::Element) -> Option<String> {
    if let Some(id) = element
        .attrs
        .iter()
        .find(|attr| attr.name.local.as_ref() == "id")
    {
        return Some(format!(
            "__CANARY__({})## {}",
            id.value.to_string(),
            element.content.to_string()
        ));
    }

    Some(format!("## {}", element.content.to_string()))
}
