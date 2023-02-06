apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::035343832406:role/Sigma_EKSNodeInstanceRole
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${CLUSTER_ACCESS_ROLE}
      username: ${USERNAME}
      groups:
        - system:masters