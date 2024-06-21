import { defineConfig } from "vite";
import dts from "vite-plugin-dts";

import { resolve } from "path";

export default defineConfig({
  plugins: [dts({ insertTypesEntry: true, exclude: ["**/*.test.ts"] })],
  build: {
    lib: {
      entry: resolve(__dirname, "src/main.ts"),
      name: "@canary/core",
      fileName: "index",
    },
  },
});
