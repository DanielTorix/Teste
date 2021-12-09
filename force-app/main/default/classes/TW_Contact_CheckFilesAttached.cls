/**
* @description   worker class to check the contact has any files attached
* @testClass     TW_Contact_CheckFilesAttachedTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               04/10/2021          Created contact Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_Contact_CheckFilesAttached {
    private IREP_ContentDocumentLink contentDocumentRepository;

    /**
    * @description constructor
    * @author Guilherme Charro | 04/10/2021 
    **/
    public TW_Contact_CheckFilesAttached(){
        this.contentDocumentRepository = new REP_ContentDocumentLink();
    }
   
    /**
    * @description constructor for test class
    * @author Guilherme Charro | 04/10/2021 
    **/
    @TestVisible
    private TW_Contact_CheckFilesAttached(IREP_ContentDocumentLink contentDocumentRepository){
        this.contentDocumentRepository = contentDocumentRepository;
    }

    /**
    * @description execute method
    * @author Guilherme Charro | 04/10/2021 
    **/
    public void execute(List<Contact> contactList, Map<Id,Contact> contactOldMap) {
        Map<Id, Contact> contactsToProcessMap = createContactsToProcessMap(contactList, contactOldMap);

        Map<Id,Set<Id>> filesMap = createFilesMap(contactsToProcessMap.keySet());

        addErrorToContacts(contactsToProcessMap, filesMap);
    }

    /**
    * @description method to check the contacts that need to be queried
    * @author Guilherme Charro | 04/10/2021 
    * @param contactList list of records from trigger
    * @param contactOldMap map of old values from trigger
    * @return return the map of contacts that need to be queried in files
    **/
    private Map<Id, Contact> createContactsToProcessMap(List<Contact> contactList, Map<Id,Contact> contactOldMap){
        Map<Id, Contact> contactToProcessMap = new Map<Id, Contact>();
        ID recordTypeContactID = Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS;
        for (Contact contactUpdated : contactList) {
            if (contactUpdated.ConfirmYouHaveWrittenConsent__c && contactOldMap.get(contactUpdated.Id).ConfirmYouHaveWrittenConsent__c && contactUpdated.RecordTypeID==recordTypeContactID) {
                contactToProcessMap.put(contactUpdated.Id, contactUpdated);
            }
        }

        return contactToProcessMap;
    }

    /**
    * @description method to create a map from a query on files attached on the contacts
    * @author Guilherme Charro | 04/10/2021 
    * @param contactsToSearchSet set of ids that are gonna be used on the query
    * @return return the map with the contact ID as the key and Set of ids from the files attached to that contact as values
    **/
    private Map<Id,Set<Id>> createFilesMap(Set<Id> contactsToSearchSet){
        Map<Id,Set<Id>> filesMap = new Map<Id,Set<Id>>();
        if (!contactsToSearchSet.isEmpty()) {
            for (ContentDocumentLink file : contentDocumentRepository.getFilesOnLead(contactsToSearchSet)) {
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
    * @description method to check if contact should be added an error
    * @author Guilherme Charro | 30-09-2021 
    * @param contactsToProcessMap Map of contacts to be checked
    * @param filesMap Map of files to compare with contacts
    **/
    private void addErrorToContacts(Map<Id, Contact> contactsToProcessMap, Map<Id,Set<Id>> filesMap){
        for (Id contactUpdated : contactsToProcessMap.keySet()) {
            if (!filesMap.containsKey(contactsToProcessMap.get(contactUpdated).Id)) {
                contactsToProcessMap.get(contactUpdated).addError(System.Label.LeadnoAttachmentError);
            }
        }
    }
}