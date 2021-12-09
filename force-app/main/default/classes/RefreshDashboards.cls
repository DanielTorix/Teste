/**
 * Created by mateuszbednarek on 22/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class RefreshDashboards {

    static List<String> dashboardIds = getDashboardIds();
    static String endpoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v31.0/analytics/dashboards/';

    public static void refresh(){
        ExceptionHandler.errorLogList.clear();

        for(String ids : dashboardIds){
            InternalResourcesRestCallout callout = new InternalResourcesRestCallout('PUT',endpoint+ids);
            callout.makeCallout();
            if(callout.getResponseCode() != 201){
                makeErrorLog(callout.getResponse(), ids);
            }
        }

        insertErrorLogs();
    }

    private static void makeErrorLog(HttpResponse response, Id dashboardId){
        ExceptionHandler.createErrorLogList(response.getBody(), response.getBody(), RefreshDashboards.class
                .getName(),
                'refresh', dashboardId, '');

    }
    private static void insertErrorLogs(){
        if(!ExceptionHandler.errorLogList.isEmpty()){
            insert ExceptionHandler.errorLogList;
        }
    }

    private static List<String> getDashboardIds(){
        List<String> ids = new List<String>();
        ids.add(Dashboard__c.getInstance().Current_Fulfilment_Dashboard__c);
        ids.add(Dashboard__c.getInstance().Fulfilment_Forecast_Penalty_Dashboard__c);
        return ids;
    }
}