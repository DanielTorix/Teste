/**
* @description   worker class to check if the data already exists in database
* @testClass     TW_Contact_CheckDataEncryptedTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               01/10/2021          Created Contact Worker
* Hugo Rodrigues                 28/10/2021          Updated to work with RecordType of Cards   
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_Contact_CheckDataEncrypted {
    private IREP_EncryptedDataGDPR encryptedDataRepository;

    /**
    * @description constructor
    * @author Guilherme Charro | 29-09-2021 
    **/
    public TW_Contact_CheckDataEncrypted(){
        this.encryptedDataRepository = new REP_EncryptedDataGDPR();
    }
   
    /**
    * @description constructor for test class
    * @author Guilherme Charro | 29-09-2021 
    **/
    @TestVisible
    private TW_Contact_CheckDataEncrypted(IREP_EncryptedDataGDPR encryptedDataRepository){
        this.encryptedDataRepository = encryptedDataRepository;
    }

    /**
    * @description execute method
    * @author Guilherme Charro | 29-09-2021 
    **/
    public void execute(List<Contact> contactList) {
        List<String> dataToSearchList = new List<String>();
        List<String> dataToDeleteList = new List<String>();
        ID recordTypeContactID = Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS;
        for (Contact contactInserted : contactList) {
            if (contactInserted.GeneralGDPR__c != DO_Lead.LEAD_GDPR_YES 
            && contactInserted.RecordTypeID==recordTypeContactID
            && contactInserted.ConfirmYouCalledTheContact__c != true
            && contactInserted.ConfirmYouHaveWrittenConsent__c != true) {
                dataToSearchList.add(DO_EncryptedDataGDPR.encryptData(String.valueOf(contactInserted.MobilePhone)));
                dataToSearchList.add(DO_EncryptedDataGDPR.encryptData(contactInserted.OtherPhone));
                dataToSearchList.add(DO_EncryptedDataGDPR.encryptData(contactInserted.Email)); 
            }else if(contactInserted.RecordTypeID==recordTypeContactID){
                dataToDeleteList.add(DO_EncryptedDataGDPR.encryptData(String.valueOf(contactInserted.MobilePhone)));
                dataToDeleteList.add(DO_EncryptedDataGDPR.encryptData(contactInserted.OtherPhone));
                dataToDeleteList.add(DO_EncryptedDataGDPR.encryptData(contactInserted.Email)); 
            }                      
        }

        if (!dataToDeleteList.isEmpty()) {
            deleteEncryptedData(dataToDeleteList);
        }

        List<EncryptedDataGDPR__c> encryptedDataList = new List<EncryptedDataGDPR__c>();
        if (!dataToSearchList.isEmpty()) {
            encryptedDataList = encryptedDataRepository.getEncryptedData(dataToSearchList);
        }

        for (Contact contactInserted : contactList) {
            for (EncryptedDataGDPR__c encryptedData : encryptedDataList) {
                if (isToAddError(contactInserted, encryptedData)) {
                    contactInserted.addError(System.Label.GDPRError);
                    break;
                }
            }
        }
    }

    /**
    * @description method to compare values in EncryptedDataGDPR__c object with the contact inserted
    * @author Guilherme Charro | 29-09-2021 
    * @param contactRecord contact record to compare the values with the encrypted data
    * @param encryptedDataRecord EncryptedDataGDPR__c record to compare the values with the contact data
    * @return return true or false 
    **/
    private boolean isToAddError(Contact contactRecord, EncryptedDataGDPR__c encryptedDataRecord){
        return ((DO_EncryptedDataGDPR.encryptData(String.valueOf(contactRecord.MobilePhone)) == encryptedDataRecord.MobilePhoneEncrypted__c && encryptedDataRecord.MobilePhoneEncrypted__c != null)
            || (DO_EncryptedDataGDPR.encryptData(contactRecord.OtherPhone) == encryptedDataRecord.BusinessPhoneEncrypted__c && encryptedDataRecord.BusinessPhoneEncrypted__c != null)
            || (DO_EncryptedDataGDPR.encryptData(contactRecord.Email) == encryptedDataRecord.EmailEncrypted__c && encryptedDataRecord.EmailEncrypted__c != null));
    }

    /**
    * @description method to delete values in EncryptedDataGDPR__c if they already exist
    * @author Guilherme Charro | 06-10-2021 
    * @param dataToDeleteList List of data to check if exists in database
    **/
    private void deleteEncryptedData(List<String> dataToDeleteList){
        List<EncryptedDataGDPR__c> encryptedDataDeleteList = new List<EncryptedDataGDPR__c>();
        for (EncryptedDataGDPR__c encryptedData : encryptedDataRepository.getEncryptedData(dataToDeleteList)) {
            encryptedDataDeleteList.add(encryptedData);
            break;
        }

        if (!encryptedDataDeleteList.isEmpty()) {
            encryptedDataRepository.deleteSObjects(encryptedDataDeleteList);
        }
    }
}