<script setup lang="ts">
import { onMounted } from "vue";

onMounted(async () => {
  import("@getcanary/web/components/canary-styles-default");
  import("@getcanary/web/components/canary-provider-mock");
  import("@getcanary/web/components/canary-content");
  import("@getcanary/web/components/canary-search");
  import("@getcanary/web/components/canary-search-input");
  import("@getcanary/web/components/canary-search-results");
  import("@getcanary/web/components/canary-ask");
  import("@getcanary/web/components/canary-ask-input");
  import("@getcanary/web/components/canary-ask-results");
});

import Hero from "./Hero.vue";
import Demo from "./Demo.vue";
import Pricing from "./Pricing.vue";
</script>

<template>
  <canary-styles-default framework="vitepress">
    <main class="flex flex-col items-center justify-center">
      <Hero />
      <Demo />
      <Pricing />
    </main>
  </canary-styles-default>
</template>
