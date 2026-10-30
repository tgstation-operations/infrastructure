import path from "node:path";
import { HtmlBasePlugin } from "@11ty/eleventy";
import * as sass from "sass";
import * as fs from 'fs';
import * as yaml from 'js-yaml';

export const config = {
  dir: {
    input: "src",
  },
};

//Loads data from a yaml file
function readDataFile(filename, fallback) {
  const filePath = fs.existsSync(filename) ? filename : fallback;
  return yaml.load(fs.readFileSync(filePath, "utf-8"));
}

export default function (eleventyConfig) {
  // Adds --pathprefix to root-relative URLs, for a GitHub Pages project path.
  eleventyConfig.addPlugin(HtmlBasePlugin);
  eleventyConfig.addPassthroughCopy({ "src/static": "/" });
  eleventyConfig.addPassthroughCopy("src/newsletters/**/*.webp");

  const alertsData = readDataFile("alerts.yaml", "example-alerts.yaml");
  eleventyConfig.addGlobalData("alerts", alertsData);


  // A newsletter's pictures show on the front page too, where their relative
  // URLs would not resolve, so they are made root-relative from its URL. They
  // load lazily, as the front page carries three newsletters' worth.
  eleventyConfig.amendLibrary("md", (md) => {
    const image = md.renderer.rules.image;
    md.renderer.rules.image = (tokens, idx, options, env, self) => {
      const base = new URL(env.page.url, "https://site.invalid");
      const src = new URL(tokens[idx].attrGet("src"), base);
      tokens[idx].attrSet("src", src.origin === base.origin ? src.href.slice(src.origin.length) : src.href);
      tokens[idx].attrSet("loading", "lazy");
      tokens[idx].attrSet("decoding", "async");
      return image(tokens, idx, options, env, self);
    };
  });

  // YAML reads a newsletter's bare date as midnight UTC.
  eleventyConfig.addFilter("monthYear", (date) =>
    date.toLocaleDateString("en-US", { month: "long", year: "numeric", timeZone: "UTC" }),
  );
  eleventyConfig.addFilter("isoDate", (date) => date.toISOString().slice(0, 10));

  eleventyConfig.addTemplateFormats("scss");
  eleventyConfig.addExtension("scss", {
    outputFileExtension: "css",
    compileOptions: {
      // main.css goes to the root, beside the fonts and images it refers to
      // relative to itself. The partials only go into it.
      permalink: (contents, inputPath) => {
        const { name } = path.parse(inputPath);
        return name.startsWith("_") ? false : `/${name}.css`;
      },
    },
    compile: (contents, inputPath) => {
      const { css } = sass.compile(inputPath, { style: "compressed" });
      return () => css;
    },
  });
}
