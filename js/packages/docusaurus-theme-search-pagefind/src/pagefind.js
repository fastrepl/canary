import fs from "fs";
import path from "path";

import micromatch from "micromatch";
import { parse, serialize } from "parse5";
import cliProgress from "cli-progress";

/**
 * @typedef PagefindRanking
 * @property {number} pageLength
 * @property {number} termFrequency
 * @property {number} termSimilarity
 * @property {number} termSaturation
 *
 * @typedef PagefindOptions
 * @property {PagefindRanking} ranking
 *
 * @typedef {Object} TagDefinition
 * @property {string} name
 * @property {string} pattern
 * @property {Object} [options] - https://github.com/micromatch/micromatch?tab=readme-ov-file#options
 *
 * @typedef {Object} TabDefinitions
 * @property {string} name
 * @property {string} pattern
 * @property {Object} [options] - https://github.com/micromatch/picomatch?tab=readme-ov-file#options
 *
 * @typedef {Object} Options
 * @description Some of these are used in this plugin, and some are passed to `canary-provider-pagefind`.
 * @property {PagefindRanking} [pagefind]
 * @property {Array<string>} [includeRoutes]
 * @property {Array<string>} [excludeRoutes]
 * @property {Record<string, string>} [styles]
 * @property {Array<TabDefinitions>} [tabs]
 * @property {Array<TagDefinition>} [tags]
 * @property {boolean} [verbose]
 * @property {number} [maxPages]
 * @property {number} [maxSubResults]
 * @property {string} [path]
 * @property {string} [_base]
 * @property {string} [_replace]
 *
 * @param {Options} options
 */
export const buildIndex = async (outDir, docs, options) => {
  const { createIndex, close } = await import("pagefind");
  const { index } = await createIndex({
    rootSelector: "html",
    verbose: !!options.verbose,
  });

  const bar = new cliProgress.SingleBar({}, cliProgress.Presets.shades_classic);
  bar.start(docs.length, 0);

  for (const [i, doc] of docs.entries()) {
    const content = getHTML(doc, options);
    await index.addHTMLFile({ url: doc.url, content });
    bar.update(i + 1);
  }
  bar.stop();
  console.log("\n");

  await index.writeFiles({ outputPath: path.join(outDir, "pagefind") });
  await close();
};

/**
 * @typedef {Object} Document
 * @property {string} url
 * @property {string} filePath
 * @property {string} relativePath
 *
 * @typedef {Object} TagDefinition
 * @property {string} name
 * @property {string} pattern
 * @property {Object} [options]
 *
 * @param {Document} doc
 * @param {object} options
 * @param {TagDefinition[]} options.tags
 */
const getHTML = (doc, options) => {
  const { tags = [] } = options;

  const html = fs.readFileSync(doc.filePath, "utf-8");

  if (tags.length === 0) {
    return html;
  }

  const matched = tags
    .filter(({ pattern, options }) =>
      [doc.filePath, doc.relativePath].some((s) =>
        micromatch.isMatch(s, pattern, options),
      ),
    )
    .map(({ name }) => name)
    .join(",");

  const dom = parse(html);

  dom.childNodes[1].attrs.push({
    // https://pagefind.app/docs/metadata/#specifying-metadata-inline
    name: "data-pagefind-meta",
    value: `tags:${matched}`,
  });

  return serialize(dom);
};
