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

    "bg-gray-100",
    "bg-red-100",
    "bg-yellow-100",
    "bg-green-100",
    "bg-blue-100",
    "bg-indigo-100",
    "bg-pink-100",
    "bg-purple-100",

    "text-gray-800",
    "text-red-800",
    "text-yellow-800",
    "text-green-800",
    "text-blue-800",
    "text-indigo-800",
    "text-pink-800",
    "text-purple-800",

    "border-l-gray-500",
    "border-l-red-500",
    "border-l-yellow-500",
    "border-l-green-500",
    "border-l-blue-500",
    "border-l-indigo-500",
    "border-l-pink-500",
    "border-l-purple-500",

    "text-gray-300",
    "text-red-300",
    "text-yellow-300",
    "text-green-300",
    "text-blue-300",
    "text-indigo-300",
    "text-pink-300",
    "text-purple-300",
  ],
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    require("@tailwindcss/aspect-ratio"),
  ],
  darkMode: "class",
};
