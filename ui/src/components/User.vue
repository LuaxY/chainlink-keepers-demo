<template>
  <UiPopover
    :options="{ offset: [0, 12], placement: 'bottom-start' }"
    v-if="popover"
  >
    <template #item>
      <a class="whitespace-nowrap cursor-pointer flex items-center gap-x-2">
        <UiAvatar :opts="{ seed: address, size: 16 }" />
        {{ _shorten(address) }}
      </a>
    </template>
    <template #content>
      <div class="p-4 text-center">
        <UiAvatar class="mb-4" :opts="{ seed: address, size: 64 }" />
        <h3>{{ _shorten(address) }}</h3>
        <a :href="_explorer(address)" target="_blank">
          <div
            class="
              flex
              items-center
              justify-center
              mt-5
              w-full
              px-4
              py-2
              rounded-full
              text-center
              font-semibold
              cursor-pointer
              outline-none
              border border-gray-300
              bg-white
              hover:bg-gray-200
            "
          >
            See on explorer
            <ExternalLinkIcon class="ml-1 h-4 w-4" />
          </div>
        </a>
      </div>
    </template>
  </UiPopover>
  <div v-else>
    <a class="whitespace-nowrap cursor-pointer">
      <UiAvatar class="mr-2 -mt-0.5" :opts="{ seed: address, size: 16 }" />
      {{ _shorten(address) }}
    </a>
  </div>
</template>

<script>
import { ExternalLinkIcon } from "@heroicons/vue/outline";

export default {
  name: "User",
  components: {
    ExternalLinkIcon,
  },
  props: {
    address: String,
    popover: {
      type: Boolean,
      default: true,
    },
  },
  setup() {},
};
</script>
