import type { RootQuery } from './graphql'
import { fetchData, gql } from './fetcher'

type PostFetched = {
  data: Pick<RootQuery, 'post'>
}

export const fetchPost = async (id: string) => {
  return (await fetchData({
    query: gql`
      query fetchPostQuery($id: ID!) {
        post(id: $id, idType: URI) {
          title
          date
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
  })) as PostFetched
}
