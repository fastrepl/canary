<script setup>
import Chat from '../components/Chat.vue'
import Headline from '../components/Headline.vue'
import KeywordSearchProblem from '../components/KeywordSearchProblem.vue'
import KeywordSearchSolution from '../components/KeywordSearchSolution.vue'
import SearchDigestProblem from '../components/SearchDigestProblem.vue'
import SearchDigestSolution from '../components/SearchDigestSolution.vue'
import QueryRankChart from '../components/QueryRankChart.vue'
</script>

<Headline />

> 🐤Canary is [open-source](https://github.com/fastrepl/canary) project just for that!

## Search works, only when users know the <ins>"keyword"</ins>

Typical search experience looks like this:

<KeywordSearchProblem />

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

<SearchDigestProblem />

::: warning With Canary ↓

<SearchDigestSolution />

:::

## Understand users through their interactions with the docs

We're still working on `Search & Ask analytics`, which will help you gain insights into what users are searching and asking for. In the meantime, you can use other feedback components we provide to collect information,

  <div class="flex justify-center items-center">
  like this 👇.
  </div>
