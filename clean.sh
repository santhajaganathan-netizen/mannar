dop container stop medusa-store
dop container rm medusa-store
dop container stop medusa-backend
dop container rm medusa-backend
dop container stop medusa-db
dop container rm medusa-db
docker rmi medusa-store-img
docker rmi medusa-backend-img
docker rmi medusa-db-img
