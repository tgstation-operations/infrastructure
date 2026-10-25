# tgstation13.org

The landing page of [tgstation13.org](https://tgstation13.org) and its
newsletters, built with [Zola](https://www.getzola.org). The server cards fill
themselves in from `serverinfo.json`, which tgstation13.org keeps up to date
from the game servers.

## Make your own copy

You can put your own version of the page on GitHub Pages, with made-up server
data, without installing anything:

1. Fork this repository.
2. In your fork, open Settings, then Pages, and set Source to GitHub Actions.
3. Open the Actions tab and enable workflows. This enables the repository's
   other workflows too, which build and deploy tgstation's servers and have
   nothing to do in a fork; you can disable all of them but Website.
4. Edit something under `website/` on your fork's `main` branch, or run the
   Website workflow from the Actions tab.
5. When the workflow finishes, the page is at
   `https://<your-username>.github.io/<your-fork>/`.

Every change you push to `main` under `website/` publishes again.

## What is where

- `content/_index.md`: the servers on the page, any alerts above them, and the
  banners under them.
- `content/newsletters/`: one directory per newsletter, with its `index.md` and
  its pictures. The front page shows the three newest.
- `templates/`: the page itself.
- `sass/`: the styles.
- `static/`: images, fonts, and the scripts: `servers.js` fills in the server
  cards, `dismiss.js` lets a reader dismiss an alert or the introduction,
  `banner.js` picks a banner, and `ian.js` pets Ian.
- `sprites/`: the list of the sprites in `static/sprites/`, and `cut.py`, which
  cuts them out of tgstation's icons.
- `mock/serverinfo.json`: the made-up server data your copy shows. Set a
  server's `data` to `null` to see it go offline.

When you have a change you would like on tgstation13.org, open a pull request
against this repository.
