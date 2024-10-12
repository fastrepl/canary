import fs from "fs";
import path from "path";

import { getFilePaths } from "./utils";
import { buildIndex } from "./pagefind";

/**
 * @typedef {import("@docusaurus/types").Plugin} Plugin
 * @typedef {import("@docusaurus/types").DocusaurusContext} DocusaurusContext
 * @typedef {import("webpack").Configuration} WebpackConfiguration
 *
 * @typedef PagefindRanking
 * @property {number} pageLength
 * @property {number} termFrequency
 * @property {number} termSimilarity
 * @property {number} termSaturation
 *
 * @typedef PagefindOptions
 * @property {PagefindRanking} ranking
 *
 * @typedef {Object} PluginOptions
 * @property {boolean} indexOnly
 * @property {PagefindRanking} pagefind
 * @property {Array<string>} includeRoutes
 * @property {Array<string>} excludeRoutes
 * @property {Record<string, string>} styles
 * @property {Array<Object>} tabs
 */

/**
 * @param {DocusaurusContext} context
 * @param {PluginOptions} options
 */
export default function plugin(context, options) {
  const { indexOnly = false } = options;

  /**
   * @type {Plugin}
   */
  const config = {
    name: "docusaurus-theme-search-pagefind",
    async contentLoaded({ actions }) {
      actions.setGlobalData({ options });
    },
    async postBuild({ routesPaths = [], outDir, baseUrl }) {
      const docs = getFilePaths(routesPaths, outDir, baseUrl, options);
      await buildIndex(outDir, docs, options);
    },
    /**
     * @returns {WebpackConfiguration}
     */
    configureWebpack(config, isServer, utils) {
      return {
        devServer: {
          setupMiddlewares(middlewares, devServer) {
            devServer.app.get("/pagefind/*", (req, res) => {
              const filePath = path.join(context.outDir, req.path);

              if (fs.existsSync(filePath)) {
                res.sendFile(filePath);
              } else {
                res.status(404).send("");
              }
            });

            return middlewares;
          },
        },
      };
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
