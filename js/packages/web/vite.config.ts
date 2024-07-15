import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  build: {
    lib: {
      entry: [
        "index",
        ...["canary-provider-cloud", "canary-provider-pagefind"],
        "canary-panel",
        "canary-trigger",
        "canary-modal",
        "canary-markdown",
        ...["canary-logo-cal", "canary-logo-slack", "canary-logo-discord"],
        ...[
          "canary-callout-cal",
          "canary-callout-slack",
          "canary-callout-discord",
        ],
        ...["canary-styles-starlight", "canary-styles-docusaurus"],
        ...["canary-mode-tabs", "canary-search-tabs"],
      ].reduce(
        (acc, cur) => ({ ...acc, [cur]: resolve(__dirname, `src/${cur}.ts`) }),
        {} as Record<string, string>,
      ),
      formats: ["es"],
      fileName: (_, entryName) => `${entryName}.js`,
    },
    outDir: "components",
  },
});
