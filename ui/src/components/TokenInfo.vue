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
    <h3 class="text-lg font-bold text-center bg-gray-200 relative">
      <RefreshIcon
        class="
          absolute
          top-0
          right-0
          mr-2
          mt-1.5
          w-4
          cursor-pointer
          hover:animate-reverse-spin
        "
        @click="fetchHolders"
      />
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
        <div class="w-2/6">{{ holder.quantity }} {{ symbol }}</div>
        <div class="w-2/6">{{ _n(holder.percentage, "0,0.00%") }}</div>
      </div>
    </div>
    <div class="text-sm text-center" v-else>No holders...</div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import { useStore } from "vuex";
import { ethers } from "ethers";
import { defaultProvider } from "@/store/modules/web3";
import SuperTokenArtifact from "../../../artifacts/contracts/Token.sol/SuperToken.json";
import { ExternalLinkIcon } from "@heroicons/vue/outline";
import { UserIcon, DocumentTextIcon, RefreshIcon } from "@heroicons/vue/solid";
import axios from "axios";
import utils from "@/mixins/utils";

export default {
  name: "TokenInfo",
  components: {
    ExternalLinkIcon,
    UserIcon,
    DocumentTextIcon,
    RefreshIcon,
  },
  setup() {
    const store = useStore();
    const _shorten = utils.methods._shorten;

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
        `https://northamerica-northeast1-voidmx.cloudfunctions.net/etherscan-polygon-mumbai-token-holders?address=${process.env.VUE_APP_SUPER_TOKEN_ADDRESS}&decimal=100000000000000000000`
      );
      holders.value = result.data;
    }

    SuperToken.on("Transfer", async (from, to, amount) => {
      setTimeout(async () => {
        await fetchHolders();
        store.dispatch("notify", "Token holders updated");
        store.dispatch("log", "Token holders updated");
      }, 30000);

      if (from === "0x0000000000000000000000000000000000000000") {
        // store.dispatch("notify", `NFT #${id.toNumber()} minted`);
        store.dispatch(
          "log",
          `${ethers.utils.formatEther(amount)} ${
            symbol.value
          } minted to ${_shorten(to)}`
        );
      } else if (to === "0x0000000000000000000000000000000000000000") {
        // store.dispatch("notify", `NFT #${id.toNumber()} burned`);
        store.dispatch(
          "log",
          `${ethers.utils.formatEther(amount)} ${
            symbol.value
          } burned by ${_shorten(from)}`
        );
      } else {
        // store.dispatch("notify", `NFT #${id.toNumber()} transfered`);
        store.dispatch(
          "log",
          `${ethers.utils.formatEther(amount)} ${
            symbol.value
          } transfered from ${_shorten(from)} to ${_shorten(to)}`
        );
      }
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
      fetchHolders,
    };
  },
};
</script>
