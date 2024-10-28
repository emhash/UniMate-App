// Need to use the React-specific entry point to import createApi
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'

// Define a service using a base URL and expected endpoints
export const userAuthApi = createApi({
  reducerPath: 'userAuthApi',
  baseQuery: fetchBaseQuery({ baseUrl: 'http://10.0.2.2:8000/' }),
  endpoints: (builder) => ({
    registerUser: builder.mutation({
      query:(user)=>{
        return {
          url:'/api/users/',
          method: 'POST',
          body: user,
          headers: {
            'Content-type':'application/json',
          }
        }
      }
    }),
  }),
})

export const { useRegisterUserMutation } = userAuthApi