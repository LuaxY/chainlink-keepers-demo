<template>
  <div>
    <div class="pt-5 px-5">
      <div>
        <div v-if="!connected" class="flex justify-center">
          <button
            @click="$store.dispatch('web3/connect')"
            class="
              px-4
              py-2
              rounded
              font-bold
              text-white
              bg-sky-500
              hover:bg-sky-600
            "
          >
            Connect Wallet
          </button>
        </div>
        <div v-else>
          <div class="flex gap-5 justify-center">
            <div class="rounded px-4 py-2 bg-gray-100 border border-gray-200">
              <User :address="address" />
            </div>
            <button
              v-if="
                parseInt($store.state.web3.network, 16) != networkId &&
                $store.state.web3.network != networkId &&
                $store.state.web3.network != ''
              "
              @click="changeNetwork"
              class="
                px-5
                py-3
                rounded
                font-semibold
                text-sm text-white
                bg-red-500
                hover:bg-white
                hover:text-red-500
                hover:ring-2
                hover:ring-red-500
                flex
                items-center
              "
            >
              <ExclamationIcon class="mr-1 w-4 mt-0.5" />
              Incorrect Network
            </button>
            <button
              @click="$store.dispatch('web3/logout')"
              class="
                px-4
                py-2
                rounded
                font-semibold
                text-sm text-white
                bg-red-500
                hover:bg-red-600
              "
            >
              Logout
            </button>
          </div>
        </div>
      </div>
      <div class="flex items-center gap-x-2">
        <button
          @click="mint"
          class="
            px-3
            py-2
            rounded
            font-bold
            text-white
            bg-blue-500
            hover:bg-blue-700
          "
        >
          MINT
        </button>
        {{ txInfo.status }} &nbsp;
        <a
          :href="_explorer(txInfo.txHash, 'tx')"
          target="_blank"
          rel="noopener noreferrer"
          class="flex"
        >
          {{ _shorten(txInfo.txHash) }}
          <ExternalLinkIcon class="ml-1 w-4" v-if="txInfo.txHash" />
        </a>
      </div>
      <div>
        <div
          class="
            inline-flex
            items-center
            font-mono
            px-4
            py-2
            border-2 border-[#375bd2]
            hover:border-blue-600
            font-medium
            bg-white
            text-[#375bd2]
            hover:text-blue-600
            rounded-md
          "
        >
          checkUpkeep()
          <span class="flex h-3 w-3 relative -mt-0.5 ml-2">
            <span
              class="
                animate-ping
                absolute
                inline-flex
                h-full
                w-full
                rounded-full
                opacity-75
              "
              :class="pingColor[0]"
            ></span>
            <span
              class="relative inline-flex rounded-full h-3 w-3"
              :class="pingColor[1]"
            ></span>
          </span>
        </div>
      </div>
    </div>
    <div class="h-[1px] bg-gray-400 mt-5"></div>
    <h3 class="text-lg font-bold text-center bg-gray-200">Logs</h3>
    <div class="h-[1px] bg-gray-400"></div>
    <div class="bg-gray-100 w-full h-24 font-mono text-sm p-1">
      <div>[00:00:00] Test</div>
      <div>TEST</div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from "vue";
import { useStore } from "vuex";
import { networkId, changeNetwork } from "@/store/modules/web3";
import { ExclamationIcon } from "@heroicons/vue/solid";
import { ExternalLinkIcon } from "@heroicons/vue/outline";
import { ethers } from "ethers";
import { provider, defaultProvider } from "@/store/modules/web3";
import SuperNFTArtifact from "../../../artifacts/contracts/NFT.sol/SuperNFT.json";

export default {
  name: "Interact",
  components: {
    ExclamationIcon,
    ExternalLinkIcon,
  },
  setup() {
    const store = useStore();
    const txInfo = ref({});
    const pingColor = ref(["bg-red-400", "bg-red-500"]);

    store.dispatch("web3/init");

    const SuperNFT = new ethers.Contract(
      process.env.VUE_APP_SUPER_NFT_ADDRESS,
      SuperNFTArtifact.abi,
      defaultProvider
    );

    const connected = computed(() => {
      return store.state.web3.connected;
    });

    const address = computed(() => {
      return store.state.web3.address;
    });

    async function mint() {
      const signer = provider.getSigner();
      const price = await SuperNFT.PRICE();

      txInfo.value.status = "📩";
      const tx = await SuperNFT.connect(signer).mint({
        value: price,
      });
      txInfo.value.txHash = tx.hash;
      txInfo.value.status = "⌛";
      tx.wait().then(async () => {
        txInfo.value.balance = ethers.utils.formatEther(
          await signer.getBalance()
        );
        txInfo.value.status = "✅";
      });
    }

    defaultProvider.on("block", async () => {
      const result = await SuperNFT.checkUpkeep("0x");
      pingColor.value = result.upkeepNeeded
        ? ["bg-green-400", "bg-green-500"]
        : ["bg-red-400", "bg-red-500"];
    });

    return {
      connected,
      address,
      networkId,
      changeNetwork,
      txInfo,
      mint,
      pingColor,
    };
  },
};
</script>
