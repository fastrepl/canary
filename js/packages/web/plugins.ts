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

export const partsReportPlugin = (): Plugin => {
  const components: Record<string, Set<string>> = {};
  let root = "";

  return {
    name: "parts-report",
    configResolved(config) {
      root = config.root;
      if (!root) {
        throw new Error("Root directory not found in config");
      }
    },
    transform(code, filePath) {
      if (!filePath.startsWith(root)) {
        return code;
      }

      const match = filePath.match(/\/(canary-[^\/]+)\.(ts|js)$/);
      if (!match) {
        return code;
      }

      const parts = [...code.matchAll(/part="([\w-]+)"/g)].map((m) => m[1]);
      if (parts.length === 0) {
        return code;
      }

      components[match[1]] = new Set(parts);

      return code;
    },
    buildEnd() {
      const outfile = path.resolve(
        root,
        "../../apps/docs/contents/docs/common/customization/styling.parts.md",
      );

      const content = Object.entries(components)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([component, parts]) => {
          const partsRendered = Array.from(parts)
            .sort()
            .map((p) => `  - \`${p}\``)
            .join("\n");

          return `- \`${component}\`\n${partsRendered}`;
        })
        .join("\n");

      fs.writeFileSync(outfile, content);
    },
  };
};
