@isTest
public with sharing class TW_Case_FillComplementaryFieldsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @testSetup
    private static void makeData(){
        CEP_Configuration__c setting = new CEP_Configuration__c();
        setting.OMVEmailDomains__c = 'omv.com,petrom.com,borealisgroup.com,external.petrom.com,external.omv.com';
        insert setting;
    }
    
    @isTest
    private static void TW_Case_FillComplementaryFieldsTest() {
        ISL_CountryDefinitionFromParent countryDefinition = (SL_CountryDefinitionFromParent)mocks.mock(SL_CountryDefinitionFromParent.class);

        Test.startTest();
        List<Account> listAccount = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType)
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType)
            )
        };

        List<Case> listCase = new List<Case>();
        listCase.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                ContactId = fflib_IDGenerator.generate(Contact.sObjectType),
                AccountId = listAccount[0].Id
            )  
        );

        listCase[0] = (Case)fflib_ApexMocksUtils.setReadOnlyFields(
            listCase[0],
            Case.class,
            new Map<SObjectField, Object> {Case.RecordTypeId => DO_Case.CASE_RECORDTYPEID_CASE}
        );

        List<Case> listCase2 = new List<Case>();
        listCase2.add(
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Origin = DO_Case.CASE_ORIGIN_EMAIL,
                SuppliedEmail = 'teste@omv.com',
                AccountId = listAccount[1].Id
            )  
        );
        
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        oldCaseMap.put(listCase[0].Id, listCase2[0]);

        mocks.startStubbing();
        mocks.stopStubbing();

        TW_Case_FillComplementaryFields jobExecutionWorker = new TW_Case_FillComplementaryFields();
        jobExecutionWorker = new TW_Case_FillComplementaryFields(countryDefinition);
        
        jobExecutionWorker.execute(listCase, null);
        jobExecutionWorker.execute(listCase2, null);
        jobExecutionWorker.execute(listCase, oldCaseMap);
        Test.stopTest();
    }
}