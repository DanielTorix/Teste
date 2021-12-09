/**
 * Created by mateuszbednarek on 22/02/2021.
 */

public with sharing class InternalResourcesRestCallout {

    String endpoint;
    String method;
    HttpRequest request;
    HttpResponse response;

    public InternalResourcesRestCallout(String method, String endpoint){
        this.method = method;
        this.endpoint = endpoint;
    }

    public void makeCallout(){
        createHttpRequest();
        Http http = new Http();
        system.debug('REQUEST '+endpoint+' '+request.getBody());
        this.response = http.send(request);
        system.debug('RESPONSE '+response.getBody());
    }

    private void createHttpRequest(){
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        this.request = request;
    }

    public String getResponseBody(){
        return response.getBody();
    }

    public Integer getResponseCode(){
        return response.getStatusCode();
    }

    public HttpResponse getResponse(){
        return response;
    }

}