import 'dotenv/config'
import { defineConfig } from 'astro/config'
import node from '@astrojs/node'

// https://astro.build/config
export default defineConfig({
  site: process.env.SITE_URL,
  output: 'server',
  adapter: node({
    mode: 'standalone',
  }),
  image: {
    domains: [new URL(process.env.SITE_URL).hostname],
  },
})
