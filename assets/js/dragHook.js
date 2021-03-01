export default {
  mounted() {
    this.el.ondrop = (event) => {
      event.preventDefault();
      const ship = JSON.parse(event.dataTransfer.getData("text/plain"));
      const x = event.target.getAttribute("phx-value-x");
      const y = event.target.getAttribute("phx-value-y");
      if (ship && ship.direction && ship.id && ship.size && x && y) {
        this.pushEvent("add_ship", {
          x: +x,
          y: +y,
          ...ship,
        });
      }
    };
    this.el.ondragover = (event) => {
      event.currentTarget.classList.add("bg-blue-900");
    };
    this.el.ondragleave = (event) => {
      event.currentTarget.classList.remove("bg-blue-900");
    };
  },
  destroyed() {
    window.dragHook = null;
  },
};

export const dragStart = (event) => {
  event.dataTransfer.setData(
    "text/plain",
    JSON.stringify({
      id: event.target.id,
      size: +event.target.getAttribute("phx-value-size"),
      direction: event.target.getAttribute("phx-value-direction"),
    })
  );
};
