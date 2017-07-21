var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var utility = require('utility');

var UserSchema = new Schema({

    nick_name: {type: String},
    login_name: {type: String}, // e-mail注册
    password: {type: String},
    avatar: {type: String}, // 头像
    isThirdPartyLogin: {type: Boolean, default: false}, //是否第三方登录

    favorite_divesite: [Schema.Types.String], // 收藏的潜点

    create_at: {type: Date, default: Date.now},
    update_at: {type: Date, default: Date.now},
    active: {type: Boolean, default: true},

    token: {type: String}
});

UserSchema.virtual('avatar_url').get(function () {
    var url = this.avatar || ('//gravatar.com/avatar/' + utility.md5(this.email.toLowerCase()) + '?size=48');

    // www.gravatar.com 被墙
    url = url.replace('//www.gravatar.com', '//gravatar.com');

    // 让协议自适应 protocol
    if (url.indexOf('http:') === 0) {
        url = url.slice(5);
    }

    // 如果是 github 的头像，则限制大小
    if (url.indexOf('githubusercontent') !== -1) {
        url += '&s=120';
    }
    return url;
});

UserSchema.index({login_name: 1}, {unique: true});
UserSchema.index({token: 1});

mongoose.model('User', UserSchema);