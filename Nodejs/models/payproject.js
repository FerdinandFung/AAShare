var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var PayProjectSchema = new Schema({

    projectid: {type: String},
    name: {type: String},
    payitems: [{
        createDate: Date,
        id: String,
        modifyDate: Date,
        money: Number,
        name: String,
        payInOut: {
            id: Number,
            name: String
        },
        payItemType: {
            id: Number,
            name: String
        },
        persons: [{
            createDate: Date,
            gender: String,
            id: String,
            modifyDate: Date,
            money: Number,
            name: String,
            number: Number,
            payMoney: Number,
            personId: String,
            serverId: String,
            payInOutName: String, //缴费 支出 退款
            specificMoney: Boolean
        }]
    }],

    paypersons: [{
        createDate: Date,
        gender: String,
        id: String,
        modifyDate: Date,
        money: Number,
        name: String,
        number: Number,
        payMoney: Number,
        personId: String,
        serverId: String,
        payInOutName: String, //缴费 支出 退款
        specificMoney: Boolean

    }],

    update_at: {type: Date, default: Date.now},

    shortUrl: {type: String}

});

PayProjectSchema.index({projectid: 1});

mongoose.model('PayProject', PayProjectSchema);