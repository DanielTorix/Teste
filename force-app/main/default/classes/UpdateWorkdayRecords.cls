/**
 * Created by mateuszbednarek on 11/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class UpdateWorkdayRecords {

    static List<FPS_Bor_Workday__c> workdaysToUpsert = new List<FPS_Bor_Workday__c>();
    static Map<String, FPS_Bor_Workday__c> uniqueNameToWorkday = getExistingWorkdays();

    public static void updateWorkdayRecords(){
        ExceptionHandler.errorLogList.clear();

        for(String code: Util.countryNameToCode.values()){
            FPS_Bor_Workday__c wd = createBaseRecord(code);
            getWorkingDaysForAMonth(wd);
            getWorkingDaysUntilToday(wd);
            if(wd.Number_of_working_days_current_month__c != null){
                workdaysToUpsert.add(wd);
            }
        }

        finish();
    }

    private static void finish(){
        upsert workdaysToUpsert Unique_Name__c;
        insertErrorLogs();
        Database.executeBatch(new UpdateServiceContractWorkingDayBatch(), 200);
    }

    private static void insertErrorLogs(){
        if(!ExceptionHandler.errorLogList.isEmpty()){
            insert ExceptionHandler.errorLogList;
        }
    }

    private static FPS_Bor_Workday__c createBaseRecord(String code){
        FPS_Bor_Workday__c wd = new FPS_Bor_Workday__c();
        wd.Country__c = code;
        wd.Month__c = String.valueOf(Date.today().month());
        wd.Year__c = Date.today().year();
        wd.Unique_Name__c = wd.Country__c+'_'+wd.Month__c+'_'+wd.Year__c;
        return wd;
    }

    private static void getWorkingDaysForAMonth(FPS_Bor_Workday__c wd){
        if(uniqueNameToWorkday.containsKey(wd.Unique_Name__c)){
            wd.Number_of_working_days_current_month__c = uniqueNameToWorkday.get(wd.Unique_Name__c)
                    .Number_of_working_days_current_month__c;
        }else{
            HolidayAPIRestCallout api = new HolidayAPIRestCallout(wd.Country__c);
            wd.Number_of_working_days_current_month__c = api.getNumberOfWorkingDays();
        }
    }

    private static void getWorkingDaysUntilToday(FPS_Bor_Workday__c wd){
        HolidayAPIRestCallout api = new HolidayAPIRestCallout(wd.Country__c, Date.today());
        wd.Number_of_working_days_till_today__c = api.getNumberOfWorkingDays();
    }

    private static Map<String, FPS_Bor_Workday__c> getExistingWorkdays(){
        Map<String, FPS_Bor_Workday__c> uniqueNameToWorkday = new Map<String, FPS_Bor_Workday__c>();
        for(FPS_Bor_Workday__c wd: [SELECT Id, Number_of_working_days_current_month__c,Unique_Name__c FROM FPS_Bor_Workday__c WHERE
                Is_current_month__c = TRUE]){
            uniqueNameToWorkday.put(wd.Unique_Name__c, wd);
        }
        return uniqueNameToWorkday;
    }
}