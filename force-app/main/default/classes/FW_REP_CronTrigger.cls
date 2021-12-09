/**
    * @description   User repository with all SOQL, SOSL and DML operations for CronTrigger
    * @testClass     FW_REP_CronTrigger
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer 					Date                Description  
    * ------------------------------------------------------------------------------------ 
    * Joana Neto					02/03/2021			Initial version
*/
public inherited sharing class FW_REP_CronTrigger extends FW_SObjectRep implements FW_IREP_CronTrigger {
    
	public static final List<SObjectField> CRONTRIGGER_FIELDS = new SObjectField[] {
        CronTrigger.Id,
        CronTrigger.NextFireTime
    };
        
    public static final List<SObjectField> CRONJOBDETAIL_FIELDS = new SObjectField[] {
        CronJobDetail.Name
    };
        
    /**
        * @description:    method to retrieve all CronTrigger items based on
        * 	a List<Id> of CronTrigger
    */
    public List<CronTrigger> getCronTriggerListById(List<Id> cronTriggerIdList) {
        String query = new FW_QueryBuilder(CronTrigger.SObjectType)
            .selectFields(CRONTRIGGER_FIELDS)
            .selectParentFields(CronTrigger.CronJobDetailId, CRONJOBDETAIL_FIELDS)
            .whereIn('Id', new List<Id>(cronTriggerIdList))
            .getQuery();
        return (List<CronTrigger>)Database.query(query);
    }
}