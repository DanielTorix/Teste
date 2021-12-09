/**
    * @description   Class to get a list of Paramenter__c
    * @testClass     FW_REP_ParametersTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public with sharing class FW_REP_Parameters extends FW_SobjectRep implements FW_IREP_Parameters{

    public static final List<SObjectField> PARAMETERS_FIELDS = new SObjectField[] {
        Parameters__c.Id,
        Parameters__c.Name,
        Parameters__c.Batch_Definition__c,
        Parameters__c.Job_Execution__c,
        Parameters__c.Value__c,
        Parameters__c.Description__c
    };

    /**
        * @description:    Method to get all parameters by BatchDefinition Id set
    */
    public List<Parameters__c> getParametersByParentId(Set<Id> parentIdSet) {
        String query = new FW_QueryBuilder(Parameters__c.SObjectType)
            .selectFields(PARAMETERS_FIELDS)
            .setWhere('Batch_Definition__c IN :parentIdSet OR Job_Execution__c IN :parentIdSet')
            .getQuery();
        return (List<Parameters__c>)Database.query(query);
    }

    /**
        * @description:    Method to get all parameters by BatchDefinition Id set
    */
    public List<Parameters__c> getParametersByBatchDefinitionId(Set<Id> batchDefinitionIdSet) {
        String query = new FW_QueryBuilder(Parameters__c.SObjectType)
            .selectFields(PARAMETERS_FIELDS)
            .setWhere('Batch_Definition__c IN :batchDefinitionIdSet')
            .getQuery();
        return (List<Parameters__c>)Database.query(query);
    }

    /**
        * @description:    Method to get all parameters by BatchDefinition Id set and Name 
    */
    public List<Parameters__c> getParametersByBatchDefinitionIdAndName(Set<Id> batchDefinitionIdSet, Set<String> parameterName) {
        String query = new FW_QueryBuilder(Parameters__c.SObjectType)
            .selectFields(PARAMETERS_FIELDS)
            .setWhere('Batch_Definition__c IN :batchDefinitionIdSet And Name IN :parameterName')
            .getQuery();
        return (List<Parameters__c>)Database.query(query);
    }


}