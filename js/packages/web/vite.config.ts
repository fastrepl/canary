import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  build: {
    lib: {
      entry: [
        "index",
        ...[
          "canary-provider-mock",
          "canary-provider-cloud",
          "canary-provider-pagefind",
          "canary-provider-vitepress-minisearch",
        ],
        ...["canary-styles-default"],
        ...[
          "canary-callout-cal",
          "canary-callout-calendly",
          "canary-callout-slack",
          "canary-callout-discord",
        ],
        "canary-modal",
        "canary-content",
        "canary-trigger-searchbar",
        ...[
          "canary-search",
          "canary-search-input",
          "canary-search-results",
          "canary-search-results-group",
        ],
        ...["canary-ask", "canary-ask-input", "canary-ask-results"],
        ...["contexts", "controllers", "mixins", "types"],
      ].reduce(
        (acc, cur) => ({ ...acc, [cur]: resolve(__dirname, `src/${cur}.ts`) }),
        {} as Record<string, string>,
      ),
      formats: ["es"],
      fileName: (_, entryName) => `${entryName}.js`,
    },
    outDir: "components",
    rollupOptions: {
      external: ["/pagefind/pagefind.js", "@localSearchIndex", "minisearch"],
    },
  },
});
