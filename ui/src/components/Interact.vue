<template>
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
            hover:bg-white hover:text-red-500 hover:ring-2 hover:ring-red-500
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
</template>

<script>
import { computed } from "vue";
import { useStore } from "vuex";
import { networkId, changeNetwork } from "@/store/modules/web3";
import { ExclamationIcon } from "@heroicons/vue/solid";

export default {
  name: "Interact",
  components: {
    ExclamationIcon,
  },
  setup() {
    const store = useStore();

    store.dispatch("web3/init");

    const connected = computed(() => {
      return store.state.web3.connected;
    });
    const address = computed(() => {
      return store.state.web3.address;
    });

    return {
      connected,
      address,
      networkId,
      changeNetwork,
    };
  },
};
</script>
