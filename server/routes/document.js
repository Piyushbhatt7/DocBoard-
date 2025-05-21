const express = require('express');
const auth = require('../middleware/auth'); // your middleware to verify JWT
const Document = require('../models/document');
const router = express.Router();

router.post('/doc/create', auth, async (req, res) => {
  try {
    const newDoc = new Document({
      uid: req.user, // comes from your auth middleware
      title: 'Untitled Document',
    });
    const savedDoc = await newDoc.save();
    res.status(200).json(savedDoc);
  } catch (e) {
    console.error('Document creation error:', e);
    res.status(500).json({ error: 'Server error while creating document' });
  }
});



documentRouter.get('/docs/me', auth, async (req, res) => {
    try {
        let document = await Document.find({ uid: req.user });
        res.json(document);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});


module.exports = documentRouter;