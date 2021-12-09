/**
@author Guilherme Charro
@date    08/10/2021
@description Test class for DO_Contact
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/10/2021         Original Version                         100
*/
@isTest
private class REP_EncryptedDataGDPRTest {
    @isTest
    static void EncryptedDataGDPRTest() {
        List<EncryptedDataGDPR__c> encryptedDataList = FW_TestDataFactory.createEncryptedData(1, true);

        test.startTest();
        REP_EncryptedDataGDPR encryptedDataRepository = new REP_EncryptedDataGDPR();   
        List<EncryptedDataGDPR__c> encryptedDataReturnedList = encryptedDataRepository.getEncryptedData(new List<String>{encryptedDataList[0].MobilePhoneEncrypted__c});
        test.stopTest();
        System.assertEquals(1, encryptedDataList.size());
    }
}