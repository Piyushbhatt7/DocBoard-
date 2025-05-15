const express = require('express');
const Document = require('../modules/document_model');
const documentRouter = express.Router();
const auth = require('../middlewares/auth');
const e = require('express');


documentRouter.post('/doc/create', auth, async(req, res) => {

    try{
        
        const { createdAt } = req.body;
        let document = new Document({
            uid: req.user,
            title: 'Untitled Document',
            createdAt,
        });

        document = await document.save();
        res.json(document);
    }
    catch(e)
    {
        res.status(500).json({error: e.message})
    }
}); 