var mongoose = require('mongoose');
var config = require('../config');

mongoose.connect(config.db, function(err){
	if (err) {
		console.error('mongoose connect to %s error: ', config.db, err.message);
		process.exit(1);
	}
});

require('./payproject');
require('./user');
require('./feedback');

exports.PayProject = mongoose.model('PayProject');
exports.User = mongoose.model('User');
exports.Feedback = mongoose.model('Feedback');