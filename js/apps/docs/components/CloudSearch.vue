<script setup lang="ts">
import { onMounted, ref } from "vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root"),
    import("@getcanary/web/components/canary-provider-mock"),
    import("@getcanary/web/components/canary-modal"),
    import("@getcanary/web/components/canary-trigger-searchbar"),
    import("@getcanary/web/components/canary-content"),
    import("@getcanary/web/components/canary-search"),
    import("@getcanary/web/components/canary-search-input"),
    import("@getcanary/web/components/canary-search-results"),
    import("@getcanary/web/components/canary-ask"),
    import("@getcanary/web/components/canary-ask-input"),
    import("@getcanary/web/components/canary-ask-results"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

<template>
  <div class="w-full max-w-[230px] pl-4 mr-auto" v-if="loaded">
    <canary-root framework="vitepress">
      <canary-provider-mock>
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-search slot="search">
              <canary-search-input slot="input"></canary-search-input>
              <canary-search-results slot="results"></canary-search-results>
            </canary-search>
            <canary-ask slot="ask">
              <canary-ask-input slot="input"></canary-ask-input>
              <canary-ask-results slot="results"></canary-ask-results>
            </canary-ask>
          </canary-content>
        </canary-modal>
      </canary-provider-mock>
    </canary-root>
  </div>
</template>
