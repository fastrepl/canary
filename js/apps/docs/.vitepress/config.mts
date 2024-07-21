import { fileURLToPath, URL } from "node:url";
import { defineConfig, type HeadConfig } from "vitepress";

import { COMPONENTS_VERSION } from "../shared.data";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  contentProps: { test: "test" },
  title: "Canary",
  description: "Canary",
  srcDir: "./contents",
  head: [
    "canary-styles-default",
    "canary-provider-mock",
    "canary-modal",
    "canary-trigger-searchbar",
    "canary-content",
    "canary-search",
    "canary-search-input",
    "canary-search-results",
    "canary-ask",
    "canary-ask-input",
    "canary-ask-results",
  ].map((tag) => [
    "script",
    {
      type: "module",
      src: `https://unpkg.com/@getcanary/web@${COMPONENTS_VERSION}/components/${tag}.js`,
    },
  ]),
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
      { text: "Docs", link: "/docs" },
      { text: "Blog", link: "/blog" },
      { text: "Cloud", link: "https://cloud.getcanary.dev" },
    ],
    sidebar: {
      "/docs/": [
        {
          text: "Guides",
          items: [
            { text: "Get Started", link: "/docs" },
            { text: "Concepts", link: "/docs/concepts" },
            { text: "Customization", link: "/docs/customization" },
            { text: "Analytics", link: "/docs/analytics" },
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
          text: "References",
          collapsed: true,
          items: [
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
