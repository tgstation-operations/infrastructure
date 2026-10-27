"use strict";

// The nav's menus open and close by themselves, as <details>. This closes the
// open one on a click outside it, when focus leaves it, or on Escape, and
// shifts its list back on screen where the menu sits near the edge of a narrow
// one.
const menus = document.querySelectorAll(".Menu");
const edgePx = 8;

for (const menu of menus) {
  menu.addEventListener("toggle", () => {
    const list = menu.querySelector(".Menu__List");
    list.style.translate = "";
    if (!menu.open) {
      return;
    }
    const { left, right } = list.getBoundingClientRect();
    const width = document.documentElement.clientWidth;
    const shift = Math.max(edgePx - left, 0) - Math.max(right - (width - edgePx), 0);
    list.style.translate = `${shift}px 0`;
  });
  menu.addEventListener("focusout", (event) => {
    if (!menu.contains(event.relatedTarget)) {
      menu.open = false;
    }
  });
}

document.addEventListener("click", (event) => {
  for (const menu of menus) {
    if (menu.open && !menu.contains(event.target)) {
      menu.open = false;
    }
  }
});

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") {
    return;
  }
  for (const menu of menus) {
    if (menu.open) {
      menu.open = false;
      menu.querySelector("summary").focus();
    }
  }
});
