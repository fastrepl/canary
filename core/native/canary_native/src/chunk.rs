use text_splitter::{ChunkConfig, MarkdownSplitter, TextSplitter};
use tiktoken_rs::cl100k_base;

pub fn chunk_text<'a>(content: &'a str, max_tokens: usize) -> anyhow::Result<Vec<String>> {
    let tokenizer = cl100k_base().unwrap();

    let splitter = TextSplitter::new(ChunkConfig::new(max_tokens).with_sizer(tokenizer));
    let chunks = splitter.chunks(content);
    Ok(chunks.map(|chunk| chunk.to_string()).collect())
}

pub fn chunk_markdown<'a>(content: &'a str, max_tokens: usize) -> anyhow::Result<Vec<String>> {
    let tokenizer = cl100k_base()?;

    let splitter = MarkdownSplitter::new(ChunkConfig::new(max_tokens).with_sizer(tokenizer));
    let chunks = splitter.chunks(content);
    Ok(chunks.map(|chunk| chunk.to_string()).collect())
}
