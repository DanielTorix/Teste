/**
    * @description   Interface for the Parameters Repository
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_IREP_Parameters extends FW_ISObjectRep {
    List<Parameters__c> getParametersByParentId(Set<Id> parentIdSet);
    List<Parameters__c> getParametersByBatchDefinitionId(Set<Id> batchDefinitionIdSet);
    List<Parameters__c> getParametersByBatchDefinitionIdAndName(Set<Id> batchDefinitionIdSet, Set<String> parameterName);
}