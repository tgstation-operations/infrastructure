"use strict";

for (const artwork of document.querySelectorAll(".Artwork__Image[data-artwork]")) {
  const sources = artwork.dataset.artwork.trim().split(" ");
  artwork.src = sources[Math.floor(Math.random() * sources.length)];
}
