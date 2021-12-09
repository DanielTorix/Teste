/**
 * Created by mateuszbednarek on 21/01/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class ClearTemporaryStorageBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    String query = 'SELECT Id FROM FPS_Bor_Temporary_Storage__c';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FPS_Bor_Temporary_Storage__c> scope){
        delete scope;
    }
    public void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest()){
            UpdateWorkdayRecords.updateWorkdayRecords();
        }
    }
}