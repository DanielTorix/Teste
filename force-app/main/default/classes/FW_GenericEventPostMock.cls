@isTest
global class FW_GenericEventPostMock implements HttpCalloutMock {
   
    private Integer statusCode;

    global FW_GenericEventPostMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        return res;
    }
}