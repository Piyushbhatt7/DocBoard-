console.log('Hello, World')
const express = require("express");
const mongoose = require("mongoose");
const cors = require('cors');
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const http = require('http');
const { Server } = require("socket.io");
const Document = require('./models/document_model');

const PORT = process.env.PORT || 3001;      

const app = express();    

var server = http.createServer(app);
var io = new Server(server, {
  cors: {
    origin: ['http://localhost:5000', 'http://127.0.0.1:5000', 'http://localhost:3000','http://localhost:3001', 'http://127.0.0.1:3000'],
    methods: ["GET", "POST"],
    credentials: true
  }
});

// Configure CORS for web development
app.use(cors({
    origin: ['http://localhost:5000', 'http://127.0.0.1:5000', 'http://localhost:3000','http://localhost:3001', 'http://127.0.0.1:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'x-auth-token', 'Accept']
}));

// Add request logging
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    console.log('Request headers:', req.headers);
    next();
});

app.use(express.json());
app.use("/api", authRouter);
app.use("/api", documentRouter);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ error: 'Internal Server Error', details: err.message });
});

const DB = "mongodb+srv://piyushbhatt162:0k0P2FcurljxejUR@cluster0.mrjbpoh.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

mongoose.connect(DB, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => {
    console.log("MongoDB Connection successful!");
})
.catch((err) => {
    console.error("MongoDB Connection Error:", err);
    process.exit(1); // Exit if cannot connect to database
});

// Add connection error handler
mongoose.connection.on('error', err => {
    console.error('MongoDB connection error:', err);
});

mongoose.connection.on('disconnected', () => {
    console.log('MongoDB disconnected');
});

// async -> await
// .then((ref) => print(ref)

io.on('connection', (socket) => {
    console.log('New client connected');
    
    socket.on('join', (documentId) => {
        socket.join(documentId);
        console.log(`Client joined room: ${documentId}`);
    });

    socket.on('save', async (data) => {
        try {
            const { documentId, content } = data;
            console.log(`Saving document ${documentId}`);
            
            // Update document in database
            await Document.findByIdAndUpdate(
                documentId,
                { content: content },
                { new: true }
            );

            // Broadcast changes to all clients in the room
            socket.broadcast.to(documentId).emit('changes', {
                type: 'content',
                content: content
            });
        } catch (error) {
            console.error('Error saving document:', error);
        }
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected');
    });
});


server.listen(PORT, "0.0.0.0", () => {
    console.log(`Server is running on http://localhost:${PORT}`);
    console.log("hey this is changing");
});