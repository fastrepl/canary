import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vitepress";
import unocss from "unocss/vite";
import footnote from "markdown-it-footnote";

const DISCORD_URL = "https://discord.gg/Y8bJkzuQZU";

const sidebar = [
  {
    text: "Start Here",
    items: [
      { text: "What is Canary?", link: "/" },
      { text: "Why use Canary?", link: "/docs/why" },
    ],
  },
  {
    text: "Common",
    items: [
      {
        text: "Customization",
        collapsed: true,
        items: [
          {
            text: "Styling",
            link: "/docs/common/customization/styling",
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
            text: "Filtering",
            link: "/docs/common/guides/filtering",
          },
          {
            text: "Conditional Callout",
            link: "/docs/common/guides/conditional-callout",
          },
        ],
      },
    ],
  },
  {
    text: "Local",
    items: [
      {
        text: "Demo",
        link: "/docs/local/demo",
      },
      {
        text: "Introduction",
        link: "/docs/local/intro",
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
            text: "Astro",
            link: "/docs/local/integrations/astro",
          },
          {
            text: "Starlight",
            link: "/docs/local/integrations/starlight",
          },
          {
            text: "Nextra",
            link: "/docs/local/integrations/nextra",
          },
        ],
      },
    ],
  },
  {
    text: "Cloud",
    items: [
      {
        text: "Demo",
        link: "/docs/cloud/demo",
      },
      {
        text: "Introduction",
        link: "/docs/cloud/intro",
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
            text: "Astro",
            link: "/docs/cloud/integrations/astro",
          },
          {
            text: "Starlight",
            link: "/docs/cloud/integrations/starlight",
          },
          {
            text: "Nextra",
            link: "/docs/cloud/integrations/nextra",
          },
        ],
      },
      {
        text: "Platform",
        collapsed: true,
        items: [
          {
            text: "Pricing",
            link: "/docs/cloud/platform/pricing",
          },
          {
            text: "Manual",
            link: "/docs/cloud/platform/manual",
          },
          {
            text: "Self-host",
            link: "/docs/cloud/platform/self-host",
          },
        ],
      },
    ],
  },
  {
    text: "Reference",
    collapsed: false,
    items: [
      {
        text: "@getcanary/docusa...",
        link: "/docs/reference/docusaurus",
      },
      {
        text: "@getcanary/web",
        link: "/docs/reference/web",
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
    config: (md) => {
      md.use(footnote);
    },
    image: {
      lazyLoading: true,
    },
  },
  transformPageData(pageData) {
    const canonicalUrl = `https://getcanary.dev/${pageData.relativePath}`
      .replace(/index\.md$/, "")
      .replace(/\.md$/, ".html");

    pageData.frontmatter.head ??= [];
    pageData.frontmatter.head.push(
      ["link", { rel: "canonical", href: canonicalUrl }],
      [
        "meta",
        {
          name: "og:title",
          content:
            pageData.frontmatter.layout === "home"
              ? `Canary`
              : `${pageData.title} | Canary`,
        },
      ],
      [
        "meta",
        {
          name: "og:description",
          content:
            pageData.frontmatter.layout === "home"
              ? "Searchbar that your users love to use. Optimized for technical docs with AI."
              : pageData.frontmatter.description,
        },
      ],
      [
        "meta",
        {
          name: "twitter:title",
          content:
            pageData.frontmatter.layout === "home"
              ? `Canary`
              : `${pageData.title} | Canary`,
        },
      ],
      [
        "meta",
        {
          name: "twitter:description",
          content:
            pageData.frontmatter.layout === "home"
              ? "Searchbar that your users love to use. Optimized for technical docs with AI."
              : pageData.frontmatter.description,
        },
      ],
    );
  },
  vue: {
    template: {
      compilerOptions: {
        isCustomElement: (tag) => tag.includes("canary-"),
      },
    },
  },
  vite: {
    plugins: [unocss()],
    resolve: {
      alias: [
        {
          find: "@components",
          replacement: fileURLToPath(new URL("../components", import.meta.url)),
        },
        {
          find: "@data",
          replacement: fileURLToPath(new URL("../data", import.meta.url)),
        },
      ],
    },
    ssr: {
      noExternal: ["@nolebase/vitepress-plugin-highlight-targeted-heading"],
    },
    server: {
      proxy: {
        "/discord": {
          target: DISCORD_URL,
          changeOrigin: true,
        },
      },
    },
  },
  themeConfig: {
    // search: { provider: "local" },
    // https://vitepress.dev/reference/default-theme-config
    siteTitle: "🐤 Canary",
    nav: [
      { text: "💡 Blog", link: "/blog" },
      {
        text: "⭐ GitHub",
        link: "https://github.com/fastrepl/canary",
      },
      {
        text: "💬 Discord",
        link: DISCORD_URL,
      },
      {
        text: "🐤 Cloud",
        link: "https://cloud.getcanary.dev",
      },
    ],
    sidebar: {
      "/": sidebar,
      "/docs/": sidebar,
    },
    outline: { level: [2, 3] },
    editLink: {
      pattern:
        "https://github.com/fastrepl/canary/edit/main/js/apps/docs/contents/:path",
    },
  },
});
