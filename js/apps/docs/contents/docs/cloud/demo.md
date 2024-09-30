<script setup>
import { onMounted, computed, ref, watch } from "vue";

import StyleController from "../../../components/StyleController.vue";
import Markdown from "../../../components/Markdown.vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

# Cloud Search Demo

::: warning

**We are not affiliated** with any of the projects listed here, and the list might change over time.

This is only for demo purposes.

:::
