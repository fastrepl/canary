import { defineConfig } from "vite";
import { resolve } from "path";
import mockServer from "vite-plugin-mock-server";

export default defineConfig({
  build: {
    lib: {
      entry: {
        "canary-search": resolve(__dirname, "src/canary-search.ts"),
        "canary-panel": resolve(__dirname, "src/canary-panel.ts"),
      },
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
