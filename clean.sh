dop container stop medusa-db
dop container rm medusa-db
dop container stop medusa-backend
dop container rm medusa-backend
docker rmi medusa-db-img
docker rmi medusa-backend-img