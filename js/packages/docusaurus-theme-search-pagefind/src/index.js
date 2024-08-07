import path from "path";

import { getFilePaths } from "./utils";
import { buildIndex } from "./pagefind";

export default function plugin(_context, options) {
  const { indexOnly = false } = options;

  const config = {
    name: "docusaurus-plugin-pagefind-canary",
    async contentLoaded({ actions }) {
      actions.setGlobalData({ options });
    },
    configureWebpack() {
      if (process.env.NODE_ENV === "production") {
        return {};
      }

      return {
        module: {
          rules: [
            {
              test: /pagefind\/*/,
              use: [{ loader: "file-loader" }],
            },
          ],
        },
      };
    },
    async postBuild({ routesPaths = [], outDir, baseUrl }) {
      const docs = getFilePaths(routesPaths, outDir, baseUrl, options);
      await buildIndex(outDir, docs);
    },
  };

  if (indexOnly) {
    return config;
  }

  return {
    ...config,
    getThemePath() {
      return path.resolve(__dirname, "./theme");
    },
  };
}
