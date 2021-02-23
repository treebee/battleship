export default {
  mounted() {
    window.dragHook = this;
  },
  destroyed() {
    window.modalHook = null;
  },
  dragStart(event) {
    this.ship = {
      id: event.target.id,
      size: +event.target.dataset.size,
      direction: event.target.dataset.direction,
    };
  },
  dropShip(event, x, y) {
    event.preventDefault();
    this.pushEvent("add_ship", {
      x,
      y,
      ...this.ship,
    });
    this.ship = null;
  },
};
