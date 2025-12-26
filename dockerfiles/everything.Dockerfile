# syntax=docker/dockerfile:1
FROM node:24-alpine

RUN npm install -g @modelcontextprotocol/server-everything
EXPOSE 3001
ENTRYPOINT ["mcp-server-everything"]
CMD ["streamableHttp"]
