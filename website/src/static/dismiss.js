"use strict";

// A dismissed block stays hidden for this reader until its key changes, which
// for an alert is its message.
for (const block of document.querySelectorAll("[data-dismiss]")) {
  const key = block.dataset.dismiss;
  if (localStorage.getItem(key) === "hidden") {
    block.hidden = true;
    continue;
  }
  const dismiss = block.querySelector(".Dismiss");
  dismiss.hidden = false;
  dismiss.addEventListener("click", () => {
    localStorage.setItem(key, "hidden");
    block.hidden = true;
  });
}
