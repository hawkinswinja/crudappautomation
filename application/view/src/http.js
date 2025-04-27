import axios from 'axios'

let http = axios.create({
  baseURL: '/api',
  headers: {
    'Content-type': 'application/json',
  }
})

export default http