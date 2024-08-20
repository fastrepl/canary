<script setup lang="ts">
import { onMounted, ref } from "vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-mock.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-input.js"),
    import("@getcanary/web/components/canary-search-results-tabs.js"),
    import("@getcanary/web/components/canary-search-suggestions.js"),
    import("@getcanary/web/components/canary-ask.js"),
    import("@getcanary/web/components/canary-ask-input.js"),
    import("@getcanary/web/components/canary-ask-results.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const questions = [
  "How can I set a limit for API cost?",
  "What is the difference between API cost and API rate limit?",
];

const question = ref(questions[0]);
</script>

<template>
  <div class="my-2">
    <div class="flex flex-row gap-2 mb-4 text-xs">
      <button
        class="btn"
        v-on:click="question = q"
        :key="q"
        v-for="q in questions"
      >
        {{ q }}
      </button>
    </div>

    <canary-root
      framework="vitepress"
      v-if="loaded"
      :key="question"
      :query="question"
    >
      <canary-provider-mock>
        <canary-content>
          <canary-search slot="mode">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-suggestions slot="body"></canary-search-suggestions>
            <canary-search-results-tabs
              slot="body"
              tabs="Docs:*;API:/api/.+$"
            ></canary-search-results-tabs>
          </canary-search>
          <canary-ask slot="mode">
            <canary-mode-breadcrumb
              slot="input-before"
              previous="Search"
              text="Ask AI"
            ></canary-mode-breadcrumb>
            <canary-ask-input slot="input"></canary-ask-input>
            <canary-ask-results slot="body"></canary-ask-results>
          </canary-ask>
        </canary-content>
      </canary-provider-mock>
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
