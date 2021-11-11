<template>
  <div>
    <h2 class="text-2xl font-bold mb-5">{{ name }} ({{ symbol }})</h2>
    <div><b>Price</b>: {{ price }} <b class="text-[#8248e5]">MATIC</b></div>
    <div><b>Owners</b>: {{ counter }}</div>
    <div><b>Block</b>: {{ blockNumber }}</div>
    <br />
    <table class="w-full">
      <tr>
        <th>#</th>
        <th>NFT</th>
        <th>Winner</th>
        <th>Date</th>
      </tr>
      <tr v-for="(winner, i) in winners" :key="winner" class="text-center">
        <td>{{ _n(i + 1, "0o") }}</td>
        <td>{{ winner.id }}</td>
        <td>
          <UiAvatar
            class="mr-0.5 -mt-0.5"
            :opts="{ seed: winner.address, size: 16 }"
          />
          {{ _shorten(winner.address) }}
        </td>
        <td>{{ _dateAgo(winner.timestamp) }}</td>
      </tr>
    </table>
  </div>
</template>

<script>
import { ref } from "vue";
import { ethers } from "ethers";
import { defaultProvider } from "@/store/modules/web3";
import SuperNFTArtifact from "../../../artifacts/contracts/NFT.sol/SuperNFT.json";

export default {
  name: "NFTInfo",
  setup() {
    const name = ref("");
    const symbol = ref("");
    const price = ref(0);
    const counter = ref(0);
    const winners = ref([]);
    const blockNumber = ref(0);

    const SuperNFT = new ethers.Contract(
      "0x997fb83134533D797be64536Ed39307BE5e60F0C", // TODO: get from env
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
      counter.value = value;
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

    // TODO: check if this is correct
    // SuperNFT.on("NewWinner", (id, address, timestamp) => {
    //   console.log(id, address, timestamp);
    //   winners.value.push({
    //     id: id.toNumber(),
    //     address: address,
    //     timestamp: timestamp.toNumber() * 1000,
    //   });
    // });

    defaultProvider.getBlockNumber().then((value) => {
      blockNumber.value = value;
    });

    defaultProvider.on("block", (block) => {
      blockNumber.value = block;
    });

    return {
      name,
      symbol,
      price,
      counter,
      winners,
      blockNumber,
    };
  },
};
</script>
