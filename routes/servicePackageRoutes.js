const express = require("express");
const router = express.Router();

const {
  getPackages,
  getPackageById,
  createPackage,
  updatePackage,
  deletePackage,
  updatePackageStatus   // 👈 thêm vào
} = require("../controllers/servicePackageController");

// GET all packages
router.get("/", getPackages);

// GET package by id
router.get("/:id", getPackageById);

// POST create package
router.post("/", createPackage);

// PUT update package (chỉnh sửa toàn bộ thông tin)
router.put("/:id", updatePackage);

// PATCH update status (chỉ thay đổi trạng thái hoạt động/ngừng)
router.patch("/:id/status", updatePackageStatus);

// DELETE package
router.delete("/:id", deletePackage);

module.exports = router;
