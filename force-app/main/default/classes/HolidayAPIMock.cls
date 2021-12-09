/**
 * Created by mateuszbednarek on 19/02/2021.
 */

public with sharing class HolidayAPIMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest param1) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\n' +
                '    "status": 200,\n' +
                '    "requests": {\n' +
                '        "used": 168,\n' +
                '        "available": 999832,\n' +
                '        "resets": "2021-03-01 00:00:00"\n' +
                '    },\n' +
                '    "workdays": 19\n' +
                '}');
        res.setStatusCode(200);
        return res;
    }
}