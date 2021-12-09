/**
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
*/
public class HolidayAPIRestCallout {

    String startDate;
    String endDate;
    String country;
    String apiKey = '1cac16ab-572f-4655-8ff8-f640fd49f1e0';
    String test_apiKey = '723b100b-b6ee-47d6-977b-e14a5fa1e327';
    HttpRequest httpRequest;
    HttpResponse httpResponse;

    Integer numberOfWorkingDays;

    public HolidayAPIRestCallout(String country){
        this.country = country;
        formatDates();
    }
    public HolidayAPIRestCallout(String country, Date today){
        this.country = country;
        formatDates(today);
    }

    private void createHttpRequest(){
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(createEndpoint());
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        httpRequest = request;
    }

    private void makeCallout(){
        createHttpRequest();
        Http http = new Http();
        system.debug('REQUEST '+country+' '+httpRequest.getBody());
        httpResponse = http.send(httpRequest);
        parseResponse();
    }

    private void parseResponse(){
        WorkdayResponseWrapper response = (WorkdayResponseWrapper)JSON.deserialize(httpResponse.getBody(),
                WorkdayResponseWrapper.class);
        system.debug('RESPONSE '+country+' '+httpResponse.getBody());
        if(response.status != 200){
            handleError(response);
        }else{
            numberOfWorkingDays = response.workdays;
        }
    }

    public Integer getNumberOfWorkingDays(){
        makeCallout();
        return numberOfWorkingDays;
    }

    private void handleError(WorkdayResponseWrapper response){
        ExceptionHandler.createErrorLogList(response.error, JSON.serialize(response), HolidayAPIRestCallout.class.getName(),
                'parseResponse', '', '');
        insert ExceptionHandler.errorLogList;
    }

    private String createEndpoint(){
        String endpoint = 'https://holidayapi.com/v1/workdays?';
        endpoint+='key='+apiKey;
        endpoint+='&country='+country;
        endpoint+='&start='+startDate;
        endpoint+='&end='+endDate;

        return endpoint;
    }

    private void formatDates(){
        formatStartDate();
        formatEndDate();
    }
    private void formatDates(Date endDate){
        formatStartDate();
        formatEndDate(endDate);
    }
    private void formatStartDate(){
        Datetime dt = Datetime.newInstance(Date.today().year(), Date.today().month(), 1);
        startDate = dt.format('yyyy-MM-dd');
    }
    private void formatEndDate(){
        Date lastDayOfMonth = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        Datetime dt = Datetime.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), lastDayOfMonth.day());
        endDate = dt.format('yyyy-MM-dd');
    }
    private void formatEndDate(Date endDate){
        Datetime dt = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
        this.endDate = dt.format('yyyy-MM-dd');
    }

    class WorkdayResponseWrapper{
        Integer status;
        Integer workdays;
        String error;
        String warning;
    }
}