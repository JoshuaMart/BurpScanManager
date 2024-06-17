
```
echo "SECRET_KEY_BASE=$(tr -dc 'A-Z0-9' </dev/urandom | head -c 32)" >> .env
chmod +x ./bin/start.sh
docker compose up
docker compose exec www bundle exec rake db:setup
```