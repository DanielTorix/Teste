/**
 * Created by mateuszbednarek on 09/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class DeleteAllErrorLogs implements Database.Batchable<sObject>{
    String query = 'SELECT Id FROM FPS_Bor_Error_Log__c';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FPS_Bor_Error_Log__c> scope){
        delete scope;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}