<script setup lang="ts">
import { onMounted, computed, ref, watch } from "vue";

import { data } from "../../../data/url_cloud.data.js";

import Radio from "../../../components/Radio.vue";
import Tabs from "../../../components/Tabs.vue";
import ButtonGroup from "../../../components/ButtonGroup.vue";
import Markdown from "../../../components/Markdown.vue";
import Video from "../../../components/Video.vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-cloud.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-callout-discord.js"),
    import("@getcanary/web/components/canary-ask.js"),
    import("@getcanary/web/components/canary-ask-results.js"),
    import("@getcanary/web/components/canary-mode-breadcrumb.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const sourceGroups = ["canary", "dspy", "hono"] as const;
const sourceGroup = ref<(typeof sourceGroups)[number]>(sourceGroups[0]);

const sourceNames = computed(() => {
  if (sourceGroup.value === "canary") {
    return ["canary_webpage", "canary_issue"];
  }

  if (sourceGroup.value === "dspy") {
    return ["dspy_webpage", "dspy_issue", "dspy_discussion"];
  }

  if (sourceGroup.value === "hono") {
    return ["hono_webpage", "hono_issue"];
  }

  throw new Error();
});

const tabs = ["UI", "Code"] as const;
const tab = ref(tabs[0]);

watch(sourceGroup, () => {
  tab.value = tabs[0];
});

const globs = computed(() => {
  if (sourceGroup.value === "canary") {
    return JSON.stringify([
      { name: "Docs", pattern: "**/docs/**/*" },
      { name: "Github", pattern: "github.com/**/*" },
    ]);
  }

  if (sourceGroup.value === "dspy") {
    return JSON.stringify([
      { name: "Docs", pattern: "**/docs/**/*" },
      { name: "API", pattern: "**/api/**" },
      { name: "Github", pattern: "**/github.com/**" },
    ]);
  }

  if (sourceGroup.value === "hono") {
    return JSON.stringify([
      { name: "Docs", pattern: "**/docs/**/!(api)/**/*" },
      { name: "API", pattern: "**/docs/api/**" },
      { name: "Github", pattern: "**/github.com/**" },
    ]);
  }
});

const question = ref("");
const questions = ref([]);

watch(sourceGroup, () => {
  if (sourceGroup.value === "canary") {
    question.value = "vite";
    questions.value = [
      "api-base",
      "vitepress supported?",
      "css variable for changing hue?",
    ];
  }

  if (sourceGroup.value === "dspy") {
    question.value = "dspy";
    questions.value = [
      "colbert",
      "filtering in retrieval?",
      "what is mi..ppro?",
      "built-in datasets list"
    ];
  }

    if (sourceGroup.value === "hono") {
    question.value = "hono";
    questions.value = [
      "middleware",
      "can i deploy to cloudflare?",
      "validate Content-Type not supported? not working",
    ];
  }
}, { immediate: true });
</script>

# Cloud Search Demo

::: tip INFO

**We are not affiliated** with any of the projects listed here, and the list might change over time.

:::

<Video id="hQVTgrdDzmoDOvrbpQdivP8IRUe5pqaXmnqgnTudGOQ" />

<div class="mt-6 flex flex-col gap-2">
  <hr class="my-1" />
  <div class="flex flex-row gap-4 items-center">
    <span class="text-sm font-semibold">Sources</span>
    <Radio :values="sourceGroups" :selected="sourceGroup" @update:selected="sourceGroup = $event" />
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
    <canary-provider-cloud :api-base="data.base" :api-key="data.key" :sources="sourceNames">
      <canary-content>
        <canary-input slot="input"></canary-input>
        <canary-search slot="mode">
          <canary-filter-tabs-glob slot="head" :tabs="globs"></canary-filter-tabs-glob>
          <canary-search-results slot="body"></canary-search-results>
        </canary-search>
        <canary-ask slot="mode">
          <canary-ask-results slot="body"></canary-ask-results>
        </canary-ask>
      </canary-content>
    </canary-provider-cloud>
  </canary-root>

  <template v-if="tab === 'Code'">

  <Markdown>

```html-vue{5-11}
<canary-root framework="vitepress">
  <canary-provider-cloud api-base="<API_BASE>" api-key="<API_KEY>">
    <canary-content>
      <canary-input slot="input"></canary-input>
      <canary-search slot="mode">
        <canary-filter-tabs-glob slot="head" tabs={JSON.stringify(tabs)}></canary-filter-tabs-glob>
        <canary-search-results slot="body"></canary-search-results>
      </canary-search>
      <canary-ask slot="mode">
        <canary-ask-results slot="body"></canary-ask-results>
      </canary-ask>
    </canary-content>
  </canary-provider-cloud>
</canary-root>
```

  </Markdown>

  </template>
</div>

<style scoped>
canary-root {
  --canary-content-max-width: 690px;
  --canary-content-max-height: 500px;
}
</style>
