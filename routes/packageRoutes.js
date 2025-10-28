// backend/routes/packageRoutes.js
const express = require('express');
const router = express.Router();
const ctl = require('../controllers/packageController');

router.get('/', ctl.list);
router.post('/', ctl.create);
router.put('/:id', ctl.update);
router.delete('/:id', ctl.remove);

module.exports = router;
