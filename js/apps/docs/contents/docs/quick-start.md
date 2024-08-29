<script setup lang="ts">
import { ref, computed } from "vue";

const providers = ["Local", "Cloud"] as const;
const frameworks = ["Docusaurus", "Vitepress", "Astro", "Starlight"] as const;

const framework = ref<typeof frameworks[number]>("");
const provider = ref<typeof providers[number]>("");

const url = computed(() => {
  const MAP = {
    Local: {
      Docusaurus: "/docs/local/integrations/docusaurus",
      Vitepress: "/docs/local/integrations/vitepress",
      Astro: "/docs/local/integrations/astro",
      Starlight: "/docs/local/integrations/starlight",
    },
    Cloud: {
      Docusaurus: "/docs/cloud/integrations/docusaurus",
      Vitepress: "/docs/cloud/integrations/vitepress",
      Astro: "/docs/cloud/integrations/astro",
      Starlight: "/docs/cloud/integrations/starlight",
    },
  }

  return MAP?.[provider.value]?.[framework.value];
});

</script>

# Quick Start

<div class="flex flex-col gap-4 mt-6">
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

<div v-if="url" class="mt-6">
<a :href="url" target="_blank">This</a> is all you need.
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
