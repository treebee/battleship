// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import Drag from "./dragHook";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
const Hooks = {
  Drag,
};

let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to);
      }
    },
  },
  params: {
    _csrf_token: csrfToken,
  },
  hooks: Hooks,
});
// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

const findNeighbors = (x, y) => {
  const coords = [];
  for (let i = -1; i < 2; ++i) {
    for (let j = -1; j < 2; ++j) {
      if (
        x + i < 0 ||
        y + j < 0 ||
        x + i > 9 ||
        y + j > 9 ||
        (i === 0 && j === 0)
      )
        continue;
      coords.push({ x: x + i, y: y + j });
    }
  }
  return coords.map(({ x, y }) => {
    return `#cell-${x}-${y}`;
  });
};
window.highlightCells = (event, { weapon }) => {
  const x = +event.target.getAttribute("phx-value-x");
  const y = +event.target.getAttribute("phx-value-y");
  const ids = [event.target.id]; //.classList.add("bg-blue-900");
  if (weapon == "airstrike") {
    findNeighbors(x, y).forEach((id) => {
      ids.push(id);
    });
  }
  ids.forEach((id) => {
    document.getElementById(id.replace("#", "")).classList.add("bg-blue-900");
  });
  event.target.onmouseleave = () => {
    ids.forEach((id) => {
      document
        .getElementById(id.replace("#", ""))
        .classList.remove("bg-blue-900");
    });
  };
};
