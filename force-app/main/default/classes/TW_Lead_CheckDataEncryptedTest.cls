/**
@author Guilherme Charro
@date    08/10/2021
@description Test class for TW_Lead_CheckDataEncrypted
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/10/2021         Original Version                         100
*/
@isTest
private class TW_Lead_CheckDataEncryptedTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @testSetup
    private static void makeData(){
        String key = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        String vector = key.substring(0, 16);
        String algorithm = 'AES128';
        insert new CEPEncrypt__c(
            SetupOwnerId=UserInfo.getOrganizationId(),
            Key__c = key,
            AlgorithmName__c = algorithm,
            Vector__c = vector
        );
    }

    @isTest
    static void TW_Lead_CheckGDPRTest() {
        IREP_EncryptedDataGDPR encryptedDataRepository = (REP_EncryptedDataGDPR)mocks.mock(REP_EncryptedDataGDPR.class);

        List<Lead> leadList = new List<Lead>{
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                Email = 'teste@teste.com',
                GeneralGDPR__c = DO_Lead.LEAD_GDPR_NO
            ),
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                MobilePhone = '999999999',
                GeneralGDPR__c = DO_Lead.LEAD_GDPR_YES
            )
        };

        List<EncryptedDataGDPR__c> encryptedDataList = new List<EncryptedDataGDPR__c>{
            new EncryptedDataGDPR__c(
                Id = fflib_IDGenerator.generate(EncryptedDataGDPR__c.sObjectType),
                EmailEncrypted__c = DO_EncryptedDataGDPR.encryptData('teste@teste.com')
            ),
            new EncryptedDataGDPR__c(
                Id = fflib_IDGenerator.generate(EncryptedDataGDPR__c.sObjectType),
                MobilePhoneEncrypted__c = DO_EncryptedDataGDPR.encryptData('999999999')
            )
        };

        mocks.startStubbing();
        mocks.when(encryptedDataRepository.getEncryptedData((List<String>)  fflib_match.anyList())).thenReturn(encryptedDataList);
        mocks.when(encryptedDataRepository.deleteSObjects((List<EncryptedDataGDPR__c>)  fflib_match.anyList())).thenReturn(new List<Database.DeleteResult>());
        mocks.stopStubbing();

        TW_Lead_CheckDataEncrypted jobExecutionWorker = new TW_Lead_CheckDataEncrypted();
        jobExecutionWorker = new TW_Lead_CheckDataEncrypted(encryptedDataRepository);
        
        jobExecutionWorker.execute(leadList);

        ((IREP_EncryptedDataGDPR)mocks.verify(encryptedDataRepository, 2)).getEncryptedData((List<String>) fflib_match.anyList());
        ((IREP_EncryptedDataGDPR)mocks.verify(encryptedDataRepository, 1)).deleteSObjects((List<EncryptedDataGDPR__c>) fflib_match.anyList());
    }
}