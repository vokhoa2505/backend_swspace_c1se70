# SWSpace Backend - Database Setup

## PostgreSQL Database với Docker

Dự án này sử dụng PostgreSQL database chạy trong Docker container.

## Yêu cầu hệ thống

- Docker Desktop
- Docker Compose
- Node.js (cho backend)

## Cấu trúc thư mục

```
backend/
├── docker-compose.yml          # Docker Compose configuration
├── .env                        # Environment variables
├── .env.example               # Environment variables template
├── database/
│   └── init/
│       ├── 01-schema.sql      # Database schema
│       └── 02-data.sql        # Sample data
└── README.md                  # This file
```

## Setup Database

### 1. Khởi động PostgreSQL Database

```bash
# Di chuyển vào thư mục backend
cd d:\code_ngochan\backend

# Khởi động database
docker-compose up -d

# Kiểm tra container đang chạy
docker-compose ps
```

### 2. Kiểm tra Database

Database sẽ được tự động tạo với:
- **Database name**: swspace
- **Username**: swspace_user  
- **Password**: swspace_password
- **Port**: 5432 (exposed ra host)

### 3. Truy cập pgAdmin (tùy chọn)

- URL: http://localhost:8080
- Email: admin@swspace.vn
- Password: admin123

### 4. Kết nối từ Node.js

```javascript
// Sử dụng pg (node-postgres)
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'swspace',
  user: process.env.DB_USER || 'swspace_user',
  password: process.env.DB_PASSWORD || 'swspace_password',
});

// Test connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Database connection error:', err);
  } else {
    console.log('Database connected successfully');
  }
});
```

## Cài đặt Dependencies cho Node.js

```bash
# Cài đặt PostgreSQL driver
npm install pg
npm install --save-dev @types/pg  # Nếu dùng TypeScript

# Cài đặt dotenv để đọc .env file
npm install dotenv

# Cài đặt thêm các package khác nếu cần
npm install express cors helmet morgan
```

## Environment Variables

Copy file `.env.example` thành `.env` và chỉnh sửa theo nhu cầu:

```bash
cp .env.example .env
```

## Database Schema

Schema được tự động tạo khi khởi động container lần đầu, bao gồm:

### Bảng chính:
- `users` - Quản lý người dùng
- `bookings` - Quản lý đặt chỗ
- `payments` - Quản lý thanh toán
- `seats` - Quản lý ghế ngồi
- `rooms` - Quản lý phòng họp
- `zones` - Quản lý khu vực
- `floors` - Quản lý tầng
- `services` - Quản lý dịch vụ
- `service_packages` - Quản lý gói dịch vụ

### Views:
- `v_admin_kpis` - KPIs cho admin
- `v_revenue_daily` - Doanh thu theo ngày
- `v_utilization_daily` - Tỷ lệ sử dụng theo ngày

## Lệnh Docker hữu ích

```bash
# Khởi động database
docker-compose up -d

# Dừng database
docker-compose down

# Xem logs
docker-compose logs postgres

# Truy cập vào PostgreSQL CLI
docker exec -it swspace_postgres psql -U swspace_user -d swspace

# Backup database
docker exec swspace_postgres pg_dump -U swspace_user swspace > backup.sql

# Restore database
docker exec -i swspace_postgres psql -U swspace_user swspace < backup.sql

# Xóa volume (reset database)
docker-compose down -v
```

## Network Configuration

Docker Compose tạo một custom network `swspace_network` với subnet `172.20.0.0/16`. Điều này cho phép:

- Các container giao tiếp với nhau qua tên service
- Isolation network từ host system
- Port mapping để truy cập từ host

## Ports

- **PostgreSQL**: 5432 (mapped to host:5432)
- **pgAdmin**: 8080 (mapped to host:8080)
- **Backend API**: 3000 (sẽ cấu hình sau)

## Troubleshooting

### Container không khởi động được:
```bash
# Kiểm tra logs
docker-compose logs

# Kiểm tra port conflicts
netstat -tulpn | grep 5432
```

### Không kết nối được database:
```bash
# Test connection
docker exec swspace_postgres pg_isready -U swspace_user -d swspace

# Kiểm tra firewall/antivirus
# Đảm bảo port 5432 không bị block
```

### Reset hoàn toàn:
```bash
# Dừng và xóa tất cả
docker-compose down -v
docker-compose up -d
```

## Security Notes

⚠️ **Quan trọng**: Đây là setup cho development. Trong production:

1. Thay đổi tất cả mật khẩu mặc định
2. Sử dụng environment variables an toàn
3. Cấu hình firewall và network security
4. Enable SSL/TLS cho database connection
5. Backup database định kỳ