# Serverless architecture pattern:

## Microservices với serverless:
```
Kiến trúc microservices hướng đến việc bóc tách các component lớn ra thành các component nhỏ hơn và hạn chế khả năng ảnh hưởng đến nhau giữa các services, hạn chế rủi ro sập toàn bộ hệ thống khi một thành phần bị lỗi, việc tách các component ra tăng khả năng scale riêng biệt của từng component nhưng đổi lại khi hệ thống quá lớn việc quản lý microservices sẽ trở nên khó khăn hơn rất nhiều.
```

#### Use case:
- Smart Parking, này đọc của Google 
- Chatbot với RAG, mình có 1 project nhỏ về LLM + RAG, mỗi API sẽ nằm trên 1 lambda function, một vài job sẽ được xử lý với Fargate do thời gian chạy cần nhiều hơn và yêu cầu custom image.

## Serverless-side rendering với Lambda
```
Trong một dự án handover lại từ team khác, họ code Angular và theo hướng SPA. Vấn đề xảy ra khi web của khách không SEO được do SPA render content dynamically. Đội dev trong team không thể giải quyết bằng cách chuyển sang SSR (???) mình thì lại không chuyên về frontend để hỗ trợ. Sau khi research mình nghĩ ra 2 hướng: SSG và SSR với lambda. 
```
#### Use case:
- Serverless Side Render với Lambda: [Serverless Server Side Rendering with Angular on AWS Lambda@Edge ](https://dev.to/eelayoubi/serverless-server-side-rendering-with-angular-on-aws-lambda-edge-57g5)


Một vài resource mình tham khảo:
- [Cloud-native architecture with serverless microservices — the Smart Parking story](https://cloud.google.com/blog/products/gcp/cloud-native-architecture-with-serverless-microservices-the-smart-parking-story)
- [Refactoring to Serverless: From Application to Automation](https://aws.amazon.com/blogs/devops/refactoring-to-serverless-from-application-to-automation/)
