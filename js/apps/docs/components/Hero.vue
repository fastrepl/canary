<script setup lang="ts">
const GITHUB_URL = "https://github.com/fastrepl/canary";
</script>

<template>
  <section id="home">
    <div class="container">
      <div class="relative">
        <div class="pt-18 sm:pt-24">
          <div class="mx-auto px-6 lg:px-8">
            <div class="mx-auto max-w-2xl text-center">
              <h1 class="text-4xl font-bold sm:text-6xl">
                Questions <span class="text-blue-500">Answered,</span>
                Happy Developers.
              </h1>
              <p class="mt-6 text-lgt">
                Canary provides all the tools you need to have questions
                <span class="underline">answered instantly</span>,<br />
                get insights on <span class="underline"> what's missing</span>,
                and <span class="underline">keep your docs fresh</span>.
              </p>
              <div class="mt-10 flex items-center justify-center gap-x-6">
                <a
                  href="/docs/guide/getting-started"
                  class="rounded-md bg-blue-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
                >
                  Get started
                </a>
                <a :href="GITHUB_URL" class="hover:underline"
                  >⭐ Star us on GitHub →</a
                >
              </div>
            </div>

            <div class="mt-24 flex justify-center items-center"></div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
