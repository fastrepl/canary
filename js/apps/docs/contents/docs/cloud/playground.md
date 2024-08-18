<script setup>
import { onMounted, computed, ref, watch } from "vue";

import StyleController from "../../../components/StyleController.vue";
import Markdown from "../../../components/Markdown.vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-pagefind.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-input.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-search-results-tabs.js"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

# Cloud Search Playground

::: info How does it work?

TODO

:::
