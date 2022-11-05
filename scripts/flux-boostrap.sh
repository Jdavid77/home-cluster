
flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=Jdavid77 \
  --repository=home-cluster \
  --branch=main \
  --path=k8s/clusters/server \
  --read-write-key \
  --token-auth
