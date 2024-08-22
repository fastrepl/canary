<script setup lang="ts">
const handleClickLeft = () => {
  window.open(
    "https://docs.litellm.ai/search?q=how%20to%20limit%20cost%20per%20user",
  );
};
const handleClickRight = () => {
  window.open("https://docs.litellm.ai/search?q=budget");
};
</script>

<template>
  <div
    class="container w-full border rounded-md p-2 flex flex-row gap-4 justify-between"
  >
    <div class="flex flex-col gap-2 w-full" v-on:click="handleClickLeft">
      <input
        type="text"
        value="🔎 how to limit api cost|"
        disabled
        class="border rounded-md w-full text-sm"
      />
      <div
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span
          >...litellm_model_<mark>cost</mark>_map -> use
          deployment_<mark>cost</mark>...</span
        >
        <span class="font-semibold">Router - Load Balancing, Fallbacks</span>
      </div>
      <span class="mt-auto mx-auto text-2xl">😢</span>
    </div>
    <div class="flex flex-col gap-2 w-full" v-on:click="handleClickRight">
      <input
        type="text"
        value="🔎 budget|"
        disabled
        class="border rounded-md w-full text-sm"
      />
      <div
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span>Set <mark>Budget</mark>s</span>
        <span class="font-semibold">Budgets, Rate Limits</span>
      </div>
      <div
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span>Setting Team <mark>Budget</mark>s</span>
        <span class="font-semibold">Budgets, Rate Limits</span>
      </div>
      <span class="mt-auto mx-auto text-2xl">😊</span>
    </div>
  </div>
</template>

<style scoped>
.container {
  background-color: var(--vp-sidebar-bg-color);
  border-color: var(--vp-c-divider);
}

input {
  color: var(--vp-c-text-1);
  border-color: red;
  background-color: var(--vp-c-bg);
  padding: 4px 8px;
}

.item {
  background-color: var(--vp-c-bg-soft);
  border-color: var(--vp-c-divider);
}
</style>
