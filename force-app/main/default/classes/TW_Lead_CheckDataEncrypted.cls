/**
* @description   worker class to check if the data already exists in database
* @testClass     TW_Lead_CheckDataEncryptedTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               28/09/2021          Created Lead Worker
* ------------------------------------------------------------------------------------ 
*/
public without sharing class TW_Lead_CheckDataEncrypted {
    private IREP_EncryptedDataGDPR encryptedDataRepository;

    /**
    * @description constructor
    * @author Guilherme Charro | 29-09-2021 
    **/
    public TW_Lead_CheckDataEncrypted(){
        this.encryptedDataRepository = new REP_EncryptedDataGDPR();
    }
   
    /**
    * @description constructor for test class
    * @author Guilherme Charro | 29-09-2021 
    **/
    @TestVisible
    private TW_Lead_CheckDataEncrypted(IREP_EncryptedDataGDPR encryptedDataRepository){
        this.encryptedDataRepository = encryptedDataRepository;
    }

    /**
    * @description execute method
    * @author Guilherme Charro | 29-09-2021 
    **/
    public void execute(List<Lead> leadList) {
        List<String> dataToSearchList = new List<String>();
        List<String> dataToDeleteList = new List<String>();
        for (Lead leadInserted : leadList) {
            if (leadInserted.GeneralGDPR__c != DO_Lead.LEAD_GDPR_YES
            && leadInserted.ConfirmYouCalledTheContact__c != true
            && leadInserted.ConfirmYouHaveWrittenConsent__c != true) {
                dataToSearchList.add(DO_EncryptedDataGDPR.encryptData(leadInserted.MobilePhone));
                dataToSearchList.add(DO_EncryptedDataGDPR.encryptData(leadInserted.Phone));
                dataToSearchList.add(DO_EncryptedDataGDPR.encryptData(leadInserted.Email)); 
            }else{
                dataToDeleteList.add(DO_EncryptedDataGDPR.encryptData(leadInserted.MobilePhone));
                dataToDeleteList.add(DO_EncryptedDataGDPR.encryptData(leadInserted.Phone));
                dataToDeleteList.add(DO_EncryptedDataGDPR.encryptData(leadInserted.Email)); 
            }                      
        }

        if (!dataToDeleteList.isEmpty()) {
            deleteEncryptedData(dataToDeleteList);
        }

        List<EncryptedDataGDPR__c> encryptedDataList = new List<EncryptedDataGDPR__c>();
        if (!dataToSearchList.isEmpty()) {
            encryptedDataList = encryptedDataRepository.getEncryptedData(dataToSearchList);
        }

        for (Lead leadInserted : leadList) {
            for (EncryptedDataGDPR__c encryptedData : encryptedDataList) {
                if (isToAddError(leadInserted, encryptedData)) {
                    leadInserted.addError(System.Label.GDPRError);
                    break;
                }
            }
        }
    }

    /**
    * @description method to compare values in EncryptedDataGDPR__c object with the lead inserted
    * @author Guilherme Charro | 29-09-2021 
    * @param leadRecord lead record to compare the values with the encrypted data
    * @param encryptedDataRecord EncryptedDataGDPR__c record to compare the values with the lead data
    * @return return true or false 
    **/
    private boolean isToAddError(Lead leadRecord, EncryptedDataGDPR__c encryptedDataRecord){
        return ((DO_EncryptedDataGDPR.encryptData(leadRecord.MobilePhone) == encryptedDataRecord.MobilePhoneEncrypted__c && encryptedDataRecord.MobilePhoneEncrypted__c != null)
            || (DO_EncryptedDataGDPR.encryptData(leadRecord.Phone) == encryptedDataRecord.BusinessPhoneEncrypted__c && encryptedDataRecord.BusinessPhoneEncrypted__c != null)
            || (DO_EncryptedDataGDPR.encryptData(leadRecord.Email) == encryptedDataRecord.EmailEncrypted__c && encryptedDataRecord.EmailEncrypted__c != null));
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