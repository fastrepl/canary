<script setup lang="ts">
import { ref, computed } from "vue";
import Slider from "./Slider.vue";

const seats = ref(1);
const searches = ref(2);
const answers = ref(100);

const seatsPrice = computed(() => (seats.value - 1) * 10);
const seatsPriceFormula = computed(() => `(${seats.value} - 1) × 10`);

const searchesPrice = computed(() => Math.max(0, searches.value - 2) * 1);
const searchesPriceFormula = computed(
  () => `(${searches.value}K - 2K) × 0.001`,
);

const answersPrice = computed(() => Math.max(0, answers.value - 100) * 0.15);
const answersPriceFormula = computed(() => `(${answers.value} - 100) × 0.15`);

const totalPrice = computed(
  () => seatsPrice.value + searchesPrice.value + answersPrice.value,
);
</script>

<template>
  <section class="py-8 lg:py-20" id="pricing">
    <div class="container">
      <div class="text-center">
        <h2 class="text-4xl font-semibold">
          Transparent pricing with free tier
        </h2>
        <p class="mt-2 text-lg">
          We don't have "Talk to sales". Instead, we have
          <a href="/" class="link link-underline">"Chat with founder".</a>
        </p>
      </div>
      <div class="flex flex-col flex-row gap-8 mt-12 items-center">
        <div class="flex flex-col gap-8 w-full max-w-[600px]">
          <div class="flex flex-col gap-2">
            <div class="flex flex-row justify-between">
              <div>
                <span class="text-lg font-semibold">{{ seats }}</span>
                <span class="text-md"> members / month</span>
              </div>
              <div class="tooltip underline" :data-tip="seatsPriceFormula">
                <span class="text-lg font-semibold">${{ seatsPrice }}</span>
              </div>
            </div>
            <Slider
              :min="1"
              :max="24"
              :step="1"
              :value="seats"
              @change="seats = $event"
            />
          </div>

          <div class="flex flex-col gap-2">
            <div class="flex flex-row justify-between">
              <div>
                <span class="text-lg font-semibold">{{ searches }}K</span>
                <span class="text-md"> searches / month</span>
              </div>
              <div class="tooltip underline" :data-tip="searchesPriceFormula">
                <span class="text-lg font-semibold">${{ searchesPrice }}</span>
              </div>
            </div>
            <Slider
              :min="2"
              :max="20"
              :step="1"
              :value="searches"
              @change="searches = $event"
            />
          </div>

          <div class="flex flex-col gap-2">
            <div class="flex flex-row justify-between">
              <div>
                <span class="text-lg font-semibold">{{ answers }}</span>
                <span class="text-md"> questions / month</span>
              </div>
              <div class="tooltip underline" :data-tip="answersPriceFormula">
                <span class="text-lg font-semibold">${{ answersPrice }}</span>
              </div>
            </div>
            <Slider
              :min="100"
              :max="5000"
              :step="50"
              :value="answers"
              @change="answers = $event"
            />
          </div>
        </div>

        <div
          class="w-full max-w-[400px] card border border-base-content/10 p-3 shadow-sm"
        >
          <div class="card px-6 py-2 text-base-content">
            <h3 class="text-xl font-semibold text-primary">Hosted</h3>
            <p class="mt-4 flex items-baseline">
              <span class="text-5xl font-bold tracking-tight text-primary">
                ${{ totalPrice }}
              </span>
              <span class="ml-1 text-xl font-semibold">/month</span>
            </p>

            <button class="mt-6 btn btn-primary btn-block">Get Started</button>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
