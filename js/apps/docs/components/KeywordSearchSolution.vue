<script setup lang="ts">
import { onMounted, ref } from "vue";
import { data } from "../data/url_cloud.data.js";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-cloud.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-input.js"),
    import("@getcanary/web/components/canary-search-results.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const questions = ["provider", "how to switch provider"];

const question = ref(questions[0]);
const counter = ref(0);

const handleSelect = (q: string) => {
  question.value = q;
  counter.value += 1;
}
</script>

<template>
  <div class="my-2">
    <div class="flex flex-row gap-2 mb-4 text-xs">
      <button
        class="btn"
        v-on:click="handleSelect(q)"
        :key="q"
        v-for="q in questions"
      >
        {{ q }}
      </button>
    </div>

    <canary-root
      framework="vitepress"
      v-if="loaded"
      :key="counter"
      :query="question"
    >
      <canary-provider-cloud :api-key="data.key" :api-base="data.base">
        <canary-content>
          <canary-search slot="mode">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="body"></canary-search-results>
          </canary-search>
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
