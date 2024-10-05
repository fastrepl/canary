<script setup lang="ts">
    import { Package } from "custom-elements-manifest/schema";
    import cem from "@getcanary/web/cusom-elements.json";

    type Component = Omit<Package["modules"][0], "path" | "kind">;
    const components = (cem as Package).modules.reduce((acc, { path, kind, ...rest}) => ({ ...acc, [path]: rest }), {} as Record<string, Component>);
</script>

<template>
    <template  v-for="[path, c] of Object.entries(components)">
        <h2 :id="path">{{ path.match(/\/([a-z-]+)\.ts$/)[1] }}</h2>
        <pre>{{ JSON.stringify(c, null, 2) }}</pre>
    </template>
</template>
