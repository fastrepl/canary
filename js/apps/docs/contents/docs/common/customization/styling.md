# Styling

[`canary-root`](https://github.com/fastrepl/canary/blob/main/js/packages/web/src/components/canary-root.ts) do the heavy lifting for you.

## CSS Variables

All components in Canary renders inside a [shadow DOM](https://developer.mozilla.org/en/docs/Web/API/Web_components/Using_shadow_DOM). So CSS in your documentation website will not affect the styling of Canary components by default.

[CSS variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties) is one exception. And Canary exposes them for you to use.

```bash{2,3}
# colors
--canary-color-primary-c
--canary-color-primary-h
--canary-color-gray-c
--canary-color-gray-h
```

<script setup>
import Styling from "../../../../components/Styling.vue";
</script>

<div class="flex flex-col items-center justify-center">
<Styling />
</div>

::: details Available CSS Variables

<!--@include: ./styling.variables.md-->

:::

## CSS Parts

You can use [`::part CSS pseudo-element`](https://developer.mozilla.org/en-US/docs/Web/CSS/::part) to style Canary's components.

::: details Available Parts

<!--@include: ./styling.parts.md-->

:::

## Light / Dark Mode

```html{1}
<canary-root framework="vitepress">
    <!-- Rest of the code -->
</canary-root>
```

Each documentation framework has its own way to add theme information to the dom. By providing `framework` attribute, `canary-root` will handle the theme for you.

Currently we support `docusaurus`, `vitepress`, and `starlight`.
