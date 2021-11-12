<template>
  <div class="mx-auto flex p-5 gap-x-5 items-start">
    <div class="w-1/3 flex flex-col gap-5">
      <div class="w-full p-5 bg-white border border-gray-400 rounded">
        <NftInfo />
      </div>
      <div class="w-full p-5 bg-white border border-gray-400 rounded"></div>
    </div>
    <div class="w-1/3 p-5 bg-white border border-gray-400 rounded">
      <Interact />
    </div>
    <div class="w-1/3 p-5 bg-white border border-gray-400 rounded">
      <HardhatMint />
    </div>
  </div>
</template>

<script>
import Interact from "../components/Interact.vue";
export default {
  components: { Interact },
  name: "Home",
};
</script>
