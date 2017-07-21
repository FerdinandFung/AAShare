var models = require('../models');
var Feedback = models.Feedback;
var utility = require('utility');
var uuid = require('uuid');

/**
 * 新建feedback
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {String} content 反馈内容
 * @param {Function} callback 回调函数
 */
exports.newFeedback = function (content, callback) {
    var feedback = new Feedback();
    feedback.content = content;
    feedback.save(callback);
};

