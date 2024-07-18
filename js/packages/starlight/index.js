/** @type {() => import('@astrojs/starlight').StarlightExtension} */
const plugin = () => {
  return {
    name: "canary",
    hooks: {
      setup({ config, updateConfig }) {
        updateConfig({
          components: {
            ...(config.components ?? {}),
            Search: "@getcanary/starlight/Search.astro",
          },
        });
      },
    },
  };
};

export default plugin;
