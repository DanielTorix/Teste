/**
* @description   interface for EncryptedDataGDPR__c domain object class
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                29/09/2021          Created interface for EncryptedDataGDPR__c domain
* ------------------------------------------------------------------------------------ 
*/
public interface IDO_EncryptedDataGDPR {
    String encryptData(String data);
    EncryptedDataGDPR__c createEncryptedData(String mobile, String business, String email);
}