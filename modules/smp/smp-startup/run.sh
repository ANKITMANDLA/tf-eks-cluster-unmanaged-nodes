#! /bin/bash
k8s_config_raw="$1"
priority_class_yaml="$2"
priority_patch_yaml="$3"


if [[ -z "${k8s_config_raw}" ]] || [[ -z "${priority_class_yaml}" ]] || [[ -z "${priority_patch_yaml}" ]]; then
  echo "Missing parameters."
  exit 1
fi

workspace_dir=`mktemp -d -t terraform-exec-XXXXXXXX`
trap "{ echo \"Cleaning up workspace ${workspace_dir}\"; rm -rf ${workspace_dir}; }" EXIT

echo "${k8s_config_raw}" > ${workspace_dir}/kube-config.yaml
# sed -i '/- -r/ d' ${workspace_dir}/kube-config.yaml || exit 1
# sed -i '/arn:aws:iam/ d' ${workspace_dir}/kube-config.yaml || exit 1
export KUBECONFIG=${workspace_dir}/kube-config.yaml || exit 1
#wait for kube to be ready
echo "Waiting for kube connectivity"
count=-1
while true; do
  kubectl get pods > /dev/null 2>&1
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

function setup_priority(){
  local _type="$1"
  local _objects=$(kubectl get ${_type} | tail -n+2)
  IFS=$'\n'
  for _object in ${_objects}; do
    local _result=""
    local _name=$(echo ${_object} | awk '{print $1}')
    if [ "${_type}" == "statefulset" ]; then
    _result=$(kubectl get ${_type} ${_name} -o jsonpath="{.spec.volumeClaimTemplates}")
    fi

    if [ "${_type}" == "deployment" ]; then
    _result=$(kubectl get ${_type} ${_name} -o jsonpath="{.spec.template.spec.volumes[*].persistentVolumeClaim}")
    fi

    if [ "$_result" != "" ]; then
      echo "PVC found in ${_type} ${_name}"
      echo "Patching ${priority_patch_yaml}"
      kubectl patch ${_type} ${_name} -p "${priority_patch_yaml}"
    fi
  done
}

echo "${priority_class_yaml}" | kubectl apply -f -

setup_priority "statefulset"
setup_priority "deployment"