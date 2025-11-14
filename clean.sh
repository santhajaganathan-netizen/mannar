dop container stop medusa-storefront || true
dop container rm medusa-storefront || true
dop container stop medusa-backend || true
dop container rm medusa-backend || true
dop container stop medusa_postgres || true
dop container rm medusa_postgres || true
docker rmi medusa-storefront-img || true
docker rmi medusa-backend-img || true
docker rmi medusa-db-img || true
