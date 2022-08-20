const colors = require("tailwindcss/colors");

module.exports = {
  content: ["../lib/*_web/**/*.*ex", "./js/**/*.js"],
  theme: {
    extend: {
      colors: {
        primary: colors.slate,
        secondary: colors.purple,
        danger: colors.red,
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    require("@tailwindcss/aspect-ratio"),
  ],
  darkMode: "class",
};
