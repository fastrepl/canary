<script setup>
import Headline from '../components/Headline.vue'
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

<Headline />

<!-- # What if user always read the docs? -->

<!-- <Demo /> -->
