#! /bin/bash

k8s_yaml="$1"
k8s_config_raw="$2"
if [[ -z ${k8s_yaml} ]] || [[ -z ${k8s_config_raw} ]]; then
  echo "Missing parameters."
  exit 1
fi

workspace_dir=`mktemp -d -t terraform-exec-XXXXXXXX`
trap "{ echo \"Cleaning up workspace ${workspace_dir}\"; rm -rf ${workspace_dir}; }" EXIT

echo "${k8s_yaml}" > ${workspace_dir}/k8s-access.yaml
echo "${k8s_config_raw}" > ${workspace_dir}/kube-config.yaml
sed -i '/- -r/ d' ${workspace_dir}/kube-config.yaml || exit 1
sed -i '/arn:aws:iam/ d' ${workspace_dir}/kube-config.yaml || exit 1
export KUBECONFIG=${workspace_dir}/kube-config.yaml || exit 1
#wait for kube to be ready
echo "Waiting for kube connectivity"
count=-1
while true; do
  kubectl get pods
  if [[ $? -eq 0 ]];then
    break
  fi
  count=$[${count}+1]
  if [[ ${count} -eq 120 ]];then
    echo "Taking too long to connect to kube..."
    exit 1
  fi
  sleep 5
done

kubectl apply -f  ${workspace_dir}/k8s-access.yaml || exit 1