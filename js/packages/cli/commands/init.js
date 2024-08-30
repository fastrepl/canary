import { existsSync, writeFileSync } from "fs";
import { resolve } from "path";

import { Command } from "commander";

import { isCancel } from "@clack/core";
import { intro, outro, text, cancel } from "@clack/prompts";

import { name } from "../package.json";

export const init = new Command("init");

init.action(async () => {
  const FILE_NAME = "canary.yaml";

  const getConfigPath = (path) => resolve(process.cwd(), path, FILE_NAME);
  const getDefaultConfigContent = () =>
    `
# yaml-language-server: $schema=./spec.schema.json
sources:
  - name: doc
    type: web
`.trim();

  intro(`${name}/init`);

  const path = await text({
    message: `Where do you want to create '${FILE_NAME}'?`,
    placeholder: "relative path",
    validate(value) {
      if (value.length === 0) {
        return `'path' is required!`;
      }

      const absolutePath = getConfigPath(value);

      if (existsSync(absolutePath)) {
        return `File already exists at '${absolutePath}'!`;
      }
    },
  });
  if (isCancel(path)) {
    cancel("Cancelled!");
    return process.exit(0);
  }

  try {
    writeFileSync(getConfigPath(path), getDefaultConfigContent());
    outro(`Config file created at '${getConfigPath(path)}'`);
  } catch (e) {
    cancel(e.message);
    return process.exit(1);
  }
});
