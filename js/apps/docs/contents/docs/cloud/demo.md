<script setup lang="ts">
import { onMounted, computed, ref, watch } from "vue";

import { data as cloud } from "@data/url_cloud.data";
import { data as demoForm } from "@data/demo_form.data";

import Radio from "@components/Radio.vue";
import Tabs from "@components/Tabs.vue";
import ButtonGroup from "@components/ButtonGroup.vue";
import Markdown from "@components/Markdown.vue";
import Video from "@components/Video.vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-cloud.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-callout-discord.js"),
    import("@getcanary/web/components/canary-ask.js"),
    import("@getcanary/web/components/canary-ask-results.js"),
    import("@getcanary/web/components/canary-mode-breadcrumb.js"),
  ]).then(() => {
    loaded.value = true;
  });
});


const projects = ["canary", "dspy", "litellm"] as const;
const project = ref<(typeof projects)[number]>(projects[0]);
const projectKey = computed(() => {
  if (project.value === "canary") {
    return cloud.key;
  }

  if (project.value === "dspy") {
    return "cpab9997bf";
  }

  if (project.value === "litellm") {
    return "cp1a506f13";
  }

  throw new Error();
});

const tabs = ["UI", "Code"] as const;
const tab = ref(tabs[0]);
const tags = ref(null);

watch(project, () => {
  tab.value = tabs[0];
});

const globs = computed(() => {
  if (project.value === "canary") {
    return JSON.stringify([
      { name: "Docs", pattern: "**/docs/**/*" },
      { name: "Github", pattern: "github.com/**/*" },
    ]);
  }

  if (project.value === "dspy") {
    return JSON.stringify([
      { name: "Docs", pattern: "**/docs/**" },
      { name: "API", pattern: "**/api/**" },
      { name: "Github", pattern: "**/github.com/**" },
    ]);
  }

  if (project.value === "litellm") {
    return JSON.stringify([
      { name: "Docs", pattern: "**/docs.litellm.ai/**" },
      { name: "Github", pattern: "**/github.com/**" },
    ]);
  }
});

const question = ref("");
const questions = ref([]);

watch(project, () => {
  if (project.value === "canary") {
    question.value = "vitepress";
    questions.value = [
      "api-base",
      "vitepress supported?",
      "css variable for changing hue?",
    ];
    tags.value = "Local,Cloud";
  }

  if (project.value === "dspy") {
    question.value = "retrieval";
    questions.value = [
      "colbert",
      "filtering in retrieval?",
      "what is mi..ppro?",
      "built-in datasets list"
    ];
    tags.value = null;
  }

    if (project.value === "litellm") {
    question.value = "openai";
    questions.value = [
      "how to limit api cost?",
      "what models are supported?",
      "guardrails",
    ];
    tags.value = "All,Proxy"
  }
}, { immediate: true });
</script>

# Cloud Search Demo

::: tip INFO

**We are not affiliated** with any of the projects listed here, and the list might change over time.

:::

<Video id="hQVTgrdDzmoDOvrbpQdivP8IRUe5pqaXmnqgnTudGOQ" />

<div class="mt-6 flex flex-col gap-2">
  <hr class="my-1" />
  <div class="flex flex-row gap-4 items-center">
    <span class="text-sm font-semibold">Sources</span>
    <Radio :values="projects" :selected="project" @update:selected="project = $event" />
  </div>
  <hr class="my-1" />
  <div class="flex flex-row gap-4 items-center">
    <span class="text-sm font-semibold">Examples</span>
    <ButtonGroup :values="questions" @update:selected="question = $event" />
  </div>
  <hr class="my-1" />
</div>

<div class="container flex flex-col gap-2 mt-4" v-if="loaded">
  <Tabs :values="tabs" :selected="tab" @update:selected="tab = $event" />

  <canary-root framework="vitepress" :key="question" :query="question" v-show="tab === 'UI'">
    <canary-provider-cloud :api-base="cloud.base" :project-key="projectKey">
      <canary-content>
        <canary-filter-tags slot="head" :tags="tags" v-if="tags"></canary-filter-tags>
        <canary-input slot="input"></canary-input>
        <canary-search slot="mode">
          <canary-filter-tabs-glob slot="head" :tabs="globs"></canary-filter-tabs-glob>
          <canary-search-results slot="body"></canary-search-results>
        </canary-search>
        <canary-ask slot="mode">
          <canary-ask-results slot="body"></canary-ask-results>
        </canary-ask>
      </canary-content>
    </canary-provider-cloud>
  </canary-root>

  <template v-if="tab === 'Code'">

  <Markdown>

```html-vue{5-11}
<canary-root framework="vitepress">
  <canary-provider-cloud api-base="<API_BASE>" project-key="<API_KEY>">
    <canary-content>{{ tags ? `\n      <canary-filter-tags slot="head" tags="${tags}"></canary-filter-tags>` : "" }}
      <canary-input slot="input"></canary-input>
      <canary-search slot="mode">
        <canary-filter-tabs-glob slot="head" tabs={JSON.stringify(tabs)}></canary-filter-tabs-glob>
        <canary-search-results slot="body"></canary-search-results>
      </canary-search>
      <canary-ask slot="mode">
        <canary-ask-results slot="body"></canary-ask-results>
      </canary-ask>
    </canary-content>
  </canary-provider-cloud>
</canary-root>
```

  </Markdown>

  </template>
</div>

::: tip Wanna try it out with your project?

<a :href="demoForm.url" target="_blank">Fill out the form</a>, and we'll send you a link. No strings attached.

:::

<style scoped>
canary-root {
  --canary-content-max-width: 690px;
  --canary-content-max-height: 500px;
  --canary-color-primary-c: 0.05;
  --canary-color-primary-h: 90;
}
</style>
