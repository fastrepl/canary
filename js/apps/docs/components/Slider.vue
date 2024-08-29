<script setup lang="ts">
const props = defineProps<{
  min: number;
  max: number;
  value: number;
  step: number;
}>();

const emit = defineEmits<{ (e: "change", value: number): void }>();

const onChange = (e: Event) => {
  const target = e.target as HTMLInputElement;
  const value = Number(target.value);
  emit("change", value);
};
</script>

<template>
  <input
    @input="onChange"
    type="range"
    :min="min.toString()"
    :max="max.toString()"
    :value="value.toString()"
    class="range"
    :step="step.toString()"
  />
</template>

<style scoped>
input {
  width: 80px;
}
</style>
