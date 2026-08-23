docker run --rm -p 8080:8080 \
  -e DB_URL='postgres://username:password@host.docker.internal:5432/fitbyte?sslmode=disable' \
  -e TOKEN_SECRET='replace-me' \
  -e TOKEN_DURATION='3600' \
  -e ADMIN_KEY='replace-me' \
  fitbyte:local