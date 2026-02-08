import { defineConfig } from "astro/config";

import icon from "astro-icon";
import sitemap from "@astrojs/sitemap";
import tailwind from "@astrojs/tailwind";
import svelte from "@astrojs/svelte";
import react from "@astrojs/react";

import rehypeSlug from "rehype-slug";
import rehypeKatex from "rehype-katex";
import rehypeAutolinkHeadings from "rehype-autolink-headings";
import remarkMath from "remark-math";
import { remarkReadingTime } from "./src/plugins/remark-reading-time.mjs";

import YukinaConfig from "./yukina.config";
import pagefind from "astro-pagefind";

// https://astro.build/config
export default defineConfig({
  base: "/",
  site: "https://serendibecolab.github.io",
  output: "static",
  image: {
    service: {
      entrypoint: "astro/assets/services/sharp",
    },
  },
  integrations: [
    tailwind(),
    svelte(),
    react(),
    icon({
      include: {
        "line-md": ["*"],
        mdi: ["*"],
      },
    }),
    // Temporarily remove swup to test if it's the cause
    // swup({
    //   theme: false,
    //   containers: ["main", "footer", ".banner-inner"],
    //   smoothScrolling: true,
    //   progress: true,
    //   cache: true,
    //   preload: true,
    //   updateHead: true,
    //   updateBodyClass: false,
    //   globalInstance: true,
    //   scroll: {
    //     enabled: true,
    //     offset: 800,
    //   },
    //   doScrollingRightAfterAnimation: true,
    // }),
    sitemap(),
    pagefind(),
  ],
  markdown: {
    shikiConfig: {
      theme: "github-dark-default",
    },
    remarkPlugins: [remarkReadingTime, remarkMath],
    rehypePlugins: [
      rehypeSlug,
      rehypeKatex,
      [
        rehypeAutolinkHeadings,
        {
          behavior: "prepend",
        },
      ],
    ],
  },
  scopedStyleStrategy: "where",
  vite: {
    build: {
      assetsInlineLimit: 0,
    },
    optimizeDeps: {},
  },
});
