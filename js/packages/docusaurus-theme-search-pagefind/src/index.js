import path from "path";

import { getFilePaths } from "./utils";
import { buildIndex } from "./pagefind";

export default function plugin(_context, options) {
  const { indexOnly = false, disable = false } = options;

  const config = {
    name: "docusaurus-theme-search-pagefind",
    async contentLoaded({ actions }) {
      actions.setGlobalData({ options });
    },
    async postBuild({ routesPaths = [], outDir, baseUrl }) {
      if (process.env.NODE_ENV !== "production" || disable) {
        console.info(
          "\n'@getcanary/docusaurus-theme-search-pagefind': Pagefind indexing skipped.\n",
        );
        return;
      }

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
