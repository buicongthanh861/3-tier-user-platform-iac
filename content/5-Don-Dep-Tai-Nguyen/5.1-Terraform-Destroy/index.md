cd terraform
terraform destroy

Xóa toàn bộ cluster, network, node group và các tài nguyên AWS do Terraform quản lý. Chỉ chạy khi đã chắc chắn, vì thao tác không thể hoàn tác.

Ghi chú vận hành
Image frontend/backend lấy từ ECR, khai báo trong k8s/*/values.yaml — cần cập nhật image.tag khi có bản build mới (đây là điểm nối với pipeline CD).
MySQL StatefulSet yêu cầu PVC 5Gi, ReadWriteOnce; k8s/database/values.yaml khai báo storageClass: gp3 nhưng template hiện vẫn dùng cứng gp2 — cần đồng bộ lại nếu muốn cấu hình qua values.
Không commit terraform.tfstate, file tfvars hoặc secret thật; nên chuyển sang remote backend có encryption và locking.
Repo hiện chưa có backup/restore hoặc replication cho MySQL StatefulSet.
