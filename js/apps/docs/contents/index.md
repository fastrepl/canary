<script setup>
import Chat from '../components/Chat.vue'
import Headline from '../components/Headline.vue'
import KeywordSearchProblem from '../components/KeywordSearchProblem.vue'
import KeywordSearchSolution from '../components/KeywordSearchSolution.vue'
import SearchDigestProblem from '../components/SearchDigestProblem.vue'
import SearchDigestSolution from '../components/SearchDigestSolution.vue'
import QueryRankChart from '../components/QueryRankChart.vue'

const keywordSearchProblemExample = {
  left: {
    query: "how to limit api cost",
    items: [
      {
        title: "Router - Load Balancing, Fallbacks",
        excerpt: "...litellm_model_<mark>cost</mark>_map -> use deployment_<mark>cost</mark>..."
      }
    ],
    emoji: "😢"
  },
  right: {
    query: "budget",
    items: [
      {
        title: "Budgets, Rate Limits",
        excerpt: "Set <mark>Budget</mark>s"
      },
      {
        title: "Budgets, Rate Limits",
        excerpt: "Setting Team <mark>Budget</mark>s"
      }
    ],
    emoji: "😊"
  }
}

const searchDisgestProblemExample = {
  query: "config feature_a",
  items: [
    {
      excerpt: "<mark>feature_a</mark>: option_1, option_2, option_3, option_4, option_5...",
      title: "Reference - <mark>config</mark>.yaml"
    },
    {
      excerpt: "...<mark>feature_a</mark>is really good. there's 999 ways of doing...",
      title: "What is <mark>Feature_A</mark>?"
    },
    {
      excerpt: "...to configure options for <mark>feature_a</mark>, you shoud do this and that...",
      title: "Tutorial - <mark>Config</mark>uration"
    }
  ]
}
</script>

<Headline />

> 🐤Canary is [open-source](https://github.com/fastrepl/canary) project just for that!

## Search works, only when users know the <ins>"keyword"</ins>

Typical search experience looks like this:

<KeywordSearchProblem v-bind="keywordSearchProblemExample" />

And this leads to bunch of support questions like:

<Chat
  left="👤 hi there! how can i <strong>set limit for api cost?</strong>"
  right="we <strong>already have docs</strong> for that. (readthemanual.com/<strong>budget</strong>-and-rate-limits) 👤"
/>

::: warning With Canary ↓

<KeywordSearchSolution />

:::

## Search results are not always easy to digest

As documentation grows, users **often need to read multiple sections and pages to get questions answered**.
This can be very time-consuming and frustrating.

<SearchDigestProblem v-bind="searchDisgestProblemExample" />

::: warning With Canary ↓

<SearchDigestSolution />

:::
