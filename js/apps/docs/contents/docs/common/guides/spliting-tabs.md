<script setup lang="ts">
  import { ref, computed } from 'vue'
  import { parseTabs } from '@getcanary/web/parsers/index.js'

  RegExp.prototype.toJSON = RegExp.prototype.toString;
  const pattern = ref("All:*;API:/api/.+$")
  const result = computed(() => JSON.stringify(parseTabs(pattern.value), null, 2))
</script>

# Spliting Tabs

```html-vue
<canary-search slot="mode">
  <canary-search-results slot="body"></canary-search-results> // [!code --]
  <canary-search-results-tabs tabs="{{ pattern }}" slot="body">  // [!code ++]
  </canary-search-results-tabs>  // [!code ++]
</canary-search>
```

<div class="flex flex-row gap-2 mt-6">
  <label>tabs =</label>
  <input type="text" v-model="pattern" />
</div>

Above pattern is [parsed](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/parsers/tabs.peggy) to below:

```json-vue
{{ result }}
```

`pattern` is a `RegExp | null`, and `null` matches to any URL.

<style scoped>
  label {
    padding-top: 4px;
  }

  input {
    border: 1px solid var(--vp-c-text-3);
    border-radius: 6px;
    padding: 2px 4px;
  }
</style>
