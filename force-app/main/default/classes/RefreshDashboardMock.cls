/**
 * Created by mateuszbednarek on 22/02/2021.
 */

public with sharing class RefreshDashboardMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest param1) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('"statusUrl":"/services/data/v31' +
                '.0/analytics/dashboards/01Z5r000000Cr89EAC/status"}');
        res.setStatusCode(200);
        return res;
    }
}