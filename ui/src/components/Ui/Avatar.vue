<template>
  <Jazzicon
    :address="opts.seed"
    :diameter="opts.size"
    class="inline-block align-middle leading-none mt-0.5"
  />
</template>

<script>
import Jazzicon from "vue3-jazzicon/src/components";

export default {
  name: "Blockie",
  components: {
    Jazzicon,
  },
  props: {
    opts: Object,
  },
};
</script>
