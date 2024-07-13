import { defineConfig } from "vite";
import { resolve } from "path";
import mockServer from "vite-plugin-mock-server";

export default defineConfig({
  build: {
    lib: {
      entry: [
        "canary-search",
        "canary-panel",
        "canary-trigger",
        "canary-wrapper-starlight",
        "canary-wrapper-docusaurus",
        "canary-slack-logo",
        "canary-discord-logo",
        "canary-callout-slack",
        "canary-callout-discord",
      ].reduce(
        (acc, cur) => ({ ...acc, [cur]: resolve(__dirname, `src/${cur}.ts`) }),
        {} as Record<string, string>,
      ),
      formats: ["es"],
      fileName: (_, entryName) => `${entryName}.js`,
    },
    outDir: "components",
  },
  plugins: [
    mockServer({
      mockRootDir: ".",
      mockTsSuffix: "mock.ts",
    }),
  ],
});
