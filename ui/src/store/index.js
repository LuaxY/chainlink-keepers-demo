import { createStore } from "vuex";
import web3 from "./modules/web3";

export default createStore({
  state: {
    notifs: [],
    logs: [],
  },
  mutations: {
    notify(state, payload) {
      state.notifs.push({ ...payload, timestamp: Date.now() });
    },
    emptyNotifs(state) {
      state.notifs = [];
    },
    log(state, payload) {
      state.logs.push({ ...payload, timestamp: Date.now() });
    },
    emptyLogs(state) {
      state.logs = [];
    },
  },
  actions: {
    notify({ commit }, payload) {
      Array.isArray(payload)
        ? commit("notify", { message: payload[0], color: payload[1] })
        : commit("notify", {
            message: payload,
            color: "green",
          });
    },
    log({ commit }, payload) {
      commit("log", {
        message: payload,
        date: new Date().toLocaleString("en-US", {
          hour: "numeric",
          minute: "numeric",
          second: "numeric",
          hour12: false,
        }),
      });
    },
  },
  modules: {
    web3,
  },
});
