import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import hooks from "./hooks";

let isVisible = (el) =>
  !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length > 0);

// Accessible focus handling

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks,
  dom: {
    onNodeAdded(node) {
      if (node instanceof HTMLElement && node.autofocus) {
        node.focus();
      }
    },
  },
});

let routeUpdated = () => {
  hooks.Focus.focusMain();
};

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });

window.addEventListener("phx:page-loading-start", (info) =>
  topbar.delayedShow(200)
);
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// Accessible routing
window.addEventListener("phx:page-loading-stop", routeUpdated);

window.addEventListener("js:exec", (e) =>
  e.target[e.detail.call](...e.detail.args)
);
window.addEventListener("js:focus", (e) => {
  let parent = document.querySelector(e.detail.parent);
  if (parent && isVisible(parent)) {
    e.target.focus();
  }
});
window.addEventListener("js:focus-closest", (e) => {
  let el = e.target;
  let sibling = el.nextElementSibling;
  while (sibling) {
    if (isVisible(sibling) && Focus.attemptFocus(sibling)) {
      return;
    }
    sibling = sibling.nextElementSibling;
  }
  sibling = el.previousElementSibling;
  while (sibling) {
    if (isVisible(sibling) && Focus.attemptFocus(sibling)) {
      return;
    }
    sibling = sibling.previousElementSibling;
  }
  Focus.attemptFocus(el.parent) || Focus.focusMain();
});
window.addEventListener("phx:remove-el", (e) =>
  document.getElementById(e.detail.id).remove()
);

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
