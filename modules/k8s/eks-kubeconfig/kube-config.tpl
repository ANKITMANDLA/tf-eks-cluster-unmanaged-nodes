apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CERTIFICATE_DATA}
    server: ${URL}
  name: ${CLUSTER_NAME}-englan
contexts:
- context:
    cluster: ${CLUSTER_NAME}-englan
    user: aws
  name: ${CLUSTER_NAME}-englan
current-context: ${CLUSTER_NAME}-englan
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - token
      - -i
      - ${CLUSTER_NAME}
      - -r
      - ${CLUSTER_ACCESS_ROLE}
      command: aws-iam-authenticator
