<script setup lang="ts">
import { onMounted, ref } from "vue";

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
      <canary-feedback-page></canary-feedback-page>
    </canary-styles>
  </div>
</template>
