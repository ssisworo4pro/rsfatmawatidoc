var hl7 = require('hl7v2');
var HL7Client = new hl7.HL7Client();
// HL7Client.connect(3006,'172.16.11.16','')
HL7Client.connect(1234,'localhost','')

function dataKirim() {
    var data;
    data = 'MSH|^~\&|MS4_AZ|UNV|PREMISE|UNV|20180301010000||ADT^A04|IHS-20180301010000.00120|P|2.1';
    data = data + '\r';
    data = data + 'EVN|A04|20180301010000';
    data = data + '\r';
    data = data + 'PID|1||19050114293307.1082||BUNNY^BUGS^RABBIT^^^MS||19830215|M|||1234 LOONEY RD^APT A^CRAIGMONT^ID^83523^USA|||||||111-11-1111|111-11-1111';
    data = data + '\r';
    data = data + 'PV1|1|E|ED^^^UNV|C|||999-99-9999^MUNCHER^CHANDRA^ANDRIA^MD^DR|888-88-8888^SMETHERS^ANNETTA^JONI^MD^DR||||||7||||REF||||||||||||||||||||||||||20180301010000';
    data = data + '\r';
    data = 'MSH|^~\&|SIMRSGOS2|RSFATMAWATI|MOZAIK|RSFATMAWATI|202309261230|-|ADT^A04|1|1|2.5|2.0|2023090001|';
    data = data + '\r';
    data = data + 'PID||1182129|||IHLUS FARDAN||19890130|M|||JL. Tanjung Barat Simatupang|';
    data = data + '\r';
    console.log('--- data prepared ---');
    console.log(data);
    return data
}

async function sendData() {
    var returnMsg = await HL7Client.sendReceive(dataKirim(),10);
    var returnMsgMSA = returnMsg._segments.find(function(e){return e._type == 'MSA'});
    var returnMsgMSAack = returnMsgMSA._fields.find(function(e){return e._name == 'AcknowledgementCode'});
    // console.log(returnMsg);
    HL7Client.close()
    console.log(returnMsgMSAack._data[0]._value);
}

HL7Client.on('connect', function(msg){
    console.log('--- server connected ---');
    HL7Client.send(dataKirim());
    // sendData();
});

HL7Client.on('message', function(returnMsg){
    console.log('--- msg from Server ---');
    // console.log(returnMsg);
    HL7Client.close();
    var returnMsgMSA = returnMsg._segments.find(function(e){return e._type == 'MSA'});
    var returnMsgMSAack = returnMsgMSA._fields.find(function(e){return e._name == 'AcknowledgmentCode'});
    console.log('MSA AcknowledgmentCode : "' + returnMsgMSAack._data[0]._value + '"');
    // var returnMsgERR = returnMsg._segments.find(function(e){return e._type == 'ERR'});
    // var returnMsgERRack = returnMsgERR._fields.find(function(e){return e._name == 'ErrorCodeAndLocation'});
    // console.log(returnMsgERRack);
});
