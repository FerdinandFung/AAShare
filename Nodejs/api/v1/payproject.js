var config = require('../../config');
var models = require('../../models');
var PayProjectProxy = require('../../proxy').PayProject;
var eventproxy = require('eventproxy');
var _ = require('lodash');

//上传账本信息
var update = function (req, res, next) {
    var projectId = req.body.projectId;
    var projectName = req.body.projectName;
    var payItems = req.body.payItems;
    var payPersons = req.body.payPersons;

    var editError;
    if (typeof(projectId) == 'undefined' || projectId === '') {
        editError = '账本id不可为空';
    } else if (typeof(projectName) == 'undefined' || projectName === '') {
        editError = '账本名称不可为空';
    } else if (typeof(payItems) == 'undefined' || payItems === '') {
        editError = '账本支付项不可为空';
    } else if (typeof(payPersons) == 'undefined' || payPersons === '') {
        editError = '账本支付人不可为空';
    }

    if (editError) {
        res.status(422);
        return res.send({
            "code": -1,
            "msg": editError
        });
    }

    PayProjectProxy.update(projectId, projectName, payItems, payPersons, function (err, payproject) {

        if (err) {
            res.status(422);
            return res.send({
                "code": -1,
                "msg": err
            });
        }

        //payproject = _.pick(payproject, ['projectid', 'name']);
        var url = config.wwwhost + '/payproject/detail/' + payproject['shortUrl'];
        return res.send({
            "code": 0,
            "msg": "请将下面的链接分享给你的朋友。",
            "data": url
        });
    })
};

exports.update = update;