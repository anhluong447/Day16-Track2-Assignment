# BÁO CÁO THỰC HÀNH LAB 16: CLOUD AI ENVIRONMENT SETUP

**Họ và tên:** Lương Hoàng Anh
**Mã sinh viên:** 2A202600472

## 1. Mục tiêu bài lab
Triển khai hạ tầng Cloud AI (Machine Learning) trên AWS bằng Terraform, sử dụng mô hình mạng Private VPC, Bastion Host, NAT Gateway và Application Load Balancer.

## 2. Phương án thực hiện
- **Lý do thay đổi:** Do tài khoản AWS mới bị giới hạn Quota GPU (0 vCPU), em đã chuyển sang phương án dự phòng sử dụng Instance CPU `t3.micro`.
- **Hạ tầng:** 
    - VPC với Public/Private Subnets.
    - Bastion Host cho quản trị.
    - ML Node (CPU) chạy FastAPI + LightGBM.
    - ALB điều phối traffic cổng 80 -> 8000.

## 3. Kết quả đạt được
- **Triển khai tự động:** Hạ tầng được khởi tạo hoàn chỉnh bằng Terraform.
- **API Inference:** Model LightGBM được train tự động và cung cấp API dự đoán.
- **Xác thực:** Đã gọi API thành công qua Load Balancer bằng lệnh `Invoke-RestMethod`.

## 4. Minh chứng (Screenshots)
- **API Success:** Xem file `CMD Proof.png`
- **EC2 Instances:** Xem file `EC2.png`
- **NAT Gateway:** Xem file `NAT.png`
- **Load Balancer:** Xem file `Load_balancer.png`

## 5. Kết luận
Bài lab đã giúp em hiểu rõ cách quản lý hạ tầng Cloud bằng mã nguồn (IaC), cách thiết lập mạng an toàn trên AWS và cách triển khai một dịch vụ Machine Learning thực tế lên môi trường Production.
