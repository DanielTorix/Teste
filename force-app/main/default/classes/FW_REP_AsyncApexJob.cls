/**
    * @description   Async Apex Job repository class with all SOQL, SOSL and DML operations
    * @testClass     FW_REP_AsyncApexJobTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public inherited sharing class FW_REP_AsyncApexJob extends FW_SobjectRep implements FW_IREP_AsyncApexJob {
    
    public static final List<SObjectField> ASYNCAPEXJOB_FIELDS = new SObjectField[] {
        AsyncApexJob.Id, 
        AsyncApexJob.ParentJobId,
        AsyncApexJob.Status,
        AsyncApexJob.ExtendedStatus
    };

    /**
        *  @description:    Method to get a list of Async Apex Job through a set of Id
    */
    public List<AsyncApexJob> getAsyncApexJobListByIdSet(Set<Id> jobIdSet) {
        String query = new FW_QueryBuilder(AsyncApexJob.SObjectType)
            .selectFields(ASYNCAPEXJOB_FIELDS)
            .whereIn(AsyncApexJob.Id, new List<Id>(jobIdSet))
            .getQuery();
            
        return (List<AsyncApexJob>)Database.query(query);
    }
}