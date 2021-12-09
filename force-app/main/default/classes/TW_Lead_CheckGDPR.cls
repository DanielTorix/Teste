/**
* @description   worker class to check if GDPR was accepted or not
* @testClass     TW_Lead_CheckGDPRTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               28/09/2021          Created Lead Worker
* ------------------------------------------------------------------------------------ 
*/
public without sharing class TW_Lead_CheckGDPR {
    private IREP_EncryptedDataGDPR encryptedDataRepository;

    /**
    * @description constructor
    * @author Guilherme Charro | 29-09-2021 
    **/
    public TW_Lead_CheckGDPR(){
        this.encryptedDataRepository = new REP_EncryptedDataGDPR();
    }
   
    /**
    * @description constructor for test class
    * @author Guilherme Charro | 29-09-2021 
    **/
    @TestVisible
    private TW_Lead_CheckGDPR(IREP_EncryptedDataGDPR encryptedDataRepository){
        this.encryptedDataRepository = encryptedDataRepository;
    }

    /**
    * @description execute method
    * @author Guilherme Charro | 29-09-2021 
    **/
    public void execute(List<Lead> leadList, Map<Id,Lead> leadOldMap) {
        List<EncryptedDataGDPR__c> encryptedDataToInsertList = new List<EncryptedDataGDPR__c>();

        for (Lead leadUpdated : leadList) {
            if(leadUpdated.GeneralGDPR__c == DO_Lead.LEAD_GDPR_NO && leadUpdated.GeneralGDPR__c != leadOldMap.get(leadUpdated.Id).GeneralGDPR__c){
                EncryptedDataGDPR__c encrypedDataRecord = DO_EncryptedDataGDPR.createEncryptedData(
                    DO_EncryptedDataGDPR.encryptData(leadUpdated.MobilePhone),
                    DO_EncryptedDataGDPR.encryptData(leadUpdated.Phone),
                    DO_EncryptedDataGDPR.encryptData(leadUpdated.Email)
                );

                if (encrypedDataRecord!=null) {
                    encryptedDataToInsertList.add(encrypedDataRecord);
                }
            }
        }

        if (!encryptedDataToInsertList.isEmpty()) {
            encryptedDataRepository.insertSObjects(encryptedDataToInsertList);
        }
    }
}