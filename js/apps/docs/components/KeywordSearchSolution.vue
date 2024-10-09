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
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search-results.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const sources = ["canary_webpage"];
const questions = ["how to change overall mood?", "dddoccsarusaurs supported?"];

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
        :api-key="data.key"
        :api-base="data.base"
        :sources="sources"
      >
        <canary-content>
          <canary-input slot="input"></canary-input>
          <canary-search slot="mode">
            <canary-search-results slot="body"></canary-search-results>
          </canary-search>
        </canary-content>
      </canary-provider-cloud>
    </canary-root>
  </div>
</template>

<style scoped>
canary-root {
  --canary-content-max-width: 650px;
  --canary-content-max-height: 300px;
  --canary-color-primary-c: 0.05;
  --canary-color-primary-h: 90;
}
</style>
