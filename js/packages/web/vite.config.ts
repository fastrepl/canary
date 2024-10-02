/// <reference types="vitest" />

import { resolve } from "path";

import { defineConfig } from "vite";
import unocss from "unocss/vite";

import dts from "vite-plugin-dts";
import cem from "vite-plugin-cem";
import { partsReportPlugin, cssVariablesReportPlugin } from "./plugins";

const components = [
  ...["canary-root", "canary-styles"],
  ...[
    "canary-provider-mock",
    "canary-provider-cloud",
    "canary-provider-pagefind",
    "canary-provider-vitepress-minisearch",
  ],
  ...[
    "canary-callout",
    "canary-callout-cal",
    "canary-callout-calendly",
    "canary-callout-slack",
    "canary-callout-discord",
  ],
  ...[
    "canary-modal",
    "canary-content",
    "canary-trigger-searchbar",
    "canary-trigger-logo",
  ],
  "canary-input",
  "canary-search",
  "canary-search-results",
  "canary-search-match",
  "canary-search-suggestions",
  "canary-search-empty",
  "canary-ask",
  "canary-ask-results",
  "canary-tooltip",
  "canary-footer",
  "canary-media-query",
  "canary-mode-tabs",
  "canary-mode-breadcrumb",
  "canary-filter-tabs-glob",
  "canary-filter-tags",
].map((name) => `components/${name}`);

export default defineConfig({
  test: {
    environmentMatchGlobs: [["./src/store/*.test.ts", "happy-dom"]],
  },
  plugins: [
    process.env.GENERATE_DOCS === "1" && partsReportPlugin(),
    process.env.GENERATE_DOCS === "1" && cssVariablesReportPlugin(),
    unocss({ mode: "shadow-dom" }),
    dts({ exclude: ["**/*.stories.*"] }),
    cem({
      files: components,
      output: "custom-elements.json",
      lit: true,
      packageJson: true,
    }),
  ].filter(Boolean),
  build: {
    minify: "terser",
    terserOptions: {
      format: {
        comments: /webpackIgnore|@vite/,
      },
    },
    lib: {
      entry: [
        ...components,
        ...["contexts", "controllers", "types/index", "utils", "store/index"],
      ].reduce(
        (acc, cur) => ({ ...acc, [cur]: resolve(__dirname, `src/${cur}.ts`) }),
        {} as Record<string, string>,
      ),
      formats: ["es"],
      fileName: (_, entryName) => `${entryName}.js`,
    },
    outDir: "dist",
    rollupOptions: {
      external: ["@localSearchIndex", "minisearch"],
    },
  },
});
