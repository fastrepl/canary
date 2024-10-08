import type { Plugin as CEMPlugin } from "@custom-elements-manifest/analyzer";

type Import = {
  name: string;
  kind: string;
  importPath: string;
  isBareModuleSpecifier: boolean;
  isTypeOnly: boolean;
};

export const canaryImportPlugin = (): CEMPlugin => {
  return {
    name: "canary-import",
    analyzePhase({ moduleDoc, context }) {
      const canaryImports = (context.imports as Import[])
        .filter(({ importPath }) => importPath.includes("canary-"))
        .map(({ importPath }) => importPath.split("/").pop());

      (moduleDoc as any)["canaryImports"] = canaryImports;
    },
  };
};
