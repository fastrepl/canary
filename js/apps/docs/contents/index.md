<script setup>
import SizeChart from '../components/SizeChart.vue'
import Demo from '../components/Demo.vue'

import { data as canarySearch } from '../data/size_canary_search.data.js'
import { data as canaryAll } from '../data/size_canary_all.data.js'
import { data as docsearch } from '../data/size_docsearch.data.js'
import { data as inkeep } from '../data/size_inkeep.data.js'
import { data as kapa } from '../data/size_kapa.data.js'
import { data as mendable } from '../data/size_mendable.data.js'

const packages = {
    "@docsearch/js": docsearch.size,
    '🐤@getcanary/web (Search)': canarySearch.size,
    '🐤@getcanary/web (Search + Ask)': canaryAll.size,
    "kapa-widget.bundle.js": kapa.size,
    "@mendable/search": mendable.size,
    "@inkeep/uikit-js": inkeep.size,
}
</script>

# What is Canary?

`Canary` provides UI primitives and self-hostable infrastructure for building **modern search-bar** for techincal documentation.

## Search-as-you-type, augmented with AI

It's been a while since we started seeing blazing fast search results. But still, it's hard to find the exact information **unless you know the exact keyword.**

`<SOME_EXAMPLES_HERE>`

Also, for large documentations, users often need to go though multiple pages and sections to get questions answered.

`<SOME_EXAMPLES_HERE>`

`Canary` use keyword based search by default to provide fast search results, but falls back to AI-powered search if it can not find any results or user is asking rather than searching.

## Tiny components that works anywhere

Canary use [Web components](https://developer.mozilla.org/en-US/docs/Web/Web_Components), so browsers know how to render it.

<sub><a href="https://github.com/fastrepl/canary/tree/main/js/apps/docs/data">source</a></sub>

<SizeChart 
title="Bundle size (Uncompressed)"
:labels="Object.keys(packages)"
:values="Object.values(packages)"
/>

## Modular and open-source

We're fully [open-source](https://github.com/fastrepl/canary), and encourage anyone to contribute to our UI components. Also, we put a lot of effort into making the **core parts of 🐤Canary as modular as possible**.

<!--@include: ./index.examples.md-->
