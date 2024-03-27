/// <reference types="astro/client" />

interface ImportMetaEnv {
  readonly ADMIN_ENDPOINT: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
