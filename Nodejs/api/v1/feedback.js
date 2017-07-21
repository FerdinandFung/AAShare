var models = require('../../models');
var FeedbackProxy = require('../../proxy').Feedback;
var config = require('../../config');
var _ = require('lodash');
var validator = require('validator');
var email = require('../../common/email');

// input: {feedback: "xxxx"}
// output: {code: 0, msg: 'successful'}
var update = function (req, res, next) {
	var feedback = req.body.feedback;

	var editError;
	if (typeof(feedback) == 'undefined' || feedback === '') {
		editError = '反馈内容不可为空';
	}

	if (editError) {
		res.status(422);
		return res.send({
			"code": -1,
			"msg": editError
		});
	}

	FeedbackProxy.newFeedback(feedback, function(err, user){
		if (err){
			return res.send({code: -1, msg: "反馈发送失败，请稍后重试！"});
		}

		email.sendFeedbackMail(feedback);

		return res.send({
				"code": 0,
				"msg": "反馈发送成功！我会尽快与您联系，谢谢您的反馈！"
		});


	});
};

exports.update = update;
