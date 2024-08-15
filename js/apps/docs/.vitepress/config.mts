import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vitepress";

const sidebar = [
  {
    text: "Integrations",
    items: [
      { text: "Docusaurus", link: "/docs/integrations/docusaurus" },
      { text: "VitePress", link: "/docs/integrations/vitepress" },
      { text: "Starlight", link: "/docs/integrations/starlight" },
    ],
  },
  {
    text: "Customization",
    items: [
      { text: "Styling", link: "/docs/customization/styling" },
      {
        text: "Built-in components",
        link: "/docs/customization/builtin",
      },
      { text: "Custom components", link: "/docs/customization/custom" },
    ],
  },
  {
    text: "Canary Cloud",
    items: [
      {
        text: "Introduction",
        link: "/docs/cloud/intro",
      },
      {
        text: "Integrations",
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
        text: "Analytics",
        link: "/docs/cloud/analytics",
      },
      {
        text: "Miscellaneous",
        link: "/docs/cloud/miscellaneous",
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
      {
        text: "🛹 Playground",
        link: "https://stackblitz.com/edit/canary?file=index.html",
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
