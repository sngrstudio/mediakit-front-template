const GRAPHQL_ENDPOINT = `${import.meta.env.DEV ? import.meta.env.ADMIN_ENDPOINT : process.env.ADMIN_ENDPOINT}/wp/graphql`

export const gql = String.raw
export const fetchData = async ({
  query,
  variables,
}: {
  query: ReturnType<typeof gql>
  variables?: Record<string, string | number>
}) => {
  try {
    const response = await fetch(GRAPHQL_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        query,
        variables,
      }),
    })

    const json = await response.json()
    if (json.errors) {
      json.errors.map((err: any) => {
        throw new Error(err.message)
      })
    }
    return json
  } catch (error) {
    console.error(error)
    return null
  }
}
