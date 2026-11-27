import type { NextConfig } from "next";

/** Site 100% estático: pode ser hospedado em qualquer lugar (inclusive no servidor da FAP). */
const config: NextConfig = {
  output: "export",
  images: { unoptimized: true },
  basePath: process.env.NEXT_PUBLIC_BASE_PATH ?? "",
};

export default config;
