<script setup lang="ts">
const props = defineProps<{
  values: string[];
  selected: string;
}>();

const emit = defineEmits<{
  (event: "update:selected", value: string): void;
}>();
</script>

<template>
  <div class="flex gap-2 items-center">
    <button
      v-for="current in values"
      :key="current"
      :class="{ tag: true, selected: selected === current }"
      @click="$emit('update:selected', current)"
    >
      {{ current }}
    </button>
  </div>
</template>

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
