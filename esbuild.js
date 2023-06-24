#!/usr/bin/env node

const esbuild = require("esbuild");

const esbuild_config = {
    logLevel: "info",
    entryPoints: ["app/public/main.js"],
    bundle: true,
    minify: true,
    sourcemap: true,
    plugins: [],
    loader: {
      ".woff": "file",
      ".woff2": "file",
      ".ttf": "file",
    },
    outfile: "app/public/builds/main.js",
}

if (process.argv.at(-1) == "watch") {
  async function watch() {
    let ctx = await esbuild.context(esbuild_config);
    await ctx.watch();
    console.log('Watching...');
  }
  watch();
} else {
  esbuild.build(esbuild_config).catch(() => process.exit(1));
}

