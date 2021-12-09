/**
* @description   Framework Api Handler
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Antonio Santos                23/08/2021          Created Framework Api Handler
* ------------------------------------------------------------------------------------ 
*/
public class FW_ApiHandler {
/* Sample Usage

FW_ApiHandler apiFw = FW_ApiHandler.getInstance();
Account account = [SELECT Id, BillingCity FROM Account WHERE BillingCity != NULL LIMIT 1];
FW_ApiMethod FW_ApiMethod = apiFw.getMethod('SampleWeatherApiMethod');
  
SampleWeatherResult result = (SampleWeatherResult)apiFW.call(FW_ApiMethod, account);

System.debug(result);

*/
    public class FW_ApiHandlerException extends Exception { }

    public class FW_ApiHandlerCalloutMock implements HttpCalloutMock {
        Integer statusCode;
        String resultBody;

        public FW_ApiHandlerCalloutMock(Integer statusCode, String resultBody) {
            this.statusCode = statusCode;
            this.resultBody = resultBody;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse httpResponse =new HttpResponse();

            httpResponse.setStatusCode(statusCode);
            httpResponse.setBody(resultBody);

            return httpResponse;
        }
    }

    public class FW_ApiCallResult {
        public String endpoint;
        public String requestBody;

        public Integer statusCode { get; set; }
        public String status { get; set; }
        public String body { get; set;}

        public FW_ApiCallResult(HttpResponse httpResponse) {
            this.statusCode = httpResponse.getStatusCode();
            this.status = httpResponse.getStatus();
            this.body = httpResponse.getBody();
        }
    }

    private static String ERROR_NO_LOGICAL_ENVIRONMENT_DEFINED = 'ERROR: No Logical Environment defined';
    private static String ERROR_LOGICAL_ENVIRONMENT_NOT_DEFINED = 'ERROR: Logical Environment not defined';
    private static String ERROR_METHOD_NAME_CANNOT_BE_BLANK = 'ERROR: Method Name cannot be blank';
    private static String ERROR_API_METHOD_NOT_DEFINED = 'ERROR: API Method not defined';
    private static String ERROR_API_CREDENTIAL_NOT_FOUND = 'ERROR: API Credential not found';
    private static String ERROR_INPUT_PARAMETER_METHOD_IS_NULL = 'ERROR: Input parameter method is null';
    private static String ERROR_OUTPUT_CLASS_NOT_FOUND = 'ERROR: Output class not found';
    
    private static Integer DEFAULT_TIMEOUT = 5; // default timeout is 5 seconds

    static FW_ApiHandler serviceInstance = null;

    /**
     * Get an instance of the API Framework Service.
     * 
     */
    public static FW_ApiHandler getInstance() {
        if (serviceInstance == null) {
            serviceInstance = new FW_ApiHandler();
        }

        return serviceInstance;
    }

    /**
     * Get an API Framework Method by Developer Name.
     * 
     */
    public FW_ApiMethod getMethod(String methodName) {
        IREP_CEP_Api apiRepo = REP_CEP_Api.getInstance();

        CEP_ApiSetting__c apiSetting;
        CEP_ApiLogicalEnvironment__mdt apiEnv;
        CEP_ApiMethod__mdt apiMethod;
        CEP_ApiPath__mdt apiPath;
        CEP_ApiCredential__mdt apiCredential;
        List<CEP_ApiHttpHeader__mdt> httpHeaderList;
        
        FW_ApiMethod fwMethod;

        apiSetting = apiRepo.getSetting();

        if (String.isBlank(apiSetting.LogicalEnvironmentDeveloperName__c)) {
            throw new FW_ApiHandlerException(ERROR_NO_LOGICAL_ENVIRONMENT_DEFINED);
        }

        apiEnv = apiRepo.getLogicalEnvironmentByDeveloperName(apiSetting.LogicalEnvironmentDeveloperName__c);

        if (String.isBlank(methodName)) {
            throw new FW_ApiHandlerException(ERROR_METHOD_NAME_CANNOT_BE_BLANK);
        }

        if (apiEnv == null) {
            throw new FW_ApiHandlerException(ERROR_LOGICAL_ENVIRONMENT_NOT_DEFINED + ' - ' + apiSetting.LogicalEnvironmentDeveloperName__c);
        }

        apiMethod = apiRepo.getMethodByDeveloperName(methodName);

        if (apiMethod == null) {
            throw new FW_ApiHandlerException(ERROR_API_METHOD_NOT_DEFINED + ' - ' + methodName);
        }

        apiPath = apiRepo.getPathById(apiMethod.ApiPath__c);

        apiCredential = apiRepo.getCredentialByEnvIdPathId(apiEnv.Id, apiMethod.ApiPath__c);

        if (apiCredential == null) {
            throw new FW_ApiHandlerException(ERROR_API_CREDENTIAL_NOT_FOUND + ' - logicalEnvironment=' + apiEnv.DeveloperName + ', methodName=' + methodName);
        }

        httpHeaderList = apiRepo.getHttpHeaderByMethodId(apiMethod.Id);

        fwMethod = new FW_ApiMethod(apiCredential, apiPath, apiMethod, httpHeaderList);

        if (fwMethod.timeout == null && apiSetting.Timeout__c != null) {
            fwMethod.timeout = Integer.valueOf(apiSetting.Timeout__c);
        }

        if (fwMethod.timeout == null) {
            fwMethod.timeout = DEFAULT_TIMEOUT;
        }

        if (Test.isRunningTest()) {
            // Setup a Mock for this method instance
            Test.setMock(HttpCalloutMock.class, new FW_ApiHandlerCalloutMock(200, fwMethod.mockOutput));
        }

        return fwMethod;
    }

    /**
     * Call an API Framework Method.
     * 
     * Fields to be merged on:
     *   - Endpoint URL
     *   - Body
     *   - Header(s)
     * 
     */
    public Object call(FW_ApiMethod method, sObject relatedSObject) {
        Map<String,Object> sobjectFieldMap = relatedSObject?.getPopulatedFieldsAsMap();

        return call(method, sobjectFieldMap);
    }

    /**
     * Call an API Framework Method
     * 
     * Fields to be merged on:
     *   - Endpoint URL
     *   - Body
     *   - Header(s)
     * 
     */
    public Object call(FW_ApiMethod method, Map<String,Object> inputFieldMap) {
        FW_ApiCallResult callResult;

        callResult = callMethod(method, inputFieldMap);

        return getObject(method, callResult);
    }

    public FW_ApiCallResult callMethod(FW_ApiMethod method, sObject relatedSObject) {
        Map<String,Object> sobjectFieldMap = relatedSObject?.getPopulatedFieldsAsMap();

        return callMethod(method, sobjectFieldMap);
    }

    public FW_ApiCallResult callMethod(FW_ApiMethod method, Map<String,Object> inputFieldMap) {
        Map<String,List<String>> httpHeaderMap = new Map<String,List<String>>();
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse;
        String endpointURL;
        String body;
        FW_ApiCallResult callResult;

        if (method == null) {
            throw new FW_ApiHandlerException(ERROR_INPUT_PARAMETER_METHOD_IS_NULL);
        }

        endpointURL = 'callout:' + method.namedCredential;

        if (String.isNotBlank(method.path)) {
            endpointURL += (method.path.startsWith('/') ? '' : '/') + method.path;
        }

        if (String.isNotBlank(method.subpath)) {
            endpointURL += (method.subpath.startsWith('/') ? '' : '/') + method.subpath;
        }

        endpointURL = mergeFields(endpointURL, inputFieldMap);

        if (!method.httpHeaderMap?.isEmpty()) {
            for (String headerName : method.httpHeaderMap.keySet()) {
                for (String headerValue : method.httpHeaderMap.get(headerName)) {

                    headerValue = mergeFields(headerValue, inputFieldMap);

                    httpRequest.setHeader(headerName, headerValue);
                }
            }
        }

        body = mergeFields(method.inputTemplate, inputFieldMap);

        httpRequest.setEndpoint(endpointURL);
        httpRequest.setMethod(method.httpMethod);
        
        if (String.isNotEmpty(body)) {
            httpRequest.setBody(body);
        } else {
            httpRequest.setBody('');
        }

        httpRequest.setTimeout(method.timeout * 1000);

        httpResponse = http.send(httpRequest);

        callResult = new FW_ApiCallResult(httpResponse);

        callResult.endpoint = endpointURL;
        callResult.requestBody = String.isNotEmpty(body) ? body : '';

        /*
        System.debug(httpResponse);
        System.debug(resultBody);
        */

        return callResult;
    }

    /**
     * Auxiliary method to performe the merge of fields into a template string.
     * 
     * 
     */
    private String mergeFields(String template, Map<String,Object> fieldMap) {
        String result = template;

        if (String.isNotBlank(result) && !fieldMap?.isEmpty()) {
            for (String field : fieldMap.keySet()) {
                Object value = fieldMap.get(field);
                String strValue = '';

                if (value != null) {
                    strValue = String.valueOf(value);
                }

                result = result.replace('{!' + field + '}', strValue);
            }
        }

        return result;
    }

    /**
     * Based on an API method and call result, return the object deserialized from the body.
     * 
     */
    public Object getObject(FW_ApiMethod method, FW_ApiCallResult callResult) {
        Object resultObject;

        if (String.isNotBlank(method.outputClass) && String.isNotBlank(callResult?.body)) {
            System.Type resultType = System.Type.forName(method.outputClass);

            if (resultType == null) {
                throw new FW_ApiHandlerException(ERROR_OUTPUT_CLASS_NOT_FOUND + ' - ' + method.outputClass);
            }

            resultObject = JSON.deserialize(callResult.body, resultType);
        }

        return resultObject;
    }
}