# Input bucket
resource "google_storage_bucket" "input_bucket" {
  name     = "${var.project_id}-input-bucket"
  project  = var.project_id
  location = var.region

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }

  force_destroy = true  # Allows Terraform to delete non-empty buckets if needed
}

# Create local text files and upload them to the input bucket
resource "null_resource" "upload_input_files" {
  # This ensures it only runs after the bucket is created
  depends_on = [google_storage_bucket.input_bucket]

  # Create and upload files
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ./input-data
      echo "Hello Cloud Infrastructure" > ./input-data/file1.txt
      echo "Hadoop MapReduce" > ./input-data/file2.txt
      echo "Dataproc Cluster" > ./input-data/file3.txt
      gsutil cp ./input-data/*.txt gs://${google_storage_bucket.input_bucket.name}/input-data/
    EOT
  }
}


# Output bucket
resource "google_storage_bucket" "output_bucket" {
  name     = "${var.project_id}-output-bucket"
  project  = var.project_id
  location = var.region

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }

  force_destroy = true  # Allows Terraform to delete non-empty buckets if needed
}
