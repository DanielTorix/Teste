/**
* @description   BactJob to update OMV Entity on Lead object
* @testClass     Async_EmployeeEntityUpdateTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                03/11/2021          BactJob to update OMV Entity on Lead object
* ------------------------------------------------------------------------------------ 
*/
global class Async_EmployeeEntityUpdate extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{
   
    private IREP_OMVEntityEmployee oMVEntityRepository;
    private IREP_Lead leadRepository;
    private static final String STATUS = 'Status';
    private static final String OWNERIDFROMLEAD = 'OwnerIDFromLead';
    global Async_EmployeeEntityUpdate() {

        oMVEntityRepository = new REP_OMVEntityEmployee();
        leadRepository = new REP_Lead();

    }

    @testVisible
    private Async_EmployeeEntityUpdate(IREP_OMVEntityEmployee oMVEntityRepository,FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep, IREP_Lead leadRepository) {

        this.oMVEntityRepository = oMVEntityRepository;
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
        this.leadRepository = leadRepository;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        setAsyncApexJobId(bc.getJobId());
        List<String> statusList = getParameterValue(STATUS).split(',');
        List<String> userIdList = getParameterValue(OWNERIDFROMLEAD).split(',');
        FW_QueryBuilder query = new FW_QueryBuilder(Lead.SObjectType)
        .selectFields(REP_Lead.LEAD_FIELDS)
        .whereIn('Status',statusList)
        .whereIn('OwnerID',userIdList);
        return executeQuery(query);
    }

    global void execute(Database.BatchableContext bc, List<Lead> leadList) {
        
        Map<String,OMVEntityEmployee__c> oMVEntityEmployeeMap = new Map<String,OMVEntityEmployee__c>();
        List<Lead> leadToUpdateList = new List<Lead> ();
        Set<Id> ownerIdSet = new Set<Id>();
        
        for (Lead leadRecord : leadList) {
            ownerIdSet.add(leadRecord.OwnerId);    
        }

        for(OMVEntityEmployee__c omvEntity : oMVEntityRepository.getCompanyCodeByUserID( ownerIdSet ) ){
            oMVEntityEmployeeMap.put(omvEntity.EmployeeUser__c,omvEntity);
        }
        for(Lead leadRecord : leadList){  
            if(oMVEntityEmployeeMap.containsKey(leadRecord.OwnerID)){
                leadRecord.CompanyCode__c = oMVEntityEmployeeMap.get(leadRecord.OwnerID).OMVEntity__c;
                leadToUpdateList.add(leadRecord);
            }
            else{
                leadRecord.CompanyCode__c = null;
                leadToUpdateList.add(leadRecord);
            }
        }

        if(!leadToUpdateList.isEmpty()){
            FW_TriggerHandlerSettings__c skipTriggerLogic = FW_TriggerHandlerSettings__c.getInstance();
            skipTriggerLogic.All__c = true;
            upsert skipTriggerLogic;
            leadRepository.updateSObjects(leadToUpdateList);
            skipTriggerLogic.All__c = false;
            upsert skipTriggerLogic;
        }
    
    }

    global void finish(Database.BatchableContext bc) {
        finishBatch(bc.getJobId());
    }
}