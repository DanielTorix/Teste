/**
    * @description   Async Apex Job repository interface with all SOQL, SOSL and DML operations
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_IREP_AsyncApexJob {
    List<AsyncApexJob> getAsyncApexJobListByIdSet(Set<Id> jobIdSet);
}