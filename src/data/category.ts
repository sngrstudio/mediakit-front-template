import type { RootQuery } from './graphql'
import { fetchData, gql } from './fetcher'

type CategoryFetched = {
  data: Pick<RootQuery, 'category'>
}

export const fetchCategory = async (id: string) => {
  return (await fetchData({
    query: gql`
      query fetchCategoryQuery($id: ID!) {
        category(id: $id, idType: URI) {
          name
          description
        }
      }
    `,
    variables: {
      id,
    },
  })) as CategoryFetched
}
