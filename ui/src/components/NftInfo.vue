<template>
  <div class="py-5">
    <div class="px-5">
      <h2 class="text-2xl font-bold">{{ name }} ({{ symbol }})</h2>
      <div class="flex mt-2">
        <b>Address</b>:
        <a
          :href="_explorer(address, 'token')"
          target="_blank"
          rel="noopener noreferrer"
          class="flex ml-1"
        >
          {{ _shorten(address) }}
          <ExternalLinkIcon class="ml-1 w-4" />
        </a>
      </div>
      <div><b>Price</b>: {{ price }} <b class="text-[#8248e5]">MATIC</b></div>
    </div>

    <div class="h-[1px] bg-gray-400 mt-5"></div>
    <h3 class="text-lg font-bold text-center bg-gray-200">
      Owners ({{ owners.length }})
    </h3>
    <div class="h-[1px] bg-gray-400 mb-5"></div>

    <div
      class="w-full flex flex-col text-center gap-y-2"
      v-if="owners.length > 0"
    >
      <div class="flex gap-x-1 w-full font-bold">
        <div class="w-1/6"></div>
        <div class="w-1/6">NFT</div>
        <div class="w-2/6">Owner</div>
      </div>
      <div
        v-for="owner in owners.sort((a, b) => a.id - b.id)"
        :key="owner"
        class="flex gap-x-1 w-full"
      >
        <div class="w-1/6"></div>
        <div class="w-1/6">{{ owner.id }}</div>
        <div class="w-2/6 pl-6">
          <User :address="owner.address" />
        </div>
      </div>
    </div>
    <div class="text-sm text-center" v-else>No owners...</div>

    <div class="h-[1px] bg-gray-400 mt-5"></div>
    <h3 class="text-lg font-bold text-center bg-gray-200">
      Winners ({{ winners.length }})
    </h3>
    <div class="h-[1px] bg-gray-400 mb-5"></div>

    <div
      class="w-full flex flex-col text-center gap-y-2"
      v-if="winners.length > 0"
    >
      <div class="flex gap-x-1 w-full font-bold">
        <div class="w-1/6">#</div>
        <div class="w-1/6">NFT</div>
        <div class="w-2/6">Winner</div>
        <div class="w-2/6">Date</div>
      </div>
      <div
        v-for="(winner, i) in winners.sort((a, b) => a.id - b.id)"
        :key="winner"
        class="flex gap-x-1 w-full"
      >
        <div class="w-1/6">{{ _n(i + 1, "0o") }}</div>
        <div class="w-1/6">{{ winner.id }}</div>
        <div class="w-2/6 pl-6">
          <User :address="winner.address" />
        </div>
        <div class="w-2/6">{{ _dateAgo(winner.timestamp) }}</div>
      </div>
    </div>
    <div class="text-sm text-center" v-else>No winners...</div>
  </div>
</template>

<script>
import { ref } from "vue";
import { ethers } from "ethers";
import { defaultProvider } from "@/store/modules/web3";
import SuperNFTArtifact from "../../../artifacts/contracts/NFT.sol/SuperNFT.json";
import { ExternalLinkIcon } from "@heroicons/vue/outline";

export default {
  name: "NFTInfo",
  components: {
    ExternalLinkIcon,
  },
  setup() {
    const name = ref("");
    const symbol = ref("");
    const price = ref(0);
    const owners = ref([]);
    const winners = ref([]);

    const SuperNFT = new ethers.Contract(
      process.env.VUE_APP_SUPER_NFT_ADDRESS,
      SuperNFTArtifact.abi,
      defaultProvider
    );

    SuperNFT.name().then((value) => {
      name.value = value;
    });

    SuperNFT.symbol().then((value) => {
      symbol.value = value;
    });

    SuperNFT.PRICE().then((value) => {
      price.value = ethers.utils.formatEther(value);
    });

    SuperNFT._counter().then((value) => {
      for (let i = 0; i < value; i++) {
        SuperNFT.ownerOf(i).then((value) => {
          owners.value.push({
            id: i,
            address: value,
          });
        });
      }
    });

    SuperNFT._winnersCounter().then((value) => {
      for (let i = 0; i < value; i++) {
        SuperNFT._winners(i).then((value) => {
          winners.value.push({
            id: value[0].toNumber(),
            address: value[2],
            timestamp: value[3].toNumber() * 1000,
          });
        });
      }
    });

    SuperNFT.on("Transfer", (from, to, id) => {
      if (from === "0x0000000000000000000000000000000000000000") {
        owners.value.push({
          id: id.toNumber(),
          address: to,
        });
      } else if (to === "0x0000000000000000000000000000000000000000") {
        owners.value = owners.value.filter(
          (owner) => owner.id !== id.toNumber()
        );
      } else {
        owners.value = owners.value.map((owner) => {
          if (owner.id === id.toNumber()) {
            return {
              id: id.toNumber(),
              address: to,
            };
          }
          return owner;
        });
      }
    });

    SuperNFT.on("NewWinner", (id, address, timestamp) => {
      winners.value.push({
        id: id.toNumber(),
        address: address,
        timestamp: timestamp.toNumber() * 1000,
      });
    });

    return {
      name,
      symbol,
      address: SuperNFT.address,
      price,
      owners,
      winners,
    };
  },
};
</script>
