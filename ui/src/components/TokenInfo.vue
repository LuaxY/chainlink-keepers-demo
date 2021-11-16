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
      <div>
        <b>Total Supply:</b> {{ _n(totalSupply, "0,0.[00]") }} {{ symbol }}
      </div>
    </div>

    <div class="h-[1px] bg-gray-400 mt-5"></div>
    <h3 class="text-lg font-bold text-center bg-gray-200">
      Holders ({{ holders.length }})
    </h3>
    <div class="h-[1px] bg-gray-400 mb-5"></div>

    <div
      class="w-full flex flex-col text-center gap-y-2"
      v-if="holders.length > 0"
    >
      <div class="flex gap-x-1 w-full font-bold">
        <div class="w-1/6">#</div>
        <div class="w-2/6">Owner</div>
        <div class="w-2/6">Quantity</div>
        <div class="w-2/6">%</div>
      </div>
      <div
        v-for="holder in holders.sort((a, b) => a.rank - b.rank)"
        :key="holder"
        class="flex gap-x-1 w-full"
      >
        <div class="w-1/6">{{ holder.rank }}</div>
        <div class="w-2/6 flex items-center gap-x-2">
          <UserIcon v-if="holder.type === 'EOA'" class="w-4" />
          <DocumentTextIcon v-if="holder.type === 'contract'" class="w-4" />
          <User :address="holder.address" />
        </div>
        <div class="w-2/6">{{ holder.quantity }}</div>
        <div class="w-2/6">{{ holder.percentage }}</div>
      </div>
    </div>
    <div class="text-sm text-center" v-else>No holders...</div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import { ethers } from "ethers";
import { defaultProvider } from "@/store/modules/web3";
import SuperTokenArtifact from "../../../artifacts/contracts/Token.sol/SuperToken.json";
import { ExternalLinkIcon } from "@heroicons/vue/outline";
import { UserIcon, DocumentTextIcon } from "@heroicons/vue/solid";
import axios from "axios";

export default {
  name: "TokenInfo",
  components: {
    ExternalLinkIcon,
    UserIcon,
    DocumentTextIcon,
  },
  setup() {
    const name = ref("");
    const symbol = ref("");
    const totalSupply = ref("");
    const holders = ref([]);

    const SuperToken = new ethers.Contract(
      process.env.VUE_APP_SUPER_TOKEN_ADDRESS,
      SuperTokenArtifact.abi,
      defaultProvider
    );

    SuperToken.name().then((value) => {
      name.value = value;
    });

    SuperToken.symbol().then((value) => {
      symbol.value = value;
    });

    SuperToken.totalSupply().then((value) => {
      totalSupply.value = ethers.utils.formatEther(value);
    });

    async function fetchHolders() {
      const result = await axios.get(
        `https://northamerica-northeast1-voidmx.cloudfunctions.net/etherscan-polygon-mumbai-token-holders?address=${process.env.VUE_APP_SUPER_TOKEN_ADDRESS}`
      );
      holders.value = result.data;
    }

    SuperToken.on("Transfer", async () => {
      await fetchHolders();
    });

    onMounted(async () => {
      fetchHolders();
    });

    return {
      name,
      symbol,
      totalSupply,
      address: SuperToken.address,
      holders,
    };
  },
};
</script>
