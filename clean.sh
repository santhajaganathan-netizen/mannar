docker container stop medusa-storefront || true
docker container rm medusa-storefront || true
docker container stop medusa-backend || true
docker container rm medusa-backend || true
docker container stop medusa-db || true
docker container rm medusa-db || true
docker rmi medusa-storefront-img || true
docker rmi medusa-backend-img || true
docker rmi medusa-db-img || true
