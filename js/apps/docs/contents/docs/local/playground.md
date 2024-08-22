<script setup lang="ts">
import { onMounted, computed, ref, watch } from "vue";

import StyleController from "../../../components/StyleController.vue";
import Markdown from "../../../components/Markdown.vue";

const modes = ["UI", "Code"] as const;
const mode = ref(modes[0]);

const sources = ["litellm", "mistral", "prisma"] as const;
const source = ref<(typeof sources)[number]>(sources[0]);

const configData: Record<typeof sources, any> = {
  litellm: {
    variants: ["basic", "group", "split"],
    pattern: "All:*;Proxy:/proxy/.+$",
    base: "https://docs.litellm.ai",
    replace: "/static/litellm",
  },
  mistral: {
    variants: ["basic", "group"],
    pattern: "All:*;API:/api/.+$",
    base: "https://docs.mistral.ai",
    replace: "/static/mistral",
  },
  prisma: {
    variants: ["basic", "group", "split"],
    pattern: "All:*;ORM:/orm/.+$;Accelerate:/accelerate/.+$;Pulse:/pulse/.+$",
    base: "https://prisma.io/docs",
    replace: "/static/prisma",
  },
};

const pattern = computed(() => configData[source.value].pattern);
const variants = computed(() => configData[source.value].variants);
const variant = ref(variants.value[0]);

const baseUrl = "https://hosted-pagefind.pages.dev";
const options = computed(() => ({
  _base: configData[source.value].base,
  _replace: configData[source.value].replace,
  path: `${baseUrl}/static/${source.value}/pagefind/pagefind.js`,
}));

watch(source, () => {
  mode.value = modes[0];
  if (!variants.value.includes(variant.value)) {
    variant.value = variants.value[0];
  }
});

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-pagefind.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-input.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-search-results-tabs.js"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

# Local Search Playground

::: info How does it work?

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
    <span class="text-sm">Source</span>
    <button
      v-for="current in sources"
      :class="{ tag: true, selected: source === current }"
      @click="source = current"
    >
      {{ current }}
    </button>
  </div>

  <div class="flex gap-2 items-center">
    <span class="text-sm">Variant</span>
    <button
      v-for="current in variants"
      :class="{ tag: true, selected: variant === current }"
      @click="variant = current"
    >
      {{ current }}
    </button>
  </div>

  <div class="flex gap-2">
    <span class="text-sm">Color</span>
    <StyleController :selector="`canary-root`" />
  </div>
</div>

<div class="container flex flex-col gap-2 mt-6" v-if="loaded">
  <div class="flex gap-2 text-sm font-semibold">
    <button
      v-for="current in modes"
      class="hover:underline"
      :class="{ underline: mode === current }"
      @click="mode = current"
    >
      {{ current }}
    </button>
  </div>

  <canary-root framework="vitepress" :key="source" :query="source" v-show="mode === 'UI'">
    <canary-provider-pagefind :options="options" base="https://docs.litellm.ai">
      <canary-content>
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="body" :group="variant === 'group'" v-if="variant !== 'split'">
          </canary-search-results>
          <canary-search-results-tabs slot="body" :tabs="pattern" v-if="variant === 'split'">
          </canary-search-results-tabs>
        </canary-search>
      </canary-content>
    </canary-provider-pagefind>
  </canary-root>

  <Markdown v-if="mode === 'Code' && variant === 'basic'">

```html-vue{4-7}
<canary-root framework="vitepress">
   <canary-provider-pagefind options={JSON.stringify(options)}>
      <canary-content>
         <canary-search slot="mode">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="body"></canary-search-results>
         </canary-search>
      </canary-content>
   </canary-provider-pagefind>
</canary-root>
```

  </Markdown>

  <Markdown v-if="mode === 'Code' && variant === 'group'">

```html-vue{4-7}
<canary-root framework="vitepress">
   <canary-provider-pagefind options={JSON.stringify(options)}>
      <canary-content>
         <canary-search slot="mode">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="body"></canary-search-results>  // [!code --]
            <canary-search-results slot="body" group></canary-search-results> // [!code ++]
         </canary-search>
      </canary-content>
   </canary-provider-pagefind>
</canary-root>
```

   </Markdown>

  <Markdown v-if="mode === 'Code' && variant === 'split'">

```html-vue{4-7}
<canary-root framework="vitepress">
   <canary-provider-pagefind options={JSON.stringify(options)}>
      <canary-content>
         <canary-search slot="mode">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="body"></canary-search-results>  // [!code --]
            <canary-search-results-tabs tabs="{{ pattern }}" slot="body"></canary-search-results-tabs>  // [!code ++]
         </canary-search>
      </canary-content>
   </canary-provider-pagefind>
</canary-root>
```

   </Markdown>
</div>

<!-- ## Looking for a better search experience?

Local search is awesome, but we believe there's lots of room for improvement. Head over to our other
[Playground](/docs/cloud/playground) to try out features that we are excited about. -->

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
}

button.tag.selected {
  background-color: var(--vp-c-brand-soft);
}

canary-root {
  --canary-content-max-width: 690px;
  --canary-content-max-height: 400px;
}
</style>
