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
        });
      },
    },
  };
};

export default plugin;
