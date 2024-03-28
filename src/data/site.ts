import type { RootQuery } from './graphql'
import { fetchData, gql } from './fetcher'

type LogoFetched = {
  data: Pick<RootQuery, 'mediaItems'>
}

export const fetchLogo = async () => {
  return (await fetchData({
    query: gql`
      query fetchLogoQuery {
        mediaItems(where: { title: "logo" }) {
          nodes {
            sourceUrl
          }
        }
      }
    `,
  })) as LogoFetched
}
