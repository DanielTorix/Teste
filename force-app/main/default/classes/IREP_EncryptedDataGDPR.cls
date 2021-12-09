/**
* @description   EncryptedDataGDPR__c interface
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              28/09/2021         Created EncryptedDataGDPR__c interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_EncryptedDataGDPR extends FW_ISObjectRep{
    List<EncryptedDataGDPR__c> getEncryptedData(List<String> dataToSearchList);
}