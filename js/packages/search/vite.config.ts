import { defineConfig } from "vite";
import { resolve } from "path";
import mockServer from "vite-plugin-mock-server";

export default defineConfig({
  build: {
    lib: {
      formats: ["es"],
      entry: resolve(__dirname, "src/canary-search.ts"),
      fileName: "canary-search",
    },
  },
  plugins: [
    mockServer({
      mockRootDir: ".",
      mockTsSuffix: "mock.ts",
    }),
  ],
});
