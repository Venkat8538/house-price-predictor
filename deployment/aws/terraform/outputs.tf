output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.airflow_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.airflow_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.airflow_server.public_dns
}

output "airflow_url" {
  description = "Airflow web UI URL"
  value       = "http://${aws_eip.airflow_eip.public_ip}:8080"
}

output "mlflow_url" {
  description = "MLflow web UI URL"
  value       = "http://${aws_eip.airflow_eip.public_ip}:5555"
}

output "fastapi_url" {
  description = "FastAPI URL"
  value       = "http://${aws_eip.airflow_eip.public_ip}:8000"
}

output "streamlit_url" {
  description = "Streamlit URL"
  value       = "http://${aws_eip.airflow_eip.public_ip}:8501"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.airflow_eip.public_ip}"
}