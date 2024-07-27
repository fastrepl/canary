<script setup lang="ts">
import { ref, onMounted } from "vue";

const loaded = ref(false);

onMounted(() => {
  const c1 = import("@getcanary/web/components/canary-root");
  const c2 = import("@getcanary/web/components/canary-provider-mock");
  const c3 = import("@getcanary/web/components/canary-content");
  const c4 = import("@getcanary/web/components/canary-search");
  const c5 = import("@getcanary/web/components/canary-search-input");
  const c6 = import("@getcanary/web/components/canary-search-results");
  const c7 = import("@getcanary/web/components/canary-ask");
  const c8 = import("@getcanary/web/components/canary-ask-input");
  const c9 = import("@getcanary/web/components/canary-ask-results");

  Promise.all([c1, c2, c3, c4, c5, c6, c7, c8, c9]).then(() => {
    loaded.value = true;
  });
});

import Hero from "./Hero.vue";
import Demo from "./Demo.vue";
// import Pricing from "./Pricing.vue";
</script>

<template>
  <canary-root framework="vitepress">
    <main class="flex flex-col items-center justify-center">
      <Hero />
      <Demo v-if="loaded" />
      <!-- <Pricing /> -->
    </main>
  </canary-root>
</template>
