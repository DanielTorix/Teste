/**
* @description   BatchJob to update account company code
* @testClass     Async_UpdateAccCompanyCodeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               02/09/2021          created class
* ------------------------------------------------------------------------------------ 
*/
global class Async_UpdateAccCompanyCode extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{
    private IREP_AccountCountryRelatedSetting accountCountryRelatedRepository;
    public Map<String, AccountCountryRelatedSetting__mdt> relatedObjectsToUpdateMap = new Map<String, AccountCountryRelatedSetting__mdt>();
    public Set<Id> accountIdsSet;
    public List<String> keyList = new List<String>();

    global Async_UpdateAccCompanyCode(){
        accountCountryRelatedRepository = new REP_AccountCountryRelatedSetting();
    }

    @testVisible
    private Async_UpdateAccCompanyCode(IREP_AccountCountryRelatedSetting accountCountryRelatedRepository,FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep){
        this.accountCountryRelatedRepository = accountCountryRelatedRepository;
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if (relatedObjectsToUpdateMap.isEmpty()) {
            for(AccountCountryRelatedSetting__mdt metadataRecord : accountCountryRelatedRepository.getAllAccountCountryRelated()) {
                relatedObjectsToUpdateMap.put(metadataRecord.MasterLabel, metadataRecord);
            }
        }
		
        keyList = new List<String>(relatedObjectsToUpdateMap.keySet());
        String query = '';

        if (!String.isBlank(relatedObjectsToUpdateMap.get(keyList[0]).Objectfilter__c)) {
            query = 'SELECT Id, '+relatedObjectsToUpdateMap.get(keyList[0]).CountryAPIName__c+' , '+
            +relatedObjectsToUpdateMap.get(keyList[0]).AccountLookupAPIName__c+' , '+relatedObjectsToUpdateMap.get(keyList[0]).AccountRelationshipName__c+'.CompanyCode__r.Country__c'+
            +' FROM '+relatedObjectsToUpdateMap.get(keyList[0]).MasterLabel+
            +' WHERE '+relatedObjectsToUpdateMap.get(keyList[0]).AccountLookupAPIName__c+' IN :accountIdsSet'+
            +' AND '+relatedObjectsToUpdateMap.get(keyList[0]).Objectfilter__c;
        }else{
            query = 'SELECT Id, '+relatedObjectsToUpdateMap.get(keyList[0]).CountryAPIName__c+' , '+
            +relatedObjectsToUpdateMap.get(keyList[0]).AccountLookupAPIName__c+' , '+relatedObjectsToUpdateMap.get(keyList[0]).AccountRelationshipName__c+'.CompanyCode__r.Country__c'+
            +' FROM '+relatedObjectsToUpdateMap.get(keyList[0]).MasterLabel +
            +' WHERE '+relatedObjectsToUpdateMap.get(keyList[0]).AccountLookupAPIName__c+' IN :accountIdsSet';
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> sobjectList) {
        List<SObject> objectsToUpdateList = new List<SObject>();
        for (SObject objectProvided : sobjectList) { 
            if (objectProvided.get((String)relatedObjectsToUpdateMap.get(keyList[0]).CountryAPIName__c) != (String)objectProvided.getSobject('Account').getSobject('CompanyCode__r').get('Country__c')) {
                objectProvided.put(relatedObjectsToUpdateMap.get(keyList[0]).CountryAPIName__c, (String)objectProvided.getSobject('Account').getSobject('CompanyCode__r').get('Country__c'));
                objectsToUpdateList.add(objectProvided);
            }
        }

        if(!objectsToUpdateList.isEmpty()){
            Database.update(objectsToUpdateList, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
        relatedObjectsToUpdateMap.remove(keyList[0]);

        if (!relatedObjectsToUpdateMap.isEmpty()) {
            Async_UpdateAccCompanyCode updateOtherObjects = new Async_UpdateAccCompanyCode();
            updateOtherObjects.relatedObjectsToUpdateMap = relatedObjectsToUpdateMap;
            updateOtherObjects.accountIdsSet = accountIdsSet;
            Database.executeBatch(updateOtherObjects, 200);
        }
    }
}