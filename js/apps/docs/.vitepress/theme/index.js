import DefaultTheme from "vitepress/theme";
import { inject } from "@vercel/analytics";

/** @type {import('vitepress').Theme} */
export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    inject();
  },
};
