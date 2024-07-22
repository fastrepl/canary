import DefaultTheme from "vitepress/theme";
import { inject } from "@vercel/analytics";

import "./tailwind.css";

/** @type {import('vitepress').Theme} */
export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    inject();
  },
};
