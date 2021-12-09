/**
@author Guilherme Charro
@date    08/10/2021
@description Test class for TW_Contact_CheckGDPR
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/10/2021         Original Version                         100
Hugo Rodrigues                28/10/2021          Updated to work with RecordType of Cards   100
*/
@isTest
private class TW_Contact_CheckGDPRTest {
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
    static void TW_Contact_CheckGDPRTest() {
        IREP_Contact contactRepository = (REP_Contact)mocks.mock(REP_Contact.class);
        IREP_EncryptedDataGDPR encryptedDataRepository = (REP_EncryptedDataGDPR)mocks.mock(REP_EncryptedDataGDPR.class);
        IDO_Contact contactDomain = (DO_Contact)mocks.mock(DO_Contact.class);
        IREP_CEPSkipValidationRules cepSkipValidationRulesRepository = (REP_CEPSkipValidationRules )mocks.mock(REP_CEPSkipValidationRules.class);

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                MobilePhone = '999999999',
                GeneralGDPR__c = DO_Contact.Contact_GDPR_NO,
                RecordTypeID= Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS
            )
        };

        Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
        oldContactMap.put(contactList[0].Id, new Contact(Id = fflib_IDGenerator.generate(Contact.sObjectType)));

        List<EncryptedDataGDPR__c> encryptedDataList = new List<EncryptedDataGDPR__c>{
            new EncryptedDataGDPR__c(
                Id = fflib_IDGenerator.generate(EncryptedDataGDPR__c.sObjectType)
            )
        };

        mocks.startStubbing();
        mocks.when(contactRepository.updateSObjects((List<Contact>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.when(contactDomain.createContact((Id)  fflib_match.anyObject())).thenReturn(contactList[0]);
        mocks.when(encryptedDataRepository.insertSObjects((List<EncryptedDataGDPR__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.when(cepSkipValidationRulesRepository.updateSObjects((List<CEPSkipValidationRules__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();

        TW_Contact_CheckGDPR jobExecutionWorker = new TW_Contact_CheckGDPR();
        jobExecutionWorker = new TW_Contact_CheckGDPR(contactRepository, encryptedDataRepository, contactDomain, cepSkipValidationRulesRepository);
        
        jobExecutionWorker.execute(contactList, oldContactMap);

        ((IREP_Contact)mocks.verify(contactRepository, 1)).updateSObjects((List<Contact>) fflib_match.anyList());
        ((IREP_EncryptedDataGDPR)mocks.verify(encryptedDataRepository, 1)).insertSObjects((List<EncryptedDataGDPR__c>) fflib_match.anyList());
        ((IDO_Contact)mocks.verify(contactDomain, 1)).createContact((Id) fflib_match.anyObject());
        ((IREP_CEPSkipValidationRules)mocks.verify(cepSkipValidationRulesRepository, 2)).updateSObjects((List<CEPSkipValidationRules__c>) fflib_match.anyList());
    }
}