<script setup lang="ts">
const props = defineProps<{
  left: string;
  right: string;
}>();
</script>

<template>
  <div class="flex flex-col">
    <div class="flex items-center">
      <div class="w-3 overflow-hidden">
        <div
          class="left h-4 rotate-45 transform origin-bottom-right rounded-sm"
        ></div>
      </div>
      <div class="left p-4 my-2 rounded-lg flex-1" v-html="left"></div>
    </div>

    <div class="flex items-center">
      <div class="right p-4 my-2 rounded-lg flex-1" v-html="right"></div>
      <div class="w-3 overflow-hidden">
        <div
          class="right h-4 rotate-45 transform origin-top-left rounded-sm"
        ></div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.left,
.right {
  color: var(--vp-c-text-1);
  background-color: var(--vp-sidebar-bg-color);
}
</style>
