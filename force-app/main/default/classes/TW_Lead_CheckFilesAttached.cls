/**
* @description   worker class to check the lead has any files attached
* @testClass     TW_Lead_CheckFilesAttachedTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               30/09/2021          Created Lead Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_Lead_CheckFilesAttached {
    private IREP_ContentDocumentLink contentDocumentRepository;

    /**
    * @description constructor
    * @author Guilherme Charro | 30-09-2021 
    **/
    public TW_Lead_CheckFilesAttached(){
        this.contentDocumentRepository = new REP_ContentDocumentLink();
    }
   
    /**
    * @description constructor for test class
    * @author Guilherme Charro | 30-09-2021 
    **/
    @TestVisible
    private TW_Lead_CheckFilesAttached(IREP_ContentDocumentLink contentDocumentRepository){
        this.contentDocumentRepository = contentDocumentRepository;
    }

    /**
    * @description execute method
    * @author Guilherme Charro | 30-09-2021 
    **/
    public void execute(List<Lead> leadList, Map<Id,Lead> leadOldMap) {
        Map<Id, Lead> leadsToProcessMap = createLeadsToProcessMap(leadList, leadOldMap);

        Map<Id,Set<Id>> filesMap = createFilesMap(leadsToProcessMap.keySet());

        addErrorToLeads(leadsToProcessMap, filesMap);
    }

    /**
    * @description method to check the leads that need to be queried
    * @author Guilherme Charro | 30-09-2021 
    * @param leadList list of records from trigger
    * @param leadOldMap map of old values from trigger
    * @return return the map of leads that need to be queried in files
    **/
    private Map<Id, Lead> createLeadsToProcessMap(List<Lead> leadList, Map<Id,Lead> leadOldMap){
        Map<Id, Lead> leadsToProcessMap = new Map<Id, Lead>();
        for (Lead leadUpdated : leadList) {
            if (leadUpdated.ConfirmYouHaveWrittenConsent__c && leadOldMap.get(leadUpdated.Id).ConfirmYouHaveWrittenConsent__c) {
                leadsToProcessMap.put(leadUpdated.Id, leadUpdated);
            }
        }

        return leadsToProcessMap;
    }

    /**
    * @description method to create a map from a query on files attached on the leads
    * @author Guilherme Charro | 30-09-2021 
    * @param leadsToSearchSet set of ids that are gonna be used on the query
    * @return return the map with the lead ID as the key and Set of ids from the files attached to that lead as values
    **/
    private Map<Id,Set<Id>> createFilesMap(Set<Id> leadsToSearchSet){
        Map<Id,Set<Id>> filesMap = new Map<Id,Set<Id>>();
        if (!leadsToSearchSet.isEmpty()) {
            for (ContentDocumentLink file : contentDocumentRepository.getFilesOnLead(leadsToSearchSet)) {
                if (filesMap.containsKey(file.LinkedEntityId)) {
                    filesMap.get(file.LinkedEntityId).add(file.Id);
                }else{
                    filesMap.put(file.LinkedEntityId, new Set<Id>{file.Id});
                }
            }
        }

        return filesMap;
    }

    /**
    * @description method to check if lead should be added an error
    * @author Guilherme Charro | 30-09-2021 
    * @param leadsToProcessMap Map of leads to be checked
    * @param filesMap Map of files to compare with leads
    **/
    private void addErrorToLeads(Map<Id, Lead> leadsToProcessMap, Map<Id,Set<Id>> filesMap){
        for (Id leadUpdated : leadsToProcessMap.keySet()) {
            if (!filesMap.containsKey(leadsToProcessMap.get(leadUpdated).Id)) {
                leadsToProcessMap.get(leadUpdated).addError(System.Label.LeadnoAttachmentError);
            }
        }
    }
}