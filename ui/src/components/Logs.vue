<template>
  <div
    class="
      bg-gray-100
      w-full
      font-mono
      text-sm
      p-3
      min-h-[20px]
      overflow-x-auto
    "
  >
    <div class="overflow-x-auto w-full" v-for="(item, i) in items" :key="i">
      <span class="text-gray-500 text-bold">[{{ item.date }}]</span>
      {{ item.message }}
    </div>
  </div>
</template>

<script>
import { computed } from "vue";
import { useStore } from "vuex";

export default {
  name: "Logs",
  setup() {
    const store = useStore();
    const items = computed(() => store.state.logs);

    return {
      items,
    };
  },
};
</script>
