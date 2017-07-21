var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var utility = require('utility');

var FeedbackSchema = new Schema({

    content: {type: String},

    create_at: {type: Date, default: Date.now},
});

FeedbackSchema.index({_id: 1});

mongoose.model('Feedback', FeedbackSchema);