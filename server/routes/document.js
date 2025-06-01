const express = require('express');
const Document = require('../models/document_model');
const documentRouter = express.Router();
const auth = require('../middlewares/auth');
const mongoose = require('mongoose');

documentRouter.post('/doc/create', auth, async(req, res) => {
    try {
        console.log('Request Body:', req.body);
        console.log('Authenticated User:', req.user);

        const { createdAt } = req.body;
        let document = new Document({
            uid: new mongoose.Types.ObjectId(req.user),
            title: 'Untitled Document',
            createdAt,
        });

        document = await document.save();
        res.json(document);
    } catch (e) {
        console.error(e.message);
        res.status(500).json({ error: e.message });
    }
});

documentRouter.get('/docs/me', auth, async (req, res) => {
    try {
        console.log('Fetching documents for user:', req.user);
        const documents = await Document.find({ 
            uid: new mongoose.Types.ObjectId(req.user)
        });
        console.log('Found documents:', documents);
        res.json(documents);
    } catch (e) {
        console.error('Error fetching documents:', e);
        res.status(500).json({ error: e.message });
    }
});

documentRouter.post('/doc/title', auth, async(req, res) => {
    try {
        console.log('Request Body:', req.body);
        console.log('Authenticated User:', req.user);

        const { id, title } = req.body;
        const document = await Document.findByIdAndUpdate(
            id, 
            { title },
            { new: true }
        );

        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }

        res.json(document);
    } catch (e) {
        console.error(e.message);
        res.status(500).json({ error: e.message });
    }
});

documentRouter.get('/docs/:id', auth, async (req, res) => {
    try {
        const document = await Document.findById(req.params.id);
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }
        res.json(document);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

documentRouter.post('/create', auth, async (req, res) => {
    try {
        const { title, content, createdAt } = req.body;
        let document = await Document.create({
            title,
            content,
            createdAt,
            uid: req.user,
        });
        document = await document.populate("uid", "name email");
        res.json(document);
    } catch (e) {
        res.status(500).json(e.message);
    }
});

documentRouter.get('/me', auth, async (req, res) => {
    try {
        let documents = await Document.find({ uid: req.user });
        res.json(documents);
    } catch (e) {
        res.status(500).json(e.message);
    }
});

documentRouter.get('/:id', auth, async (req, res) => {
    try {
        const document = await Document.findOne({ _id: req.params.id });
        res.json(document);
    } catch (e) {
        res.status(500).json(e.message);
    }
});

documentRouter.put('/title', auth, async (req, res) => {
    try {
        const { id, title } = req.body;
        const document = await Document.findOneAndUpdate(
            { _id: id, uid: req.user },
            { title },
            { new: true }
        );
        res.json(document);
    } catch (e) {
        res.status(500).json(e.message);
    }
});

documentRouter.put('/content', auth, async (req, res) => {
    try {
        const { id, content } = req.body;
        const document = await Document.findOneAndUpdate(
            { _id: id, uid: req.user },
            { content },
            { new: true }
        );
        res.json(document);
    } catch (e) {
        res.status(500).json(e.message);
    }
});

module.exports = documentRouter;