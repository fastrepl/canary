import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  build: {
    lib: {
      entry: [
        "index",
        "canary-panel",
        "canary-trigger",
        "canary-modal",
        "canary-radio",
        "canary-wrapper-starlight",
        "canary-wrapper-docusaurus",
        "canary-logo-cal",
        "canary-logo-slack",
        "canary-logo-discord",
        "canary-callout-cal",
        "canary-callout-slack",
        "canary-callout-discord",
        "canary-markdown",
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
