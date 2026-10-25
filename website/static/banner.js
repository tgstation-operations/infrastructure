"use strict";

for (const banner of document.querySelectorAll(".Banner__Image[data-banners]")) {
  const sources = banner.dataset.banners.trim().split(" ");
  banner.src = sources[Math.floor(Math.random() * sources.length)];
}
