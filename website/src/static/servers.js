"use strict";

// The edge polls the game servers and publishes what they answered beside this
// page. A server it has no data for, or does not list, is offline.
const refreshMs = 4000;
// The game's GAME_STATE_STARTUP and GAME_STATE_PREGAME: a server still starting
// up, and one waiting in the lobby for its round.
const startup = 0;
const pregame = 1;
const unlimited = "\u221e";

function duration(seconds) {
  const pad = (n) => String(n).padStart(2, "0");
  let text = `${pad(Math.floor(seconds / 60) % 60)}:${pad(Math.floor(seconds) % 60)}`;
  if (seconds >= 3600) text = `${pad(Math.floor(seconds / 3600) % 24)}:${text}`;
  if (seconds >= 86400) text = `${Math.floor(seconds / 86400)}:${text}`;
  return text;
}

function show(card, data) {
  const field = (name) => card.querySelector(`.Server__${name}`);
  card.classList.toggle("Server--Offline", !data);
  card.classList.toggle("Server--Startup", data?.gamestate === startup);
  card.classList.toggle("Server--Pregame", data?.gamestate === pregame);
  const commit = field("Flag--Commit");
  commit.hidden = !data;
  field("Flag--Hub").hidden = !data?.hub;
  if (!data) {
    field("GameMode").textContent = "Offline";
    field("CurrentPlayers").textContent = "--";
    field("MaxPlayers").textContent = "--";
    field("Timer").textContent = "--:--";
    return;
  }
  commit.textContent = data.revision.slice(0, 7);
  field("GameMode").textContent = `Playing ${data.version} - ${data.map_name}`;
  field("CurrentPlayers").textContent = data.players;
  field("MaxPlayers").textContent = data.popcap ?? unlimited;
  field("Timer").textContent = duration(data.round_duration);
}

async function refresh() {
  try {
    const response = await fetch("serverinfo.json");
    if (!response.ok) {
      throw new Error(`serverinfo.json: HTTP ${response.status}`);
    }
    const { servers } = await response.json();
    const data = new Map(servers.map((server) => [server.identifier, server.data]));
    for (const card of document.querySelectorAll(".Server[data-server]")) {
      show(card, data.get(card.dataset.server));
    }
  } catch (error) {
    console.error(error);
  }
  setTimeout(refresh, refreshMs);
}

refresh();
