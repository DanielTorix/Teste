/**
* @description   worker class to update Unique Field and Show errors
* @testClass     TW_OMVEntityEmployee_UpdateUniqueIDTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               20/10/2021         Created the class
* Hugo Rodrigues               04/03/2021         updated to meet US39484 requirements
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_OMVEntityEmployee_UpdateUniqueID {

    private IREP_OMVEntityEmployee oMVEntityRepository;
    private FW_IREP_BatchDefinition batchDefRep;
    private FW_IREP_JobExecution jobExecutionRep;
    private FW_IDO_JobExecution jobExecutionDO;
    private FW_IREP_Parameters parameterRep;

    public TW_OMVEntityEmployee_UpdateUniqueID(){
        this.oMVEntityRepository = new REP_OMVEntityEmployee();
        this.batchDefRep = new FW_REP_BatchDefinition();
        this.jobExecutionRep = new FW_REP_JobExecution();
        this.jobExecutionDO = new FW_DO_JobExecution();
        this.parameterRep = new FW_REP_Parameters();
        
    }
    
    @TestVisible
    private TW_OMVEntityEmployee_UpdateUniqueID(IREP_OMVEntityEmployee oMVEntityRepository,FW_IREP_BatchDefinition batchDefRep, FW_IREP_JobExecution jobExecutionRep, FW_IDO_JobExecution jobExecutionDO,FW_IREP_Parameters parameterRep){
        this.oMVEntityRepository = oMVEntityRepository;
        this.batchDefRep = batchDefRep;
        this.jobExecutionRep = jobExecutionRep;
        this.jobExecutionDO = jobExecutionDO;
        this.parameterRep = parameterRep;
    }
    
    public void execute(List<OMVEntityEmployee__c> oMVList, Map<Id,OMVEntityEmployee__c> oldOmvMap) {
        Set<ID> userIDSet = new Set<ID>();
        List<OMVEntityEmployee__c> omvEmployeeToUpdatedList = new List<OMVEntityEmployee__c>();
        List<OMVEntityEmployee__c> oMVEntityEmployeeList =new List<OMVEntityEmployee__c>();
        Map<String,OMVEntityEmployee__c> oMVEntityEmployeeMap = new Map<String,OMVEntityEmployee__c>();
        Set<ID> userBatchIDSet = new Set<ID>();
        if(oMVList==null){
            for(OMVEntityEmployee__c entityRecord :oldOmvMap.Values()){
                userBatchIDSet.add(entityRecord.EmployeeUser__c);
            }
        }
        else{
            for(OMVEntityEmployee__c entityRecord : oMVList){
                if(entityRecord.EmployeeUser__c ==null){
                    entityRecord.addError(Label.ApexOMVEntityEmptyError);
                }
                else if(oldOmvMap == null){
                        userIDSet.add(entityRecord.EmployeeUser__c);
                        omvEmployeeToUpdatedList.add(entityRecord);
                        userBatchIDSet.add(entityRecord.EmployeeUser__c);
                }
                else if(oldOmvMap != null && (entityRecord.UniqueKey__c != oldOmvMap.get(entityRecord.Id).UniqueKey__c || entityRecord.EmployeeUser__c != oldOmvMap.get(entityRecord.Id).EmployeeUser__c)){
                    entityRecord.addError(Label.ApexOMVEntityChangeError);
                }
                else if(oldOmvMap != null && entityRecord.OMVEntity__c != oldOmvMap.get(entityRecord.Id).OMVEntity__c ){
                    userBatchIDSet.add(entityRecord.EmployeeUser__c);
                }
            }
        }

        if(!userIDSet.isEmpty()){
             oMVEntityEmployeeList= oMVEntityRepository.getCompanyCodeByUserID(userIDSet);
        }

        for(OMVEntityEmployee__c omvEntity : oMVEntityEmployeeList){
            oMVEntityEmployeeMap.put(omvEntity.EmployeeUser__c,omvEntity);
        }

        if(!oMVEntityEmployeeMap.isEmpty()){
            for (OMVEntityEmployee__c entityRecord :omvEmployeeToUpdatedList){
                if(oMVEntityEmployeeMap.containsKey(entityRecord.EmployeeUser__c)){
                    entityRecord.addError(Label.ApexUserChangeError + ' ' + oMVEntityEmployeeMap.get(entityRecord.EmployeeUser__c).OMVEntity__r.Name + Label.ApexUserChangeError2);
                }
                else{
                    entityRecord.UniqueKey__c = entityRecord.EmployeeUser__c;
                }
            }
        }
        if(!userBatchIDSet.isEmpty()){
            List<Batch_Definition__c> bdList = batchDefRep.getBatchDefinitionByNameSet(new Set<String>{'EmployeeEntityUpdate'});

            
        if(bdList.isEmpty()){
            createErrorLog();
        }else{
            list<Parameters__c> parameterList = parameterRep.getParametersByBatchDefinitionIdAndName(new Set<ID>{bdList[0].id},new Set<String>{'OwnerIDFromLead'});
            for(Parameters__c parameter : parameterList){
                parameter.Value__c = string.valueof(userBatchIDSet).replace('{', '').replace('}', '');
            }
            if(!parameterList.isEmpty()){
                parameterRep.updateSObjects(parameterList);
            }
            
            jobExecutionRep.insertSObjects(new list<Job_Execution__c>{jobExecutionDO.createJobExecutionsFromBD(bdList[0].id)});
            
        }

       }
    }
    
    /**  
        *  @description:    Create an error log record
    **/ 
    private void createErrorLog(){
        FW_ErrorAndMonitoringLog errorLog = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setErrorMessage('Batch execution not found for EmployeeEntityUpdate at '+Datetime.now())
                            .setOrigin(String.valueOf(this))
                            .setCategory(FW_ErrorAndMonitoringLog.categoryType.Apex_Class)
                            .setActorId(UserInfo.getUserId())
                            .build();

        new FW_SystemNotificationPublr(errorLog);
    }

}