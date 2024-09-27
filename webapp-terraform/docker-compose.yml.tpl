version: '3'

services:
  backend:
    image: ${backend_image}
    environment:
      POSTGRES_DB: ${postgres_db}
      POSTGRES_USER: ${postgres_user}
      POSTGRES_PASSWORD: ${postgres_password}
      DATABASE_URL: jdbc:postgresql://postgres:5432/${postgres_db}
      REDIS_PROTOCOL: ${redis_protocol}
      REDIS_HOST: ${redis_host}
      REDIS_PORT: ${redis_port}
      REACT_APP_API_BASE_URL: ${react_app_api_base_url}
      MONGO_CURRENT_DATABASE: ${mongo_database}
      DEFAULT_SERVER_CLUSTER: ${default_server_cluster}
    depends_on:
      - postgres
      - redis
      - mongo

  frontend:
    image: ${frontend_image}
    environment:
      REACT_APP_API_BASE_URL: ${react_app_api_base_url}

  postgres:
    image: postgres:latest
    environment:
      POSTGRES_DB: ${postgres_db}
      POSTGRES_USER: ${postgres_user}
      POSTGRES_PASSWORD: ${postgres_password}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:latest

  mongo:
    image: mongo:latest
    volumes:
      - mongo_data:/data/db

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - frontend
      - backend

volumes:
  postgres_data:
  mongo_data:

networks:
  default:
    name: app-network