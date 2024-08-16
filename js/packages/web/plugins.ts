import * as fs from "fs";
import * as path from "path";
import type { Plugin } from "vite";

export const cssVariablesReportPlugin = (): Plugin => {
  const regex = /--canary-[\w-]+/g;
  const set = new Set<string>();
  let root = "";

  return {
    name: "css-variables-report",
    configResolved(config) {
      root = config.root;
      if (!root) {
        throw new Error();
      }
    },
    transform(code, path) {
      if (!path.startsWith(root)) {
        return code;
      }

      code.match(regex)?.forEach((match) => {
        set.add(match);
      });

      return code;
    },
    buildEnd() {
      const outfile = path.resolve(
        root,
        "../../apps/docs/contents/docs/common/customization/styling.variables.md",
      );

      const content =
        Array.from(set)
          .sort()
          .map((variable) => `- \`${variable}\``)
          .join("\n") + "\n";

      fs.writeFileSync(outfile, content);
    },
  };
};
