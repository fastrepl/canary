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
    '🐤@getcanary/web (All)': canaryAll.size,
    "kapa-widget.bundle.js": kapa.size,
    "@mendable/search": mendable.size,
    "@inkeep/uikit-js": inkeep.size,
}
</script>

# What is Canary?

`Canary` is modern search-bar for techincal documentation.

## Search-as-you-type, augmented with AI

## Tiny components that works anywhere

<sub><a href="https://github.com/fastrepl/canary/tree/main/js/apps/docs/data">Source</a></sub>

<SizeChart 
title="Bundle size (Uncompressed)"
:labels="Object.keys(packages)"
:values="Object.values(packages)"
/>

## Modular and open-source

We're fully [open-source](https://github.com/fastrepl/canary), and encourage anyone to contribute to our UI components. Also, we put a lot of effort into making the **core parts of 🐤Canary as modular as possible**.

<!--@include: ./index.examples.md-->
