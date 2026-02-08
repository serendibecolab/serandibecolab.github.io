import I18nKeys from "./src/locales/keys";
import type { Configuration } from "./src/types/config";

const YukinaConfig: Configuration = {
  title: "Serendib eco lab",
  subTitle: "Sakuna Template Demo Site",
  brandTitle: "Serendib eco lab",

  description: "Demo Site",

  site: "https://serendibecolab.com",

  locale: "en",

  navigators: [
    {
      nameKey: I18nKeys.nav_bar_home,
      href: "/",
    },
    {
      nameKey: I18nKeys.nav_bar_blog,
      href: "/blog",
    },
    {
      nameKey: I18nKeys.nav_bar_archive,
      href: "/archive",
    },
    {
      nameKey: I18nKeys.nav_bar_about,
      href: "/about",
    },
  ],

  username: "Sakuna",
  sign: "BTechIOI",
  avatarUrl: "/images/IMG_8817.webp",
  socialLinks: [
    {
      icon: "line-md:github-loop",
      link: "https://github.com/WhitePaper233",
    },
    {
      icon: "mingcute:bilibili-line",
      link: "https://space.bilibili.com/22433608",
    },
    {
      icon: "mingcute:netease-music-line",
      link: "https://music.163.com/#/user/home?id=125291648",
    },
  ],
  maxSidebarCategoryChip: 6,
  maxSidebarTagChip: 12,
  maxFooterCategoryChip: 6,
  maxFooterTagChip: 24,

  banners: [
    { src: "/images/IMG-20251109-WA0004.jpg", focalPoint: "center", textLines: ["First banner line 1", "First banner line 2", "First banner line 3", "First banner line 4"] },
    { src: "/images/IMG-20251109-WA0005.jpg", focalPoint: "center", textLines: ["Second banner line 1", "Second banner line 2", "Second banner line 3", "Second banner line 4"] },
    { src: "/images/IMG-20251109-WA0006.jpg", focalPoint: "center", textLines: ["Third banner line 1", "Third banner line 2", "Third banner line 3", "Third banner line 4"] },
    { src: "/images/IMG-20251109-WA0007.jpg", focalPoint: "center", textLines: ["Fourth banner line 1", "Fourth banner line 2", "Fourth banner line 3", "Fourth banner line 4"] },
    { src: "/images/IMG-20251109-WA0008.jpg", focalPoint: "center", textLines: ["Fifth banner line 1", "Fifth banner line 2", "Fifth banner line 3", "Fifth banner line 4"] },
    { src: "/images/IMG-20251109-WA0009.jpg", focalPoint: "center", textLines: ["Sixth banner line 1", "Sixth banner line 2", "Sixth banner line 3", "Sixth banner line 4"] },
    { src: "/images/IMG_7461.webp", focalPoint: "center", textLines: ["Seventh banner line 1", "Seventh banner line 2", "Seventh banner line 3", "Seventh banner line 4"] },
    { src: "/images/IMG_9468.webp", focalPoint: "center", textLines: ["Eighth banner line 1", "Eighth banner line 2", "Eighth banner line 3", "Eighth banner line 4"] },
    { src: "/images/IMG_9499.webp", focalPoint: "center", textLines: ["New Banner 1 Line 1", "New Banner 1 Line 2", "New Banner 1 Line 3", "New Banner 1 Line 4"] },
    { src: "/images/IMG_9516.webp", focalPoint: "center", textLines: ["New Banner 2 Line 1", "New Banner 2 Line 2", "New Banner 2 Line 3", "New Banner 2 Line 4"] },
  ],

  secondBanners: [
    { src: "/images/IMG_9530.webp", focalPoint: "center", textLines: ["Second Banner Set 1 Line 1", "Second Banner Set 1 Line 2", "Second Banner Set 1 Line 3", "Second Banner Set 1 Line 4"] },
    { src: "/images/IMG_9542.webp", focalPoint: "center", textLines: ["Second Banner Set 2 Line 1", "Second Banner Set 2 Line 2", "Second Banner Set 2 Line 3", "Second Banner Set 2 Line 4"] },
  ],

  slugMode: "HASH",

  license: {
    name: "CC BY-NC-SA 4.0",
    url: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
  },

  bannerStyle: "LOOP",

  homepageGridItems: [
    {
      src: "/images/IMG_8938.webp",
      alt: "Cat",
      title: "Cat",
      description: "A short description for Cat.",
      href: "/grid-items/example-1",
      size: 'small',
    },
    {
      src: "/images/IMG_9763.webp",
      alt: "Grid Item 2",
      title: "Grid Item 2",
      description: "A short description for grid item 2, spanning two columns.",
      href: "/grid-items/example-2",
      size: 'medium',
    },
    {
      src: "/images/IMG_7115.webp",
      alt: "Grid Item 3",
      title: "Grid Item 3",
      description: "A short description for grid item 3, spanning two rows and two columns.",
      href: "/grid-items/example-3",
      size: 'large',
    },
    {
      src: "/images/IMG_9537.webp",
      alt: "Grid Item 4",
      title: "Grid Item 4",
      description: "A short description for grid item 4.",
      href: "/grid-items/example-4",
      size: 'small',
    },
    {
      src: "/images/IMG_9498.webp",
      alt: "Grid Item 5",
      title: "Grid Item 5",
      description: "A short description for grid item 5, spanning two columns.",
      href: "/grid-items/example-5",
      size: 'medium',
    },
    {
      src: "/images/IMG_9069.webp",
      alt: "Grid Item 6",
      title: "Grid Item 6",
      description: "A short description for grid item 6.",
      href: "/grid-items/example-6",
      size: 'small',
    },
  ],

  homepageServiceCards: [
    {
      title: "Web Development",
      description: "Building modern, responsive, and performant web applications.",
      coverImage: "/images/IMG-20251109-WA0004.jpg",
      href: "/services/web-development",
    },
    {
      title: "Mobile App Development",
      description: "Creating intuitive and powerful mobile experiences for iOS and Android.",
      coverImage: "/images/IMG_9468.webp",
      href: "/services/mobile-app-development",
    },
    {
      title: "UI/UX Design",
      description: "Crafting beautiful and user-friendly interfaces that delight users.",
      coverImage: "/images/IMG_9498.webp",
      href: "/services/ui-ux-design",
    },
    {
      title: "Cloud Solutions",
      description: "Leveraging cloud platforms for scalable and reliable infrastructure.",
      coverImage: "/images/IMG_9723.webp",
      href: "/services/cloud-solutions",
    },
    {
      title: "Data Analytics",
      description: "Transforming raw data into actionable insights for informed decisions.",
      coverImage: "/images/IMG_9594.webp",
      href: "/services/data-analytics",
    },
    {
      title: "DevOps & Automation",
      description: "Streamlining development workflows and automating deployments.",
      coverImage: "/images/IMG_7447.webp",
      href: "/services/devops-automation",
    },
  ],
};

export default YukinaConfig;