// backend/server.js
const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const pool = require("./config/db"); // Kết nối MySQL

dotenv.config();
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Test kết nối MySQL
pool.getConnection()
  .then(conn => {
    console.log("✅ MySQL connected!");
    conn.release();
  })
  .catch(err => {
    console.error("❌ MySQL connection error:", err);
  });

// Routes
app.use("/api/packages", require("./routes/servicePackageRoutes"));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
