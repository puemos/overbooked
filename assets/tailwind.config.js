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
    "bg-gray-300",
    "bg-red-300",
    "bg-yellow-300",
    "bg-green-300",
    "bg-blue-300",
    "bg-indigo-300",
    "bg-pink-300",
    "bg-purple-300",
  ],
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    require("@tailwindcss/aspect-ratio"),
  ],
  darkMode: "class",
};
