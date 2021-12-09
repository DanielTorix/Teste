/**
    * @description   Job Execution repository with all SOQL, SOSL and DML operations
    * @testClass     FW_REP_JobExecutionTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public inherited sharing class FW_REP_JobExecution extends FW_SobjectRep implements FW_IREP_JobExecution{

    public static final List<SObjectField> JOBEXECUTION_FIELDS = new SObjectField[] {
        Job_Execution__c.Id,
        Job_Execution__c.AsyncApexJobId__c,
        Job_Execution__c.Batch_Definition__c,
        Job_Execution__c.Batch_Finish__c,
        Job_Execution__c.Batch_Start__c,
        Job_Execution__c.Job_Size__c,
        Job_Execution__c.Run_with_Defaults__c,
        Job_Execution__c.Scheduled_Execution_DateTime__c,
        Job_Execution__c.Status__c,
        Job_Execution__c.Batch_Definition_Name__c
    };

    /**
        * @description:    Method to get a list of Job Executions and related Batch Definitions
    */
    public List<Job_Execution__c> getJobExecwithBatchDefinitionsByIdSet(Set<Id> jobExecutionIdSet) {
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectFields(JOBEXECUTION_FIELDS)
            .selectParentFields(Job_Execution__c.Batch_Definition__c, FW_REP_BatchDefinition.BATCHDEFINITION_FIELDS)
            .whereIn(Job_Execution__c.Id, new List<Id>(jobExecutionIdSet))
            .getQuery();
        
        return (List<Job_Execution__c>)Database.query(query);
    }

    /**
        * @description:    Method to get a list of Job Executions by AsyncApexJobId
    */
    public List<Job_Execution__c> getJobExecutionByAsyncApexJobIdSet(Id AsyncApexJobId) {
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectFields(JOBEXECUTION_FIELDS)
            .whereIn(Job_Execution__c.AsyncApexJobId__c, new List<Id>{AsyncApexJobId})
            .getQuery();
        
        return (List<Job_Execution__c>)Database.query(query);
    }
    
    /**
        * @description:    Method to get a list of Job Executions by AsyncApexJob Id Set
    */
    public List<Job_Execution__c> getJobExecutionByAsyncApexJobIdSet(Set<Id> asyncApexJobIdSet) {
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectFields(JOBEXECUTION_FIELDS)
            .whereIn(Job_Execution__c.AsyncApexJobId__c, new List<Id>(asyncApexJobIdSet))
            .getQuery();
        
        return (List<Job_Execution__c>)Database.query(query);
    }
        
    /**
     * @description:    overriding extended class Method, needed to use partial in creation of job Execution on requests
    */
    public override List<Database.SaveResult> insertSObjects(List<SObject> sObjectList) {
        String errorStringTemplate = 'Error returned: {0} - {1} - {2}';
        List<FW_ErrorAndMonitoringLog> errorLogList = new List<FW_ErrorAndMonitoringLog>();
        List<Database.SaveResult> resultList = Database.insert(sobjectList, false);
        
        for(Integer i = 0; i < resultList.size(); i++) {

            if(!resultList[i].isSuccess()) {
                
                List<String> errorMessages = new List<String>();             
                for(Database.Error err : resultList[i].getErrors()) {
                    errorMessages.add(String.format(errorStringTemplate, new String[] {string.valueOf(err.getStatusCode()), err.getMessage(), String.valueOf(err.getFields())}));
                }

                Id recordId = sObjectList.get(i).Id;

                FW_ErrorAndMonitoringLog errorLog = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                                                    .setErrorMessage(string.join(errorMessages, '\n'))
                                                    .setRecordId(recordId)
                                                    .setCategory(FW_ErrorAndMonitoringLog.categoryType.Apex_Class)
                                                    .setActorId(UserInfo.getUserId())
                                                    .build();
                errorLogList.add(errorLog);
            }
        }
        if(errorLogList.size() > 0) {
            new FW_SystemNotificationPublr(errorLogList);
        }
        return resultList; 
    }
}