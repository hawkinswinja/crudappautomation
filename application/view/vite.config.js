import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    proxy: {
      '/api/Auth': {
        target: 'http://localhost:5036',
        changeOrigin: true,
        // rewrite: (path) => path.replace(/^\/api/, ''),
      },
      '/api/': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        // rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
});