import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vitepress";

const sidebar = [
  {
    text: "Common",
    items: [
      { text: "What is Canary?", link: "/" },
      { text: "Why use Canary?", link: "/docs/common/why" },
      {
        text: "Customization",
        collapsed: true,
        items: [
          {
            text: "Styling",
            link: "/docs/common/customization/styling",
          },
          {
            text: "Built-in components",
            link: "/docs/common/customization/builtin",
          },
          {
            text: "Custom components",
            link: "/docs/common/customization/custom",
          },
        ],
      },
      {
        text: "Guides",
        collapsed: true,
        items: [
          {
            text: "Spliting Tabs",
            link: "/docs/common/guides/spliting-tabs",
          },
          {
            text: "Conditional Callout",
            link: "/docs/common/guides/conditional-callout",
          },
          {
            text: "Custom Mode",
            link: "/docs/common/guides/custom-mode",
          },
        ],
      },
    ],
  },

  {
    text: "Local",
    items: [
      {
        text: "Introduction",
        link: "/docs/local/introduction",
      },
      {
        text: "Playground",
        link: "/docs/local/playground",
      },
      {
        text: "Integrations",
        collapsed: true,
        items: [
          {
            text: "Docusaurus",
            link: "/docs/local/integrations/docusaurus",
          },
          {
            text: "VitePress",
            link: "/docs/local/integrations/vitepress",
          },
          {
            text: "Starlight",
            link: "/docs/local/integrations/starlight",
          },
        ],
      },
    ],
  },
  {
    text: "Cloud",
    items: [
      {
        link: "/docs/cloud/intro",
        text: "Introduction",
      },
      {
        link: "/docs/cloud/playground",
        text: "Playground",
      },
      {
        text: "Integrations",
        collapsed: true,
        items: [
          {
            text: "Docusaurus",
            link: "/docs/cloud/integrations/docusaurus",
          },
          {
            text: "VitePress",
            link: "/docs/cloud/integrations/vitepress",
          },
          {
            text: "Starlight",
            link: "/docs/cloud/integrations/starlight",
          },
        ],
      },
      {
        text: "Features",
        collapsed: true,
        items: [
          {
            text: "Analytics",
            link: "/docs/cloud/features/analytics",
          },
        ],
      },
      {
        text: "Pricing",
        link: "/docs/cloud/pricing",
      },
    ],
  },
  {
    text: "Reference",
    items: [
      {
        text: "Packages",
        link: "/docs/reference/packages",
      },
    ],
  },
];

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Canary",
  description: "Canary",
  srcDir: "./contents",
  sitemap: { hostname: "https://getcanary.dev" },
  lastUpdated: true,
  markdown: {
    image: {
      lazyLoading: true,
    },
  },
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
        // {
        //   find: /^.*\/VPHome\.vue$/,
        //   replacement: fileURLToPath(
        //     new URL("../components/Home.vue", import.meta.url),
        //   ),
        // },
        {
          find: /^.*\/VPNavBarSearch\.vue$/,
          replacement: fileURLToPath(
            new URL("../components/LocalSearch.vue", import.meta.url),
          ),
        },
      ],
    },
  },
  themeConfig: {
    search: { provider: "local" },
    // https://vitepress.dev/reference/default-theme-config
    siteTitle: "🐤 Canary",
    nav: [
      {
        text: "📚 Storybook",
        link: "https://storybook.getcanary.dev",
      },
    ],
    sidebar: {
      "/": sidebar,
      "/docs/": sidebar,
    },
    outline: { level: [2, 3] },
    socialLinks: [
      { icon: "github", link: "https://github.com/fastrepl/canary" },
      { icon: "discord", link: "https://discord.gg/Y8bJkzuQZU" },
    ],
  },
});
