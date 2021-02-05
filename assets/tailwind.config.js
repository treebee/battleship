module.exports = {
  theme: {
    container: {
      center: true,
    },
    extend: {
      gridTemplateColumns: {
        10: "repeat(10, 2rem)",
      },
    },
  },
  variants: {
    extend: {
      opacity: ["disabled"],
    },
  },
  purge: {
    enabled: process.env.NODE_ENV === "production",
    content: ["../lib/**/*.eex", "../lib/**/*.leex", "../lib/**/*_view.ex"],
    options: {
      whitelist: [/phx/, /nprogress/],
    },
  },
};
