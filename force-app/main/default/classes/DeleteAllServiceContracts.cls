/**
 * Created by mateuszbednarek on 09/02/2021.
 */

public with sharing class DeleteAllServiceContracts implements Database.Batchable<sObject>{
    String query = 'SELECT Id FROM ServiceContract';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<ServiceContract> scope){
        delete scope;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}