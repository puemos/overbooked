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
  safelist: [
    "col-start-1",
    "col-start-2",
    "col-start-3",
    "col-start-4",
    "col-start-5",
    "col-start-6",
    "col-start-7",
    "col-start-8",
    "col-start-9",
    "h-screen",
  ],
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    require("@tailwindcss/aspect-ratio"),
  ],
  darkMode: "class",
};
