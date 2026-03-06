PG_BASE="tsdc/postgres:15.7-v2"
IMAGE="tsdc/openshift-patroni:15.7-v6"


set -e

cd postgres-base
sudo docker build -t "$PG_BASE" .
sudo docker push "$PG_BASE"

cd ../patroni-openshift
sudo docker build -t "$IMAGE" .
sudo docker push "$IMAGE"
