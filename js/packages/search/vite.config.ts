import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  build: {
    lib: {
      formats: ["es"],
      entry: resolve(__dirname, "src/canary-search.ts"),
      fileName: "canary-search",
    },
  },
});
