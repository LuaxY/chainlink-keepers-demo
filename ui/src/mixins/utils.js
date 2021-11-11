import numeral from "numeral";
import TimeAgo from "javascript-time-ago";
import en from "javascript-time-ago/locale/en";
import networks from "./networks.json";

TimeAgo.addDefaultLocale(en);
const timeAgo = new TimeAgo("en-US");

function shorten(str, key) {
  if (!str || str === "") return str;
  let limit;
  if (typeof key === "number") limit = key;
  if (key === "symbol") limit = 6;
  if (key === "name") limit = 64;
  if (key === "choice") limit = 12;
  if (limit)
    return str.length > limit ? `${str.slice(0, limit).trim()}...` : str;
  return short(str, 6, 4);
}

function short(str, limitStart, limitEnd) {
  return `${str.slice(0, limitStart)}...${str.slice(str.length - limitEnd)}`;
}

export default {
  methods: {
    _short: short,
    _shorten: shorten,
    _n(number, format = "(0.[00]a)") {
      if (number < 0.00001) return format.includes("%") ? "0%" : 0;
      return numeral(number).format(format);
    },
    _explorer(str, type = "address") {
      return `${
        networks[process.env.VUE_APP_NETWORK_ID].explorer
      }/${type}/${str}`;
    },
    _dateAgo(endDate) {
      return timeAgo.format(endDate);
    },
  },
};
