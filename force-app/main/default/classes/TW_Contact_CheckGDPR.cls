/**
* @description   worker class to check if GDPR was accepted or not
* @testClass     TW_Contact_CheckGDPRTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               01/10/2021          Created Contact Worker
* Hugo Rodrigues                 28/10/2021          Updated to work with RecordType of Cards   
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_Contact_CheckGDPR {
    private IREP_Contact contactRepository;
    private IREP_EncryptedDataGDPR encryptedDataRepository;
    private IDO_Contact contactDomain;
    private IREP_CEPSkipValidationRules cepSkipValidationRulesRepository;

    /**
    * @description constructor
    * @author Guilherme Charro | 29-09-2021 
    **/
    public TW_Contact_CheckGDPR(){
        this.contactRepository = new REP_Contact();
        this.encryptedDataRepository = new REP_EncryptedDataGDPR();
        this.contactDomain = new DO_Contact();
        this.cepSkipValidationRulesRepository = new REP_CEPSkipValidationRules();
    }
   
    /**
    * @description constructor for test class
    * @author Guilherme Charro | 29-09-2021 
    **/
    @TestVisible
    private TW_Contact_CheckGDPR(IREP_Contact contactRepository, IREP_EncryptedDataGDPR encryptedDataRepository, IDO_Contact contactDomain, IREP_CEPSkipValidationRules cepSkipValidationRulesRepository){
        this.contactRepository = contactRepository;
        this.encryptedDataRepository = encryptedDataRepository;
        this.contactDomain = contactDomain;
        this.cepSkipValidationRulesRepository = cepSkipValidationRulesRepository;
    }

    /**
    * @description execute method
    * @author Guilherme Charro | 29-09-2021 
    **/
    public void execute(List<Contact> contactList, Map<Id,Contact> contactOldMap) {
        List<contact> contactsToUpdateList = new List<contact>();
        List<EncryptedDataGDPR__c> encryptedDataToInsertList = new List<EncryptedDataGDPR__c>();
        ID recordTypeContactID = Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS;
        for (Contact contactUpdated : contactList) {
            if(contactUpdated.GeneralGDPR__c == DO_Contact.Contact_GDPR_NO && contactUpdated.GeneralGDPR__c != contactOldMap.get(contactUpdated.Id).GeneralGDPR__c && contactUpdated.RecordTypeID==recordTypeContactID){
                EncryptedDataGDPR__c encrypedDataRecord = DO_EncryptedDataGDPR.createEncryptedData(
                    DO_EncryptedDataGDPR.encryptData(String.valueOf(contactUpdated.MobilePhone)),
                    DO_EncryptedDataGDPR.encryptData(contactUpdated.OtherPhone),
                    DO_EncryptedDataGDPR.encryptData(contactUpdated.Email)
                );

                contactsToUpdateList.add(contactDomain.createContact(contactUpdated.Id));

                if (encrypedDataRecord!=null) {
                    encryptedDataToInsertList.add(encrypedDataRecord);
                }
            }
        }

        if (!encryptedDataToInsertList.isEmpty()) {
            encryptedDataRepository.insertSObjects(encryptedDataToInsertList);
        }

        if (!contactsToUpdateList.isEmpty()) {
            CEPSkipValidationRules__c skipValidation = CEPSkipValidationRules__c.getOrgDefaults();
            skipValidation.Contact__c = true;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});

            contactRepository.updateSObjects(contactsToUpdateList);

            skipValidation.Contact__c = false;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});
        }
    }
}