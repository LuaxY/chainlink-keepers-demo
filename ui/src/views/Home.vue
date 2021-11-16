<template>
  <div>
    <div class="pt-5 px-5 flex justify-between">
      <h1 class="flex font-bold text-xl text-[#375bd2] items-center">
        <img src="/chainlink.png" alt="Chainlink logo" class="h-6 mr-2" />
        Chainlink Keepers Demo
      </h1>
      <div class="text-gray-400 text-lg gap-x-10 flex">
        <div>
          <b>Chain</b>: {{ network.name }} ({{ network.network }}/{{
            network.chainId
          }})
        </div>
        <div><b>Block #</b>: {{ blockNumber }}</div>
      </div>
    </div>
    <div class="mx-auto flex p-5 gap-x-5 items-start">
      <div class="w-1/3 flex flex-col gap-5">
        <div
          class="w-full bg-white border border-gray-400 rounded overflow-hidden"
        >
          <NftInfo />
        </div>
        <div
          class="w-full bg-white border border-gray-400 rounded overflow-hidden"
        >
          <TokenInfo />
        </div>
      </div>
      <div
        class="w-1/3 bg-white border border-gray-400 rounded overflow-hidden"
      >
        <Interact />
      </div>
      <div
        class="w-1/3 bg-white border border-gray-400 rounded overflow-hidden"
      >
        <HardhatMint />
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from "vue";
import { defaultProvider, network } from "@/store/modules/web3";

export default {
  name: "Home",
  setup() {
    const blockNumber = ref(0);

    defaultProvider.getBlockNumber().then((value) => {
      blockNumber.value = value;
    });

    defaultProvider.on("block", (block) => {
      blockNumber.value = block;
    });

    return {
      blockNumber,
      network,
    };
  },
};
</script>
