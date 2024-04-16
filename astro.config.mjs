import { defineConfig } from 'astro/config'
import node from '@astrojs/node'
import alpinejs from '@astrojs/alpinejs'
import htmx from 'astro-htmx'

// https://astro.build/config
export default defineConfig({
  integrations: [alpinejs(), htmx()],
  output: 'server',
  adapter: node({
    mode: 'standalone',
  }),
})
