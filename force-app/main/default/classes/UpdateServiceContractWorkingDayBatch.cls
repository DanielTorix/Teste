/**
 * Created by mateuszbednarek on 12/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class UpdateServiceContractWorkingDayBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    String query = 'SELECT Id, ParentServiceContractId, ParentServiceContract.Account.BillingCountry FROM ' +
            'ServiceContract WHERE ParentServiceContractId != NULL AND Is_Current_Month__c = TRUE';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<ServiceContract> scope) {
        UpdateServiceContractWorkingDays updater = new UpdateServiceContractWorkingDays();
        updater.updateServiceContracts(scope);
    }

    public void finish(Database.BatchableContext bc) {
        if(!Test.isRunningTest()){
            RefreshDashboards.refresh();
        }
    }
}