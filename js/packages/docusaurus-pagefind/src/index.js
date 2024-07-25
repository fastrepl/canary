import path from "path";

import { getFilePaths } from "./utils";
import { buildIndex } from "./pagefind";
import { NAME } from "./shared";

export default function plugin(_context, options) {
  return {
    name: NAME,
    getThemePath() {
      return path.resolve(__dirname, "./theme");
    },
    async postBuild({ routesPaths = [], outDir, baseUrl }) {
      const docs = getFilePaths(routesPaths, outDir, baseUrl, options);
      await buildIndex(outDir, docs);
    },
  };
}
