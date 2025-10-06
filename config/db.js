const mysql = require("mysql2/promise");

const pool = mysql.createPool({
  host: "localhost",
  user: "root",        // đổi thành user MySQL của bạn
  password: "kkking",        // mật khẩu MySQL
  database: "swspace_db", // tên database, dựa theo file swspace_full.sql
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;
