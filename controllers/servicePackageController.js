// backend/controllers/servicePackageController.js
const pool = require("../config/db");

// Hàm chuẩn hóa status (luôn uppercase để hợp với MySQL enum)
const normalizeStatus = (status) => {
  if (!status) return "INACTIVE"; // default
  return status.toUpperCase() === "ACTIVE" ? "ACTIVE" : "INACTIVE";
};

// GET all
// controllers/servicePackageController.js
const getPackages = async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM service_packages ORDER BY package_id DESC");

    const packages = rows.map(pkg => {
      let parsedFeatures = [];
      try {
        if (pkg.features) {
          parsedFeatures = JSON.parse(pkg.features);
          if (!Array.isArray(parsedFeatures)) parsedFeatures = [parsedFeatures];
        }
      } catch (e) {
        parsedFeatures = [];
      }
      return {
        ...pkg,
        features: parsedFeatures
      };
    });

    res.json(packages);
  } catch (err) {
    console.error("❌ getPackages error:", err);
    res.status(500).json({ message: err.message });
  }
};

// GET by ID
const getPackageById = async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM service_packages WHERE package_id = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Package not found" });

    const pkg = rows[0];
    pkg.features = pkg.features ? JSON.parse(pkg.features) : [];
    res.json(pkg);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// POST create
const createPackage = async (req, res) => {
  try {
    const { name, description, price, status, features } = req.body;
    const featuresJSON = JSON.stringify(features || []);
    const normalizedStatus = normalizeStatus(status);

    const [result] = await pool.query(
      "INSERT INTO service_packages (name, description, price, status, features) VALUES (?, ?, ?, ?, ?)",
      [name, description, price, normalizedStatus, featuresJSON]
    );

    res.status(201).json({
      package_id: result.insertId,
      name,
      description,
      price,
      status: normalizedStatus,
      features
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// PUT update
const updatePackage = async (req, res) => {
  try {
    const { name, description, price, status, features } = req.body;
    const featuresJSON = JSON.stringify(features || []);
    const normalizedStatus = normalizeStatus(status);

    const [result] = await pool.query(
      "UPDATE service_packages SET name=?, description=?, price=?, status=?, features=?, updated_at=NOW() WHERE package_id=?",
      [name, description, price, normalizedStatus, featuresJSON, req.params.id]
    );

    if (result.affectedRows === 0) return res.status(404).json({ message: "Not found" });
    res.json({ message: "Updated successfully" });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// PATCH update status
const updatePackageStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const normalizedStatus = normalizeStatus(status);

    const [result] = await pool.query(
      "UPDATE service_packages SET status=?, updated_at=NOW() WHERE package_id=?",
      [normalizedStatus, req.params.id]
    );

    if (result.affectedRows === 0) return res.status(404).json({ message: "Not found" });
    res.json({ message: "Status updated" });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// DELETE
const deletePackage = async (req, res) => {
  try {
    const [result] = await pool.query("DELETE FROM service_packages WHERE package_id=?", [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ message: "Not found" });
    res.json({ message: "Deleted successfully" });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

module.exports = {
  getPackages,
  getPackageById,
  createPackage,
  updatePackage,
  updatePackageStatus,
  deletePackage,
};
