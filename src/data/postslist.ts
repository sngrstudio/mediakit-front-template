import type { RootQuery } from './graphql'
import { fetchData, gql } from './fetcher'

type PostsListFetched = {
  data: Pick<RootQuery, 'posts'>
}

export const fetchPostsList = async ({
  category,
  after = '',
  first = 12,
}: {
  category: string
  after?: string
  first?: number
}) => {
  return (await fetchData({
    query: gql`
      query fetchPostsListQuery(
        $categoryName: String
        $first: Int
        $after: String
      ) {
        posts(
          where: { categoryName: $categoryName }
          first: $first
          after: $after
        ) {
          nodes {
            title
            date
            excerpt
            uri
            featuredImage {
              node {
                sourceUrl
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    `,
    variables: {
      categoryName: category,
      first,
      after,
    },
  })) as PostsListFetched
}
