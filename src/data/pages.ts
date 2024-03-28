import type { RootQuery } from './graphql'
import { fetchData, gql } from './fetcher'

type PageFetched = {
  data: Pick<RootQuery, 'page'>
}

export const fetchPage = async (id: string) => {
  return (await fetchData({
    query: gql`
      query fetchPageQuery($id: ID!) {
        page(id: $id, idType: URI) {
          title
          uri
          content
          featuredImage {
            node {
              sourceUrl
            }
          }
        }
      }
    `,
    variables: {
      id,
    },
  })) as PageFetched
}
