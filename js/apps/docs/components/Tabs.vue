<script setup lang="ts">
import { defineProps, defineEmits } from "vue";

const props = defineProps<{
  values: readonly string[];
  selected: string;
}>();

const emits = defineEmits<{
  (e: "update:selected", value: string): void;
}>();

const setActiveTab = (tab: string) => {
  emits("update:selected", tab);
};
</script>

<template>
  <div class="flex gap-2 text-sm font-semibold">
    <button
      v-for="current in values"
      :key="current"
      class="hover:underline"
      :class="{ underline: selected === current }"
      @click="setActiveTab(current)"
    >
      {{ current }}
    </button>
  </div>
</template>
