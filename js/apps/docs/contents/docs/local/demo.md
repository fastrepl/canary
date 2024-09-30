<script setup lang="ts">
import { onMounted, computed, ref, watch } from "vue";

import Radio from "../../../components/Radio.vue";
import Tabs from "../../../components/Tabs.vue";
import ButtonGroup from "../../../components/ButtonGroup.vue";
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

const question = ref("");
const questions = ref([]);

watch(source, () => {
  if (source.value === "litellm") {
    question.value = "litellm";
    questions.value = [
      "litellm",
      "rate"
    ];
  }

  if (source.value === "mistral") {
    question.value = "mistral";
    questions.value = [
      "mistral"
    ];
  }

  if (source.value === "prisma") {
    question.value = "prisma";
    questions.value = [
      "prisma"
    ];
  }
}, { immediate: true });
</script>

# Local Search Demo

::: tip INFO

**We are not affiliated** with any of the projects listed here, and the list might change over time.

:::

::: details How does it work?

1. Use [`@getcanary/docusaurus-theme-search-pagefind`](/docs/local/integrations/docusaurus.html#one-step-to-integrate) to create Pagefind index.
2. [Serve it](https://github.com/fastrepl/hosted-pagefind/tree/main/public/static) using Cloudflare Pages.
3. Use [`canary-provider-pagefind`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/components/canary-provider-pagefind.ts) to load the index, and build UI using `@getcanary/web`.

:::

<div class="mt-6 flex flex-col gap-2">
  <hr class="my-1" />
  <div class="flex flex-row gap-4 items-center">
    <span class="text-sm font-semibold">Sources</span>
    <Radio :values="sources" :selected="source" @update:selected="source = $event" />
  </div>
  <hr class="my-1" />
  <div class="flex flex-row gap-4 items-center">
    <span class="text-sm font-semibold">Examples</span>
    <ButtonGroup :values="questions" @update:selected="question = $event" />
  </div>
  <hr class="my-1" />
</div>

<div class="container flex flex-col gap-2 mt-4" v-if="loaded">
  <Tabs :values="tabs" :selected="tab" @update:selected="tab = $event" />

  <canary-root framework="vitepress" :key="question" :query="question" v-show="tab === 'UI'">
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

  <template v-if="tab === 'Code'">

  <Markdown>

```html-vue{5-8}
<canary-root framework="vitepress">
  <canary-provider-pagefind options={JSON.stringify(options)}>
    <canary-content>
      <canary-input slot="input"></canary-input>
      <canary-search slot="mode">
        <canary-filter-tabs-glob slot="head" tabs={JSON.stringify(tabs)}></canary-filter-tabs-glob>
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

canary-root {
  --canary-content-max-width: 690px;
  --canary-content-max-height: 400px;
}
</style>
