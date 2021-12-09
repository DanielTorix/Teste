/**
* @description   EncryptedDataGDPR__c Repository
* @testClass     REP_EncryptedDataGDPRTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              28/09/2021         Created EncryptedDataGDPR__c Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_EncryptedDataGDPR extends FW_SobjectRep implements IREP_EncryptedDataGDPR{
    /**
    * @description method to search if there are any values of the newly inserted lead already in the EncryptedDataGDPR__c object
    * @author Guilherme Charro | 29-09-2021 
    * @param dataToSearchList list of strings that will be used to compare if these values are already in the database
    * @return List<REP_EncryptedDataGDPR> return the list of records returned
    **/
    public List<EncryptedDataGDPR__c> getEncryptedData(List<String> dataToSearchList){
        return [
            SELECT Id, BusinessPhoneEncrypted__c, EmailEncrypted__c, MobilePhoneEncrypted__c 
            FROM EncryptedDataGDPR__c 
            WHERE BusinessPhoneEncrypted__c IN :dataToSearchList 
            OR EmailEncrypted__c IN :dataToSearchList 
            OR MobilePhoneEncrypted__c IN :dataToSearchList
        ];
    }
}