/**
* @description   EncryptedDataGDPR__c interface
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              30/09/2021         Created EncryptedDataGDPR__c interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_ContentDocumentLink extends FW_ISObjectRep{
    List<ContentDocumentLink> getFilesOnLead(Set<Id> leadIdsSet);
}