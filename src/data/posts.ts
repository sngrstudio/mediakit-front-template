import type { RootQuery } from './graphql'
import { fetchData, gql } from './fetcher'

type PostsFetched = {
  data: Pick<RootQuery, 'posts'>
}

export const fetchAllPosts = async () => {
  const res = await fetchData({
    query: gql`
      query fetchAllPostsQuery {
        posts {
          nodes {
            title
            date
            excerpt
            featuredImage {
              node {
                sourceUrl
              }
            }
            content
          }
        }
      }
    `,
  })

  const data: PostsFetched = (await res.json()) as PostsFetched
  return data.data.posts?.nodes
}

type PostFetched = {
  data: Pick<RootQuery, 'post'>
}

export const fetchPost = async (id: string) => {
  const res = await fetchData({
    query: gql`
      query fetchPostQuery($id: ID!) {
        post(id: $id, idType: URI) {
          title
          date
          uri
          content
        }
      }
    `,
    variables: {
      id,
    },
  })

  const data: PostFetched = (await res.json()) as PostFetched
  return data.data.post
}
