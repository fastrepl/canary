const base = "https://edge.bundlejs.com/";
const components = [
  "@getcanary/web@latest/components/canary-root.js",
  "@getcanary/web@latest/components/canary-provider-cloud.js",
  "@getcanary/web@latest/components/canary-modal.js",
  "@getcanary/web@latest/components/canary-trigger-searchbar.js",
  "@getcanary/web@latest/components/canary-input.js",
  "@getcanary/web@latest/components/canary-content.js",
  "@getcanary/web@latest/components/canary-search.js",
  "@getcanary/web@latest/components/canary-search-results.js",
];

const url = `${base}?q=${components.join(",")}`;

export default {
  async load() {
    const data = await fetch(url).then((res) => res.json());
    return { size: Math.round(data.size.rawUncompressedSize / 1024) };
  },
};
