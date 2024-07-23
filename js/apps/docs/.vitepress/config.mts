import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vitepress";

import { COMPONENTS_VERSION } from "../shared.data";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Canary",
  description: "Canary",
  srcDir: "./contents",
  sitemap: { hostname: "https://getcanary.dev" },
  lastUpdated: true,
  vue: {
    template: {
      compilerOptions: {
        isCustomElement: (tag) => tag.includes("canary-"),
      },
    },
  },
  vite: {
    resolve: {
      alias: [
        {
          find: /^.*\/VPHome\.vue$/,
          replacement: fileURLToPath(
            new URL("../components/Home.vue", import.meta.url),
          ),
        },
      ],
    },
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    siteTitle: "🐤 Canary",
    nav: [
      { text: "Docs", link: "/docs/guide/what-is-canary.html" },
      { text: "Blog", link: "/blog" },
      {
        text: "Storybook",
        link: "https://storybook.getcanary.dev",
      },
      {
        text: "Playground",
        link: "https://stackblitz.com/edit/canary?file=index.html",
      },
      {
        text: "Cloud",
        link: "https://cloud.getcanary.dev",
      },
    ],
    sidebar: {
      "/docs/": [
        {
          text: "Introduction",
          items: [
            { text: "What is Canary?", link: "/docs/guide/what-is-canary" },
            { text: "Why use Canary?", link: "/docs/guide/why-use-canary" },
            { text: "Getting Started", link: "/docs/guide/getting-started" },
            { text: "Concepts", link: "/docs/guide/concepts" },
          ],
        },
        {
          text: "Integrations",
          items: [
            { text: "Docusaurus", link: "/docs/integrations/docusaurus" },
            { text: "Starlight", link: "/docs/integrations/starlight" },
            { text: "VitePress", link: "/docs/integrations/vitepress" },
          ],
        },
        {
          text: "Customization",
          items: [
            { text: "Compose Built-ins", link: "/docs/customization/compose" },
            { text: "Bring Your Own", link: "/docs/customization/byo" },
            { text: "Styling", link: "/docs/customization/styling" },
          ],
        },
        {
          text: "Miscellaneous",
          collapsed: true,
          items: [
            {
              text: "Optimizations",
              link: "/docs/miscellaneous/optimizations",
            },
          ],
        },
        {
          text: "References",
          collapsed: true,
          items: [
            {
              text: "Controllers",
              items: [
                {
                  text: "Operation",
                  link: "/docs/controllers/operation",
                },
                {
                  text: "Event",
                  link: "/docs/controllers/event",
                },
              ],
            },
            {
              text: "Components",
              items: [
                {
                  text: "Provider",
                  link: "/docs/components/provider",
                },
                {
                  text: "Styles",
                  link: "/docs/components/styles",
                },
                {
                  text: "Layout",
                  link: "/docs/components/layout",
                },
                {
                  text: "Search",
                  link: "/docs/components/search",
                },
                {
                  text: "Ask",
                  link: "/docs/components/ask",
                },
              ],
            },
          ],
        },
      ],
    },
    outline: { level: [2, 3] },
    socialLinks: [
      { icon: "github", link: "https://github.com/fastrepl/canary" },
      { icon: "discord", link: "https://discord.gg/Y8bJkzuQZU" },
    ],
  },
});
