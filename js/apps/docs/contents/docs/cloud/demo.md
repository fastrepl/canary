<script setup lang="ts">
import { onMounted, computed, ref, watch } from "vue";

import { data } from "../../../data/url_cloud.data.js";

import Radio from "../../../components/Radio.vue";
import Tabs from "../../../components/Tabs.vue";
import ButtonGroup from "../../../components/ButtonGroup.vue";
import Markdown from "../../../components/Markdown.vue";

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

const sourceGroups = ["canary", "dspy"] as const;
const sourceGroup = ref<(typeof sourceGroups)[number]>(sourceGroups[0]);

const sourceNames = computed(() => {
  if (sourceGroup.value === "canary") {
    return ["canary_webpage", "canary_issue"];
  }

  if (sourceGroup.value === "dspy") {
    return ["dspy_webpage", "dspy_issue", "dspy_discussion"];
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
});

const question = ref("");
const questions = ref([]);

watch(sourceGroup, () => {
  if (sourceGroup.value === "canary") {
    question.value = "vite";
    questions.value = [
      "api-base",
      "vitepress supported?",
      "how to change overall mood?",
      "code example for changing hue?",
    ];
  }

  if (sourceGroup.value === "dspy") {
    question.value = "dspy";
    questions.value = [
      "dspy"
    ];
  }
}, { immediate: true });
</script>

# Cloud Search Demo

::: tip INFO

**We are not affiliated** with any of the projects listed here, and the list might change over time.

:::

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
</div>

<style scoped>
canary-root {
  --canary-content-max-width: 690px;
  --canary-content-max-height: 400px;
}
</style>
