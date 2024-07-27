# Ngày thứ 2, deep dive vào Lambda.

- Mục đích của phần này nhằm:
  - Concept của MicroVM và một vài framework opensource
  - Tìm hiểu rõ hơn về Lambda: Cách thức hoạt động, lifecycle, các giới hạn của Lambda
  - Triển khai một services tự động xóa background của ảnh

### Concept của MicroVM và một vài framework opensource.
MicroVMs (Micro Virtual Machines) là các máy ảo nhỏ gọn, được tối ưu hóa để chạy các ứng dụng có thời gian khởi động nhanh và yêu cầu ít tài nguyên. Chúng được thiết kế để chạy các ứng dụng container hoặc serverless, mang lại hiệu suất cao và độ trễ thấp.

Các project MVM lớn hiện nay có thể kể đến:
- Firecracker: Đây là hàng của AWS Dev và là backbone cho Lambda và Fargate
- Cloudflare Workers: Sử dụng MVM architecture base trên V8 engine, nhưng là bản v8 isolates.
- Kata Containers, Wasm,...


### Tìm hiểu rõ hơn về Lambda: Cách thức hoạt động, lifecycle, các giới hạn của Lambda

- Với ngày đầu tiên của challenge, người dùng có thể tìm hiểu sơ qua về cách thức hoạt động của lambda, cơ chế invoke và làm quen với việc tạo function và code trực tiếp trên giao diện của Lambda. Nhưng thực tế Lambda chạy bên dưới như nào?
- Sau đây là 1 lifecycle của Lambda, từ lúc function được tạo đến lúc được khởi chạy và kết thúc:
  - Tạo function - 2 Options:
    - Option 1: Lamda function với Runtime đã có sẵn:
      - Việc tạo function Lambda khá đơn giản với mức cơ bản, người dùng chỉ cần làm 3 thao tác sau:
        - Nhập thông tin function
        - Chọn Runtime: Chọn runtime mong muốn. Nếu không có sẵn, chọn Runtime OS để tự config runtime mong muốn.
        - Chọn CPU Architecture, hiện tại chỉ có 2 kiến trúc được sử dụng: x86_64, arm64 (phân tích kiến trúc, xem lại ngày 1)
        - Chọn role mà function sẽ assume, lambda function sẽ assume role này và tương tác với những resources mà cách policy trong role cho phép.
    - Option 2: Lambda function với Container:
      - Trong một số trường hợp đặc thù, người dùng có thể yêu cầu khả năng kiểm soát khá sâu xuống tầng OS hoặc đơn giản các library cần sử dụng có kích thước quá lớn thì đây là cách để giải quyết.
      - 
  - Deploy function - Code changes:
    - Việc này xảy ra rất thường xuyên, tại bước này, nếu:
      - Function được tạo từ đầu, code base:
        - Code trực tiếp trên console của Lambda nếu package size tổng < 2MB
        - Cập nhập file code thông qua: Cloud9/IaC/Upload file Zip trên Lambda Function Console
      - Fucntion được tạo từ Container Image:
        - Cập nhập thông qua IaC
        - Cập nhập thông qua việc uplaod image mới lên ECR, deploy phiên bản mới thủ công trên Lambda Function Console
  - Trigger function:
    - Init function & Cold start:
      - Có một cái hardlimit 10s tại đây, các Extension, runtime, function init sẽ được chạy tại bước này
      - Lambda cần provision 1 instance/container để exec code, trong trường hợp không có container nào trống, khoảng thời gian này là cần thiết để chạy mới 1 container phục vụ cho việc chạy code.
    - Run state:
      -  Sau khi một container được chạy sẽ exec function, tại đây sẽ có 2 trường hợp:
         -  Function chạy thành công: Container về idle state và chờ lượt gọi tiếp theo
         -  Function chạy không thành công: Run time sẽ được restart lại và Extension sẽ bị tắt đi (bật lại tại lần invoke tiếp theo), container về idle state.
    - Terminate state:
      - Việc này xảy ra khi function ở trạng thái idle quá lâu, Lambda engine sẽ tự thu hồi resource bằng cách terminate container
    - Archived function:
      - Đối với những function được deploy từ image pull từ ECR, Lambda sẽ optimize image được chọn để deploy và kéo image về phân vùng lưu trữ của Lambda thay vì ECR, nhưng sau vài tuần không hoạt động, Optimizer sẽ bị thu hồi và image sẽ bị xóa tại phân vùng lưu trữ của Lambda. Lúc này cần thực hiện restore lại function, việc này có thể mất thời gian.

- Scope của ngày 2 sẽ là:
  - Sử dụng Lambda với Layer.
  - Tương tác với Lambda thông qua các resource của AWS.
  - Optimize thời gian chạy 1 function nếu cần


### Triển khai một services tự động xóa background của ảnh
- Requirements:
  - Thư viện rembg cho Python
  - S3 bucket lưu ảnh upload/remove background
  - Event trigger sự kiện tạo file trên bucket
  - Lambda + Layer (Sẽ sửa về sau vì một số hạn chế)

##### Triển:
- Terraform code được chép từ Day 1 với một số yêu cầu thêm:
  - S3: Tạo bucket, tạo event trigger khi PUT (aka tạo file)
  - Lambda: Thêm 1 policy cho phép Lambda đọc/ghi object vào bucket, thêm 1 Policy cho phép đọc ECR private. Cho phép S3 bucket trigger khi upload
  - Terraform: Thêm module S3, thêm null_resource handle việc tạo layer.
  - ECR: Lưu image tự build. Lý do bên dưới

- Vấn đề xảy ra tại bước tạo layer:
  - Lambda có một hard limit về kích thước của deployment package khi giải nén (250MB Max)
  - Rembg và các thư viện đi kèm quá nặng (OpenCV, Pytoch) khiến package trước/sau giải nén đều vượt quá 250MB

Mặc dù đã cố gắng dùng trick lỏ (download library về /tmp sau đó giải nén và add vào sys/dynamic import) nhưng đều không thành công, mình quyết định chuyển qua hướng tự build image và đẩy lên ECR, sau đó Lambda sẽ thực hiện kéo image về và xử lý ảnh.


