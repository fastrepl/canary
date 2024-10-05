<script setup lang="ts">
import type { Package, CustomElementDeclaration } from "custom-elements-manifest/schema";

import cem from "@getcanary/web/custom-elements.json";

const components = (cem as Package).modules.reduce(
  (acc, module) => {
    const {
      path,
      declarations: [declaration],
    } = module;
    const name = path.match(/\/([a-z-]+)\.ts$/)[1];
    return {
      ...acc,
      [name]: {
        declaration: declaration as CustomElementDeclaration,
        canaryImports: (module["canaryImports"] || []) as string[],
      },
    };
  },
  {} as Record<
    string,
    { declaration: CustomElementDeclaration; canaryImports: string[] }
  >,
);
</script>

<template>
  <template
    v-for="[name, { declaration, canaryImports }] of Object.entries(components)"
  >
    <h2 :id="name" class="text-3xl">{{ name }}</h2>
    <a
      :href="`https://github.com/fastrepl/canary/blob/main/js/packages/web/${name}.ts`"
      target="_blank"
      class="text-sm"
    >
      source
    </a>

    <template v-if="canaryImports.length">
      <h3>Imports</h3>
      <ul class="list-disc list-inside">
        <li v-for="name in canaryImports">
          <a :href="`#${name}`">{{ name }}</a>
        </li>
      </ul>
    </template>

    <template v-if="declaration.slots">
      <h3>Slots</h3>
      <ul class="list-disc list-inside">
        <li v-for="slot in declaration.slots">
          <code>{{ slot.name || "Default" }}</code>
        </li>
      </ul>
    </template>

    <template v-if="declaration.attributes">
      <h3>Attributes</h3>
      <ul class="list-disc list-inside">
        <li v-for="attr in declaration.attributes">
          <code>{{ attr.name }}</code>
        </li>
      </ul>
    </template>

    <template v-if="declaration.cssProperties">
      <h3>CSS Properties</h3>
      <ul class="list-disc list-inside">
        <li
          v-for="prop in declaration.cssProperties"
          class="flex flex-row gap-2 items-center"
        >
          <code>{{ prop.name }}</code>
          <span class="text-sm">{{ prop.description }}</span>
        </li>
      </ul>
    </template>

    <template v-if="declaration.cssParts">
      <h3>CSS Parts</h3>
      <ul class="list-disc list-inside">
        <li v-for="part in declaration.cssParts">
          <code>{{ part.name }}</code>
        </li>
      </ul>
    </template>
  </template>
</template>
