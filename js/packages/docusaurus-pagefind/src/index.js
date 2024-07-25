import path from "path";

import { getFilePaths } from "./utils";
import { buildIndex } from "./pagefind";

export default function plugin(_context, options) {
  return {
    name: "docusaurus-plugin-pagefind-canary",
    getThemePath() {
      return path.resolve(__dirname, "./theme");
    },
    async contentLoaded({ actions }) {
      actions.setGlobalData({ options });
    },
    async postBuild({ routesPaths = [], outDir, baseUrl }) {
      const docs = getFilePaths(routesPaths, outDir, baseUrl, options);
      await buildIndex(outDir, docs);
    },
  };
}
