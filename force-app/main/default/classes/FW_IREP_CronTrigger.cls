/**
    * @description   Interface classe for CronTrigger repository with all SOQL, SOSL
    *  and DML operations
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer 					Date                Description  
    * ------------------------------------------------------------------------------------ 
    * Joana Neto					02/03/2021			Initial version
*/
public interface FW_IREP_CronTrigger extends FW_ISObjectRep {

    List<CronTrigger> getCronTriggerListById(List<Id> cronTriggerIdList);
    
}