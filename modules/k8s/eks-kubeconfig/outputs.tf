output "s3_location" {
  value = "${aws_s3_bucket_object.kube_config_object.bucket}/${aws_s3_bucket_object.kube_config_object.key}"
}

output "kube_config_raw" {
  value = data.null_data_source.kube_config_raw.outputs["content"]
}