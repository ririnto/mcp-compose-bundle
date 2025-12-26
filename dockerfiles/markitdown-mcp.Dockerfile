# syntax=docker/dockerfile:1
FROM python:3.13-slim

WORKDIR /workdir
RUN apt-get update
RUN apt-get install -y ffmpeg exiftool
RUN python -m pip install --upgrade pip
RUN python -m pip install markitdown-mcp
EXPOSE 3001
ENTRYPOINT ["markitdown-mcp"]
CMD ["--http", "--host", "0.0.0.0"]
