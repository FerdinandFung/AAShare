var config = require('./config');
var express = require('express');
var userController = require('./api/v1/user');
var payprojectController = require('./api/v1/payproject');
var feedbackController = require('./api/v1/feedback');
var router = express.Router();

//*** 用户 ***
router.post('/user/login', userController.login);
router.post('/user/register', userController.register);

router.post('/payproject/update', payprojectController.update);

router.post('/feedback/update', feedbackController.update);


module.exports = router;