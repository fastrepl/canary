<script setup lang="ts">
import { onMounted, computed, ref, watch } from "vue";

import Markdown from "../../../components/Markdown.vue";

const sources = ["litellm", "mistral", "prisma"] as const;
const source = ref<(typeof sources)[number]>(sources[0]);

const sourceData: Record<typeof sources, any> = {
  litellm: {
    base: "https://docs.litellm.ai",
    replace: "/static/litellm",
  },
  mistral: {
    base: "https://docs.mistral.ai",
    replace: "/static/mistral",
  },
  prisma: {
    base: "https://prisma.io/docs",
    replace: "/static/prisma",
  },
};

const globs = computed(() => {
  if (source.value === "litellm") {
    return [
      { name: "All", pattern: "**/*" },
      { name: "Proxy", pattern: "**/proxy/**" }
    ];
  }

  if (source.value === "mistral") {
    return [
      { name: "All", pattern: "**/*" },
      { name: "Guide", pattern: "**/guides/**" }
    ];
  }

  if (source.value === "prisma") {
    return [
      { name: "All", pattern: "**/*" }, 
      { name: "ORM", pattern: "**/orm/**" }, 
      { name: "Accelerate", pattern: "**/accelerate/**" }, 
      { name: "Pulse", pattern: "**/pulse/**" }
    ];
  }

  throw new Error();
});


const pagefindOptions = computed(() => ({
  _base: sourceData[source.value].base,
  _replace: sourceData[source.value].replace,
  path: `https://hosted-pagefind.pages.dev/static/${source.value}/pagefind/pagefind.js`,
}));


const tabs = ["UI", "Code"] as const;
const tab = ref(tabs[0]);

watch(source, () => {
  tab.value = tabs[0];
});

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-pagefind.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-filter-tabs-glob.js"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

# Local Search Demo

`🐤 Canary X Pagefind` for `Litellm`, `Mistral`, and `Prisma`.

::: warning

**We are not affiliated** with any of the projects listed here, and the list might change over time.

This is only for demo purposes.

:::

::: details How does it work?

1. Use [`@getcanary/docusaurus-theme-search-pagefind`](/docs/local/integrations/docusaurus.html#one-step-to-integrate) to create Pagefind index.
2. [Serve it](https://github.com/fastrepl/hosted-pagefind/tree/main/public/static) using Cloudflare Pages.
3. Use [`canary-provider-pagefind`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/components/canary-provider-pagefind.ts) to load the index, and build UI using `@getcanary/web`.

:::

::: details Where did the source come from?

- [docs.litellm.ai](https://docs.litellm.ai)
- [docs.mistral.ai](https://docs.mistral.ai)
- [prisma.io/docs](https://prisma.io/docs)

:::

::: details What is `provider`?

`Provider` registers operations like `search`.

You can swap out the provider and keep the same UI.

Click **Code** tab to read the code.

:::

<div class="flex flex-col gap-4 mt-6">
  <div class="flex gap-2 items-center">
    <button
      v-for="current in sources"
      :class="{ tag: true, selected: source === current }"
      @click="source = current"
    >
      {{ current }}
    </button>
  </div>
</div>

<div class="container flex flex-col gap-2 mt-6" v-if="loaded">
  <div class="flex gap-2 text-sm font-semibold">
    <button
      v-for="current in tabs"
      class="hover:underline"
      :class="{ underline: tab === current }"
      @click="tab = current"
    >
      {{ current }}
    </button>
  </div>

  <canary-root framework="vitepress" :key="source" :query="source" v-show="tab === 'UI'">
    <canary-provider-pagefind :options="pagefindOptions">
      <canary-content>
        <canary-input slot="input"></canary-input>
        <canary-search slot="mode">
          <canary-filter-tabs-glob slot="head" :tabs="globs"></canary-filter-tabs-glob>
          <canary-search-results slot="body">
          </canary-search-results>
        </canary-search>
      </canary-content>
    </canary-provider-pagefind>
  </canary-root>

  <template v-if="mode === 'Code'">

  <Markdown>

```html-vue{4-7}
<canary-root framework="vitepress">
  <canary-provider-pagefind options={JSON.stringify(options)}>
    <canary-content>
      <canary-input slot="input"></canary-input>
      <canary-search slot="mode">
        <canary-search-results slot="body"></canary-search-results>
      </canary-search>
    </canary-content>
  </canary-provider-pagefind>
</canary-root>
```

  </Markdown>

  </template>
</div>

<style scoped>
.container {
  height: 500px;
}

button.tag {
  font-size: 0.875rem;
  border: 1px solid var(--vp-c-divider);
  padding: 4px 12px;
  border-radius: 1rem;
}
button.tag:hover {
  background-color: var(--vp-c-brand-soft);
  opacity: 0.8;
}

button.tag.selected {
  background-color: var(--vp-c-brand-soft);
}

canary-root {
  --canary-content-max-width: 690px;
  --canary-content-max-height: 400px;
}
</style>
