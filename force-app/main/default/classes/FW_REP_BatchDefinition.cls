/**
    * @description   Batch Execution repository with all SOQL, SOSL and DML operations
    * @testClass     FW_REP_AsyncApexJobTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public inherited sharing class FW_REP_BatchDefinition extends FW_SobjectRep implements FW_IREP_BatchDefinition{
    
    public static final List<SObjectField> BATCHDEFINITION_FIELDS = new SObjectField[] {
        Batch_Definition__c.Id, 
        Batch_Definition__c.Name, 
        Batch_Definition__c.Batch_Name__c, 
        Batch_Definition__c.Class_Name__c,
        Batch_Definition__c.Job_Size__c, 
        Batch_Definition__c.SObject_API_Name__c 
    }; 

    /**
        *  @description:    retrieve batch definition records for a given batch definition Id set
    */
    public List<Batch_Definition__c> getBatchDefinitionByIdSet(Set<Id> batchDefinitionIdSet) {
         String query = new FW_QueryBuilder(Batch_Definition__c.SObjectType)
            .selectFields(BATCHDEFINITION_FIELDS)
            .whereIn(Batch_Definition__c.Id, new List<Id>(batchDefinitionIdSet))
            .getQuery();
            
        return (List<Batch_Definition__c>)Database.query(query);
    }

    /**
        *  @description:    retrieve batch definition records for a given batch definition Name set
    */
    public List<Batch_Definition__c> getBatchDefinitionByNameSet(Set<String> batchDefinitionNameSet) {
        String query = new FW_QueryBuilder(Batch_Definition__c.SObjectType)
           .selectFields(BATCHDEFINITION_FIELDS)
           .whereIn(Batch_Definition__c.Batch_Name__c, new List<String>(batchDefinitionNameSet))
           .getQuery();
           
       return (List<Batch_Definition__c>)Database.query(query);
   }
}