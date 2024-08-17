<script setup lang="ts">
import { onMounted, computed, ref, watch } from "vue";

import StyleController from "../../../components/StyleController.vue";
import Markdown from "../../../components/Markdown.vue";

const loaded = ref(false);

const tabs = ["UI", "Code"] as const;
const mode = ref(tabs[0]);

const names = ["litellm", "mistral", "prisma"] as const;
const name = ref<(typeof names)[number]>(names[0]);

const variants = computed(() => {
  const data: Record<(typeof names)[number], string[]> = {
    litellm: ["basic", "group", "split"],
    mistral: ["basic", "group"],
    prisma: ["basic", "group", "split"],
  };

  return data[name.value];
});

const pattern = computed(() => {
  const data: Record<(typeof names)[number], string> = {
    litellm: "SDK:*;Proxy:/proxy/.+$",
    mistral: "Docs:*;API:/api/.+$",
    prisma: "Docs:*;ORM:/orm/.+$;Accelerate:/accelerate/.+$;Pulse:/pulse/.+$",
  };

  return data[name.value];
});

const variant = ref(variants.value[0]);
watch(name, () => {
  mode.value = tabs[0];
  if (!variants.value.includes(variant.value)) {
    variant.value = variants.value[0];
  }
});

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

const baseUrl = "https://hosted-pagefind.pages.dev";
const options = computed(() => ({
  path: `${baseUrl}/static/${name.value}/pagefind/pagefind.js`,
}));

const test = "123"
</script>

# Playground

::: info How does it work?

1. Use [`@getcanary/docusaurus-theme-search-pagefind`](/docs/local/integrations/docusaurus.html#one-step-to-integrate) to create Pagefind index.
2. Serve it using [Cloudflare Pages](https://github.com/fastrepl/hosted-pagefind/tree/main/public/static).
3. Use [`canary-provider-pagefind`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/components/canary-provider-pagefind.ts) to load the index, and build UI using `@getcanary/web`.

:::

::: details Where did the source come from?

- [docs.litellm.ai](https://docs.litellm.ai)
- [docs.mistral.ai](https://docs.mistral.ai)
- [prisma.io/docs](https://prisma.io/docs)

:::

<div class="flex flex-col gap-4 mt-6">
  <div class="flex gap-2 items-center">
    <span class="text-sm">Source</span>
    <button
      v-for="current in names"
      :class="{ tag: true, selected: name === current }"
      @click="name = current"
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

<div class="flex flex-col gap-2 mt-6 h-[500px]" v-if="loaded">
  <div class="flex gap-2 text-sm font-semibold">
    <button
      v-for="current in tabs"
      class="hover:underline"
      :class="{ underline: mode === current }"
      @click="mode = current"
    >
      {{ current }}
    </button>
  </div>

  <canary-root framework="vitepress" :key="name" :query="name" v-show="mode === 'UI'">
    <canary-provider-pagefind :options="options">
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
   <canary-provider-pagefind>
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
   <canary-provider-pagefind>
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
   <canary-provider-pagefind>
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

<style scoped>
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
