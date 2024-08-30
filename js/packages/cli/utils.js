import { homedir } from "os";
import { resolve } from "path";
import { mkdirSync, readFileSync, writeFileSync } from "fs";

import { customAlphabet } from "nanoid";

export const readConfigFromDisk = () => {
  const path = resolve(homedir(), ".canary", "config.json");

  try {
    const data = readFileSync(path, "utf-8");
    return JSON.parse(data);
  } catch (e) {
    return null;
  }
};

export const writeConfigToDisk = (obj) => {
  const path = resolve(homedir(), ".canary", "config.json");

  mkdirSync(path, { recursive: true });
  writeFileSync(path, JSON.stringify(obj));
};

export const nanoid = customAlphabet("123456789QAZWSXEDCRFVTGBYHNUJMIKOLP", 8);
