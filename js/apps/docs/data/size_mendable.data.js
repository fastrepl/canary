export default {
  async load() {
    const data = await fetch(
      "https://edge.bundlejs.com/?q=@mendable/search@latest",
    ).then((res) => res.json());

    return { size: Math.round(data.size.rawUncompressedSize / 1024) };
  },
};
