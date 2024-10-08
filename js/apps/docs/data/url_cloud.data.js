import fs from "node:fs";
import { parse } from "dotenv";

export default {
  watch: ["../.env"],
  load([envPath]) {
    if (process.env.NODE_ENV === "production") {
      return forProd();
    } else {
      return forDev(envPath);
    }
  },
};

const forDev = (path) => {
  const { CANARY_API_BASE, CANARY_API_KEY } = parse(
    fs.readFileSync(path, "utf-8"),
  );

  return {
    base: CANARY_API_BASE,
    key: CANARY_API_KEY,
  };
};

const forProd = () => {
  return {
    base: process.env.CANARY_API_BASE,
    key: process.env.CANARY_API_KEY,
  };
};
