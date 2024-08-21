<script setup lang="ts">
import { onMounted, ref } from "vue";
import { data } from "../data/url_cloud.data.js";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-styles.js"),
    import("@getcanary/web/components/canary-feedback-page.js"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

<template>
  <div class="flex justify-center items-center" v-if="loaded">
    <canary-styles framework="vitepress">
      <canary-feedback-page :api-base="data.base" :api-key="data.key">
      </canary-feedback-page>
    </canary-styles>
  </div>
</template>
