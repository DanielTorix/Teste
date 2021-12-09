/**
    * @description   Interface for the Batch Definition Repository
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_IREP_BatchDefinition extends FW_ISObjectRep {

    List<Batch_Definition__c> getBatchDefinitionByIdSet(Set<Id> batchDefinitionIdSet);
    List<Batch_Definition__c> getBatchDefinitionByNameSet(Set<String> batchDefinitionNameSet);
}