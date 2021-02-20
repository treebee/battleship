module.exports = {
  theme: {
    container: {
      center: true,
      screens: {
        sm: "100%",
        md: "100%",
        lg: "1024px",
        xl: "1024px",
      },
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
