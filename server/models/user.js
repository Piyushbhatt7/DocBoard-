const mongoose = require('moongose');

const userSchema = mongoose.Schema ({

    name: {
        type: String,
        required: true,

    },
})