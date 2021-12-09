/**
* @description   Service class to define when was the last time related activity happened in the contact
* @testClass     SL_ContactRelatedActivityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               09/11/2021           Created service class
* ------------------------------------------------------------------------------------ 
*/
public without sharing class SL_ContactRelatedActivity implements ISL_ContactRelatedActivity{
    private IREP_Contact contactRepository;
    private IREP_CEPSkipValidationRules cepSkipValidationRulesRepository;
    private IREP_TriggerHandlerSettings triggerHandlerSettingsRepository;
    
    public SL_ContactRelatedActivity (){
        this.contactRepository = new REP_Contact();
        this.cepSkipValidationRulesRepository = new REP_CEPSkipValidationRules();
        this.triggerHandlerSettingsRepository = new REP_TriggerHandlerSettings();
    }
    
    @TestVisible
    private SL_ContactRelatedActivity (IREP_Contact contactRepository, IREP_CEPSkipValidationRules cepSkipValidationRulesRepository, IREP_TriggerHandlerSettings triggerHandlerSettingsRepository){
        this.contactRepository = contactRepository;
        this.cepSkipValidationRulesRepository = cepSkipValidationRulesRepository;
        this.triggerHandlerSettingsRepository = triggerHandlerSettingsRepository;
    }

    public void setContactRelatedActivity(Set<Id> contactIdSet) {
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact contactReturned : contactRepository.getContactById(contactIdSet)) {
            if (contactReturned.RecordTypeId == DO_Contact.CONTACT_RECORDTYPEID_CEPCARDS) {
                contactsToUpdate.add(
                    new Contact(
                        Id = contactReturned.Id,
                        RelatedActivityDate__c = DATE.TODAY()
                    )
                );
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            CEPSkipValidationRules__c skipValidation = CEPSkipValidationRules__c.getOrgDefaults();
            skipValidation.Contact__c = true;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});

            FW_TriggerHandlerSettings__c skipTrigger = FW_TriggerHandlerSettings__c.getOrgDefaults();
            skipTrigger.Contact__c = true;
            triggerHandlerSettingsRepository.updateSObjects(new List<FW_TriggerHandlerSettings__c>{skipTrigger});

            contactRepository.updateSObjects(contactsToUpdate);         
            
            skipValidation.Contact__c = false;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});

            skipTrigger.Contact__c = false;
            triggerHandlerSettingsRepository.updateSObjects(new List<FW_TriggerHandlerSettings__c>{skipTrigger});
        }
    }
}