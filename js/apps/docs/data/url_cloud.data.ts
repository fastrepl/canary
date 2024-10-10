import fs from "node:fs";
import { parse } from "dotenv";

import { defineLoader } from "vitepress";

export interface Data {
  base: string;
  key: string;
}

declare const data: Data;
export { data };

export default defineLoader({
  watch: ["../.env"],
  load([envPath]): Data {
    if (process.env.NODE_ENV === "production") {
      return forProd();
    } else {
      return forDev(envPath);
    }
  },
});

const forDev = (path) => {
  const { CANARY_API_BASE, CANARY_PROJECT_KEY } = parse(
    fs.readFileSync(path, "utf-8"),
  );

  return {
    base: CANARY_API_BASE,
    key: CANARY_PROJECT_KEY,
  };
};

const forProd = () => {
  return {
    base: process.env.CANARY_API_BASE,
    key: process.env.CANARY_PROJECT_KEY,
  };
};
