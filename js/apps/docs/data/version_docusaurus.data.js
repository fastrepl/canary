export default {
  async load() {
    const data = await fetch(
      "https://registry.npmjs.org/@getcanary/docusaurus-theme-search-pagefind/latest",
    ).then((res) => res.json());

    return { version: data.version };
  },
};
