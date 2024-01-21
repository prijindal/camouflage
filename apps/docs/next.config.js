const path = require("path");

/** @type {import('next').NextConfig} */
module.exports = {
  reactStrictMode: true,
  transpilePackages: ["@repo/ui"],
  basePath: process.env.BASE_PATH,
  experimental: {
    outputFileTracingRoot: path.join(__dirname, "../../"),
  },
};
