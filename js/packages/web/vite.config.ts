/// <reference types="vitest" />

import { resolve } from "path";

import { defineConfig } from "vite";
import unocss from "unocss/vite";

import dts from "vite-plugin-dts";
import cem from "vite-plugin-cem";
import { canaryImportPlugin } from "./plugins";

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
    "canary-logo-cal",
    "canary-logo-calendly",
    "canary-logo-discord",
    "canary-logo-github",
    "canary-logo-slack",
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
  "canary-search-match-base",
  "canary-search-match-webpage",
  "canary-search-match-openapi",
  "canary-search-match-github-issue",
  "canary-search-match-github-discussion",
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
    unocss({ mode: "shadow-dom" }),
    dts({
      include: ["src/**/*.ts"],
      exclude: ["**/*.stories.*", "**/*.test.ts"],
    }),
    cem({
      files: components.map((c) => `src/${c}.ts`),
      output: "custom-elements.json",
      lit: true,
      packageJson: false,
      plugins: [canaryImportPlugin()],
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
