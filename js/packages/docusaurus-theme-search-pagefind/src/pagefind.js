import fs from "fs";
import path from "path";

import micromatch from "micromatch";
import { parse, serialize } from "parse5";
import cliProgress from "cli-progress";

export const buildIndex = async (outDir, docs, options) => {
  const { createIndex, close } = await import("pagefind");
  const { index } = await createIndex();

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
  const dom = parse(html);

  const matched = tags
    .filter(({ pattern, options }) =>
      [doc.filePath, doc.relativePath].some((s) =>
        micromatch.isMatch(s, pattern, options),
      ),
    )
    .map(({ name }) => name)
    .join(",");

  // https://pagefind.app/docs/metadata/#specifying-metadata-inline
  dom.childNodes[1].attrs.push({
    name: "data-pagefind-meta",
    value: `tags:${matched}`,
  });

  return serialize(dom);
};
