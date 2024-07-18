/** @type {() => import('@astrojs/starlight').StarlightExtension} */
const plugin = () => {
  return {
    name: "canary",
    hooks: {
      setup({ config, updateConfig }) {
        updateConfig({
          components: {
            ...(config.components ?? {}),
            Search: "@getcanary/starlight/search.astro",
          },
          head: [
            ...[
              "canary-provider-pagefind",
              "canary-styles-starlight",
              "canary-modal",
              "canary-trigger-searchbar",
              "canary-content",
              "canary-search",
              "canary-search-input",
              "canary-search-results",
            ].map((c) => ({
              tag: "script",
              attrs: {
                type: "module",
                src: `https://unpkg.com/@getcanary/web@0.0.31/components/${c}.js`,
              },
            })),
          ],
        });
      },
    },
  };
};

export default plugin;
