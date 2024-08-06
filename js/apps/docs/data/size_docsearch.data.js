export default {
  async load() {
    const data = await fetch(
      "https://edge.bundlejs.com/?q=@docsearch/js@latest",
    ).then((res) => res.json());

    return { size: Math.round(data.size.rawUncompressedSize / 1024) };
  },
};
