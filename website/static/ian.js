"use strict";

// A random whole number of game pixels from -4 to 4, at twice the game's size.
const nudge = () => `${(Math.floor(Math.random() * 9) - 4) * 2}px`;

for (const ian of document.querySelectorAll(".Ian")) {
  ian.addEventListener("click", () => {
    ian.classList.add("Ian--Spinning");

    const heart = new Image(64, 64);
    heart.className = "Ian__Heart";
    heart.alt = "";
    heart.src = ian.dataset.heart;
    heart.style.setProperty("--x", nudge());
    heart.style.setProperty("--y", nudge());
    heart.addEventListener("animationend", () => heart.remove());
    ian.append(heart);
  });
  ian.addEventListener("animationend", (event) => {
    if (event.animationName === "IanSpin") {
      ian.classList.remove("Ian--Spinning");
    }
  });
}
