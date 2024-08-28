<script setup lang="ts">
import { ref } from "vue";

const providers = ["local", "cloud"] as const;
const frameworks = ["docusaurus", "vitepress", "starlight"] as const;

const framework = ref<typeof frameworks[number]>("docusaurus");
const provider = ref<typeof providers[number]>("local");
</script>

# Quick Start

<span class="mt-12">WIP</span>

<div class="flex flex-col gap-4">
<div class="flex gap-2 items-center">
  <button
    v-for="f in frameworks"
    :class="{ tag: true, selected: framework === f }"
    @click="framework = f"
  >
    {{ f }}
  </button>
</div>

<div class="flex gap-2 items-center">
  <button
    v-for="p in providers"
    :class="{ tag: true, selected: provider === p }"
    @click="provider = p"
  >
    {{ p }}
  </button>
</div>
</div>

<style scoped>
button.tag {
  font-size: 0.875rem;
  border: 1px solid var(--vp-c-divider);
  padding: 4px 12px;
  border-radius: 1rem;
}
button.tag:hover {
  background-color: var(--vp-c-brand-soft);
  opacity: 0.8;
}

button.tag.selected {
  background-color: var(--vp-c-brand-soft);
}
</style>
