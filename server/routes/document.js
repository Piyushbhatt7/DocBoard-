const express = require('express');
const Document = require('../models/document_model');
const documentRouter = express.Router();
const auth = require('../middlewares/auth');
const e = require('express');


documentRouter.post('/doc/create', auth, async(req, res) => {
    try {
        console.log('Request Body:', req.body);
        console.log('Authenticated User:', req.user);

        const { createdAt } = req.body;
        let document = new Document({
            uid: req.user,
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


documentRouter.get('/docs:id', auth, async (req, res) => {
    try {
        let document = await Document.find({ uid: req.params.id });
        res.json(document);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

documentRouter.post('/doc/title', auth, async(req, res) => {
    try {
        console.log('Request Body:', req.body);
        console.log('Authenticated User:', req.user);

        const { id, title } = req.body;
        const document = await Document.finndByIdAndUpdate(id, { title },);

        res.json(document);
    } catch (e) {
        console.error(e.message);
        res.status(500).json({ error: e.message }); //4:01
    }
});

module.exports = documentRouter;