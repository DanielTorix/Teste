/**
    * @description   Batch & Scheduler to facilitate test class and reduce unitary
    *                   test dependency
    * @testClass     FW_TestBatchTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public class FW_TestBatch extends FW_AsyncHandler implements Database.Batchable<sObject>, Schedulable {

    public void execute(SchedulableContext sc){
        FW_TestBatch testBatch = new FW_TestBatch ();
        database.executebatch(testBatch,200);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Batch_Definition__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        Integer i = 1 / 1;
    }

    public void finish(Database.BatchableContext BC){ }
}