<template>
  <div>
    <div class="pt-5 px-5 space-y-5">
      <div>
        <div v-if="!connected" class="flex justify-center">
          <button
            @click="$store.dispatch('web3/connect')"
            class="
              px-4
              py-2
              rounded
              font-medium
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
                font-medium
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
                font-medium
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
    </div>
    <div class="h-[1px] bg-gray-400 mt-5"></div>
    <div class="pt-5 px-5 space-y-5">
      <div class="flex justify-center items-center gap-x-5">
        <div class="px-4 py-2 border-2 border-gray-400 font-medium rounded-md">
          <b>Balance</b>: {{ _n(balance, "0,0.[000000]") }}
          <b class="text-[#8248e5]">MATIC</b>
        </div>
        <div class="flex items-center gap-x-2">
          <button
            @click="mint"
            class="
              px-3
              py-2
              rounded
              font-semibold
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
      </div>
    </div>
    <div class="h-[1px] bg-gray-400 mt-5"></div>
    <h3 class="text-lg font-bold text-center bg-gray-200">Logs</h3>
    <div class="h-[1px] bg-gray-400"></div>
    <Logs />
  </div>
</template>

<script>
import { ref, computed, onMounted } from "vue";
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

    const balance = ref(0);
    const txInfo = ref({});

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
        balance.value = ethers.utils.formatEther(await signer.getBalance());
        txInfo.value.status = "✅";
      });
    }

    onMounted(async () => {
      setTimeout(async () => {
        balance.value = ethers.utils.formatEther(
          //FIXME: not working
          await provider.getSigner().getBalance()
        );
      }, 1000);
    });

    return {
      connected,
      address,
      balance,
      networkId,
      changeNetwork,
      txInfo,
      mint,
    };
  },
};
</script>
