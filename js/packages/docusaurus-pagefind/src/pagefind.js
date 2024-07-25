import fs from "fs";
import path from "path";

import cliProgress from "cli-progress";

export const buildIndex = async (outDir, docs) => {
  const { createIndex, close } = await import("pagefind");
  const { index } = await createIndex();

  const bar = new cliProgress.SingleBar({}, cliProgress.Presets.shades_classic);
  bar.start(docs.length, 0);

  for (const [i, doc] of docs.entries()) {
    const content = fs.readFileSync(doc.path, "utf-8");
    await index.addHTMLFile({ url: doc.url, content });
    bar.update(i + 1);
  }
  bar.stop();
  console.log("\n");

  await index.writeFiles({ outputPath: path.join(outDir, "pagefind") });
  await close();
};
