<template>
  <div class="p-5">
    <button
      @click="enabled = !enabled"
      class="
        w-full
        px-3
        py-2
        font-bold
        bg-gray-200
        hover:bg-gray-300
        rounded
        border border-gray-400
      "
    >
      Toggle Super Shadowy Panel
    </button>
    <div
      class="flex flex-col gap-y-2 mt-5"
      v-if="enabled && accounts.length > 0"
    >
      <div class="w-full flex gap-x-1 items-center font-lg">
        <div class="w-4/12 text-center font-bold">Address</div>
        <div class="w-2/12 text-center font-bold text-[#8248e5]">MATIC</div>
        <div class="w-2/12 text-center flex justify-center">
          <LightningBoltIcon class="w-4" />
        </div>
        <div class="w-4/12 text-center font-bold">TX</div>
      </div>
      <div
        class="w-full flex gap-x-1 items-center"
        v-for="(account, i) in accounts.sort((a, b) => a.id - b.id)"
        :key="account"
      >
        <div class="w-4/12">
          <User :address="account.address" />
        </div>
        <div class="w-2/12 text-center">
          {{ _n(account.balance, "0,0.[000000]") }}
        </div>
        <div class="w-2/12 text-center">
          <button
            @click="mint(i)"
            class="px-3 py-2 rounded font-bold text-white"
            :class="colors[i]"
          >
            MINT
          </button>
        </div>
        <div class="w-4/12 flex flex-nowrap items-center gap-x-1">
          <span>{{ account.status }}</span>
          <a
            :href="_explorer(account.txHash, 'tx')"
            target="_blank"
            rel="noopener noreferrer"
            class="flex"
          >
            {{ _shorten(account.txHash) }}
            <ExternalLinkIcon class="ml-1 w-4" v-if="account.txHash" />
          </a>
          <span class="truncate" v-if="account.error">{{ account.error }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, ref } from "vue";
import { ethers } from "ethers";
import { defaultProvider } from "@/store/modules/web3";
import SuperNFTArtifact from "../../../artifacts/contracts/NFT.sol/SuperNFT.json";
import { ExternalLinkIcon } from "@heroicons/vue/outline";
import { LightningBoltIcon } from "@heroicons/vue/solid";

export default {
  name: "HardhatMint",
  components: {
    ExternalLinkIcon,
    LightningBoltIcon,
  },
  setup() {
    const enabled = ref(false);
    const accounts = ref([]);
    const signers = [];

    const initialIndex = 2;
    for (let i = initialIndex; i < 10 + initialIndex; i++) {
      signers.push(
        ethers.Wallet.fromMnemonic(
          process.env.VUE_APP_MNEMONIC,
          `m/44'/60'/0'/0/${i}`
        ).connect(defaultProvider)
      );
    }

    const SuperNFT = new ethers.Contract(
      process.env.VUE_APP_SUPER_NFT_ADDRESS,
      SuperNFTArtifact.abi,
      defaultProvider
    );

    let price;
    SuperNFT.PRICE().then((value) => {
      price = value;
    });

    const colors = [
      "bg-red-500 hover:bg-red-700",
      "bg-orange-500 hover:bg-orange-700",
      "bg-yellow-500 hover:bg-yellow-700",
      "bg-lime-500 hover:bg-green-700",
      "bg-green-500 hover:bg-green-700",
      "bg-teal-500 hover:bg-teal-700",
      "bg-blue-500 hover:bg-blue-700",
      "bg-indigo-500 hover:bg-indigo-700",
      "bg-purple-500 hover:bg-purple-700",
      "bg-pink-500 hover:bg-pink-700",
    ];

    async function mint(accountIndex) {
      try {
        const signer = signers[accountIndex];
        accounts.value[accountIndex].status = "📩";
        const tx = await SuperNFT.connect(signer).mint({
          value: price,
        });
        accounts.value[accountIndex].txHash = tx.hash;
        accounts.value[accountIndex].status = "⌛";
        tx.wait().then(async () => {
          accounts.value[accountIndex].balance = ethers.utils.formatEther(
            await signer.getBalance()
          );
          accounts.value[accountIndex].status = "✅";
        });
      } catch (error) {
        accounts.value[accountIndex].status = "❌";
        accounts.value[accountIndex].error = error.message;
      }
    }

    const getAccount = async (i) => {
      const signer = signers[i];
      accounts.value.push({
        id: i,
        address: await signer.getAddress(),
        balance: ethers.utils.formatEther(await signer.getBalance()),
        txHash: "",
        status: "",
      });
    };

    onMounted(async () => {
      for (let i = 0; i < 10; i++) {
        getAccount(i);
      }
    });

    return {
      enabled,
      accounts,
      colors,
      mint,
    };
  },
};
</script>
