import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  build: {
    lib: {
      entry: [
        ...["canary-provider-cloud", "canary-provider-pagefind"],
        "canary-content",
        "canary-trigger",
        ...["canary-input-ask", "canary-input-search"],
        ...["canary-result-search", "canary-result-ask"],
        "canary-modal",
        "canary-markdown",
        ...[
          "canary-logo-cal",
          "canary-logo-calendly",
          "canary-logo-slack",
          "canary-logo-discord",
        ],
        ...[
          "canary-callout-cal",
          "canary-callout-calendly",
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
    rollupOptions: {
      external: ["/pagefind/pagefind.js"],
    },
  },
});
