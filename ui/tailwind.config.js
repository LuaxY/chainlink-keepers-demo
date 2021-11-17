const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  purge: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      keyframes: {
        "reverse-spin": {
          from: { transform: "rotate(360deg)" },
          // 'to': { transform: 'rotate(0deg)' },
        },
      },
      animation: {
        "reverse-spin": "reverse-spin 1s linear infinite",
      },
    },
    colors: {
      transparent: "transparent",
      ...colors,
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
