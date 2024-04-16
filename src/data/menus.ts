import type { RootQuery, MenuLocationEnum } from './graphql'
import { fetchData, gql } from './fetcher'

type MenuFetched = {
  data: Pick<RootQuery, 'menus'>
}

export const fetchMenu = async (location: MenuLocationEnum) => {
  return (await fetchData({
    query: gql`
      query fetchMenuQuery($location: MenuLocationEnum!) {
        menus(where: { location: $location }) {
          nodes {
            menuItems {
              nodes {
                label
                uri
              }
            }
          }
        }
      }
    `,
    variables: {
      location,
    },
  })) as MenuFetched
}
