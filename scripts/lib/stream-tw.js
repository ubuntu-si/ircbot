var oauth = require('oauth'),
    events = require('events'),
    _ = require('underscore'),
    util = require("util");


var public_stream_url = 'https://stream.twitter.com/1.1/statuses/filter.json',
    request_token_url = 'https://api.twitter.com/oauth/request_token',
    access_token_url = 'https://api.twitter.com/oauth/access_token';

module.exports = Stream;

function Stream(params) {

    if (!(this instanceof Stream)) {
        return new Stream(params);
    }
    events.EventEmitter.call(this);
    this.params = params;
    this.oauth = new oauth.OAuth(
        request_token_url,
        access_token_url,
        this.params.consumer_key,
        this.params.consumer_secret,
        '1.0',
        null,
        'HMAC-SHA1',
        null,
        {
            'Accept':'*/*',
            'Connection':'close',
            'User-Agent':'public-stream-bot'
        }
    );

}
util.inherits(Stream, events.EventEmitter);
Stream.prototype.stream = function () {
    var stream = this;
    var request = this.oauth.post(
        public_stream_url,
        this.params.access_token_key,
        this.params.access_token_secret,
        {
            delimited:'length',
            stall_warnings:'true',
            follow:this.params.follow
        },
        null
    );

    this.destroy = function () {
        request.abort();
    }
    this.changeParams = function (params) {
        this.params = _.extend(this.params, params);
    }

    request.on('response', function (response) {
        if (response.statusCode > 200) {
            stream.emit('error', {type:'response', data:{code:response.statusCode}});
        } else {
            var buffer = '',
                next_data_length = 0,
                end = '\r\n';

            //emit connected event
            stream.emit('connected');

            //set chunk encoding
            response.setEncoding('utf8');

            response.on('data', function (chunk) {

                //is heartbeat?
                if (chunk == end) {
                    stream.emit('heartbeat');
                    return;
                }

                //check whether new incomming data set
                if (!buffer.length) {
                    //get length of incomming data
                    var line_end_pos = chunk.indexOf(end);
                    next_data_length = parseInt(chunk.slice(0, line_end_pos));
                    //slice data length string from chunk
                    chunk = chunk.slice(line_end_pos + end.length);
                }

                if (buffer.length != next_data_length) {
                    //data set recieved
                    //first remove end and append to buffer
                    buffer += chunk.slice(0, chunk.indexOf(end));
                    //parse json
                    var parsed = false;
                    try {
                        //try parse & emit
                        buffer = JSON.parse(buffer);
                        parsed = true;
                    } catch (e) {
                        stream.emit('garbage', buffer);
                    }
                    //don't emit into "try" and emit only if data formatted
                    if (parsed) {
                        stream.emit('data', buffer);
                    }
                    //clean buffer
                    buffer = '';

                } else {
                    //append to buffer
                    buffer += chunk;
                }
            });

            response.on('error', function (error) {
                stream.emit('close', error);
            });

            response.on('end', function () {
                stream.emit('close', 'socket end');
            });
            response.on('close', function () {

                request.abort();

            });
        }
    });
    request.on('error', function (error) {
        stream.emit('error', {type:'request', data:error});
    });
    request.end();
}