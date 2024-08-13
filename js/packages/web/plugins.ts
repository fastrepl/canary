import type { Plugin } from "vite";

export const CSSVariablesReportPlugin = (): Plugin => {
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
      const variables = Array.from(set).sort();
      const seperator = new Array(20).fill("-").join("");

      console.info(`\n${seperator}`);
      variables.forEach((variable) => {
        console.info(variable);
      });
      console.info(`${seperator}\n`);
    },
  };
};
