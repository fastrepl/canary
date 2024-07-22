<script setup lang="ts">
import { onMounted } from "vue";

onMounted(async () => {
  import("@getcanary/web/components/canary-styles-default");
  import("@getcanary/web/components/canary-provider-mock");
  import("@getcanary/web/components/canary-modal");
  import("@getcanary/web/components/canary-trigger-searchbar");
  import("@getcanary/web/components/canary-content");
  import("@getcanary/web/components/canary-search");
  import("@getcanary/web/components/canary-search-input");
  import("@getcanary/web/components/canary-search-results");
  import("@getcanary/web/components/canary-ask");
  import("@getcanary/web/components/canary-ask-input");
  import("@getcanary/web/components/canary-ask-results");
});
</script>

<template>
  <canary-styles-default theme="light">
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
  </canary-styles-default>
</template>
