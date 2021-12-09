/**
 * Created by mateuszbednarek on 11/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class UpdateServiceContractWorkingDays {

    Map<String, List<ServiceContract>> childrenContractsByCountry;
    Map<String, FPS_Bor_Workday__c> workdaysGroupedByCountries = groupWorkdays();

    private void groupServiceContracts(List<ServiceContract> scope) {
        Map<String, List<ServiceContract>> countryToContract = new Map<String, List<ServiceContract>>();

        for(ServiceContract contract: scope){

            if(countryToContract.containsKey(contract.ParentServiceContract.Account.BillingCountry)){
                countryToContract.get(contract.ParentServiceContract.Account.BillingCountry).add(contract);
            }else{
                countryToContract.put(contract.ParentServiceContract.Account.BillingCountry, new List<ServiceContract>{contract});
            }
        }

        childrenContractsByCountry = countryToContract;
    }

    private Map<String,FPS_Bor_Workday__c> groupWorkdays() {
        Map<String, FPS_Bor_Workday__c> countryToWorkday = new Map<String, FPS_Bor_Workday__c>();

        for(FPS_Bor_Workday__c wd: [SELECT Id, Number_of_working_days_current_month__c, Number_of_working_days_till_today__c,
                Country__c
        FROM FPS_Bor_Workday__c WHERE Is_current_month__c = TRUE]){
            countryToWorkday.put(wd.Country__c, wd);
        }

        return countryToWorkday;
    }

    public void updateServiceContracts(List<ServiceContract> scope){
        List<ServiceContract> toUpdate = new List<ServiceContract>();
        groupServiceContracts(scope);

        for(String country: childrenContractsByCountry.keySet()){
            for(ServiceContract contract : childrenContractsByCountry.get(country)){
                contract.Work_Days_Excl_Holiday_This_Month__c = workdaysGroupedByCountries.get(Util.countryNameToCode
                        .get(country)).Number_of_working_days_current_month__c;
                contract.Work_Days_Excl_Holiday_Till_Today__c = workdaysGroupedByCountries.get(Util.countryNameToCode
                        .get(country)).Number_of_working_days_till_today__c;

                toUpdate.add(contract);
            }
        }

        update toUpdate;
    }
}