<script setup lang="ts">
import { onMounted, ref } from "vue";

import { data } from "@data/url_cloud.data";
import ButtonGroup from "@components/ButtonGroup.vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-cloud.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-search-suggestions.js"),
    import("@getcanary/web/components/canary-ask.js"),
    import("@getcanary/web/components/canary-ask-results.js"),
    import("@getcanary/web/components/canary-filter-tabs-glob.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const sources = ["canary_webpage"];

const tabs = JSON.stringify([
  { name: "All", pattern: "**/*" },
  { name: "Local", pattern: "**/local/**" },
  { name: "Cloud", pattern: "**/cloud/**" },
]);

const questions = [
  "css variable for changing hue?",
  "how to generate pagefind index in docusaurus?",
];

const question = ref(questions[0]);
const counter = ref(0);

const handleSelect = (q: string) => {
  question.value = q;
  counter.value += 1;
};
</script>

<template>
  <div class="my-2">
    <div class="my-2">
      <ButtonGroup :values="questions" @update:selected="handleSelect" />
    </div>

    <canary-root
      framework="vitepress"
      v-if="loaded"
      :key="counter"
      :query="question"
    >
      <canary-provider-cloud
        :project-key="data.key"
        :api-base="data.base"
        :sources="sources"
      >
        <canary-content>
          <canary-input slot="input"></canary-input>
          <canary-search slot="mode">
            <canary-search-suggestions slot="head"></canary-search-suggestions>
            <canary-filter-tabs-glob
              slot="head"
              :tabs="tabs"
            ></canary-filter-tabs-glob>
            <canary-search-results slot="body"></canary-search-results>
          </canary-search>
          <canary-ask slot="mode">
            <canary-mode-breadcrumb
              slot="input-before"
              text="Ask AI"
            ></canary-mode-breadcrumb>
            <canary-ask-results slot="body"></canary-ask-results>
          </canary-ask>
        </canary-content>
      </canary-provider-cloud>
    </canary-root>
  </div>
</template>

<style scoped>
.btn {
  padding: 2px 8px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background-color: var(--vp-c-bg);
  color: var(--vp-c-text-1);

  max-width: 130px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.btn:hover {
  background-color: var(--vp-c-brand-soft);
}

canary-root {
  --canary-content-max-width: 650px;
  --canary-content-max-height: 300px;
  --canary-color-primary-c: 0.05;
  --canary-color-primary-h: 90;
}
</style>
