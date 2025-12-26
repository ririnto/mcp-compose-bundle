# syntax=docker/dockerfile:1
FROM node:24-alpine

RUN npm install -g @upstash/context7-mcp
ENV MCP_CONTEXT7_API_KEY=""
EXPOSE 3000
ENTRYPOINT ["context7-mcp"]
CMD ["--transport", "http", "--port", "3000"]
