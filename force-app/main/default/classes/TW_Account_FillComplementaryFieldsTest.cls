/**
@author Guilherme Charro
@date   08/09/2021
@description Test class for TW_Account_FillComplementaryFields
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/09/2021         Original Version                         100
*/
@isTest
public with sharing class TW_Account_FillComplementaryFieldsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void TW_Account_FillComplementaryFieldsTest() {
        IREP_CompanyCode companyCodeRepository = (REP_CompanyCode)mocks.mock(REP_CompanyCode.class);

        List<CompanyCode__c> companyCodeList = new List<CompanyCode__c>{
            new CompanyCode__c(
                Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType),
                Country__c = 'RO',
                Language__c = 'Romanian',
                CurrencyIsoCode = 'USD'
            ),
            new CompanyCode__c(
                Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType),
                Country__c = 'AT',
                Language__c = 'German',
                CurrencyIsoCode = 'EUR'
            )
        };

        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                CompanyCode__c = companyCodeList[0].Id,
                CompanyCode__r = companyCodeList[0],
                CurrencyIsoCode = 'MDL',
                Phone = '123123123'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                CompanyCode__c = companyCodeList[1].Id,
                CompanyCode__r = companyCodeList[1],
                CurrencyIsoCode = 'MDL',
                Phone = '456456456'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType)
            )    
        };

        accountList[0] = (Account)fflib_ApexMocksUtils.setReadOnlyFields(
            accountList[0],
            Account.class,
            new Map<SObjectField, Object> {Account.RecordTypeId => DO_Account.ACCOUNT_RECORDTYPEID_CEPCARDS}
        );

        accountList[1] = (Account)fflib_ApexMocksUtils.setReadOnlyFields(
            accountList[1],
            Account.class,
            new Map<SObjectField, Object> {Account.RecordTypeId => DO_Account.ACCOUNT_RECORDTYPEID_CEPCARDS}
        );
        
        accountList[2] = (Account)fflib_ApexMocksUtils.setReadOnlyFields(
            accountList[2],
            Account.class,
            new Map<SObjectField, Object> {Account.RecordTypeId => DO_Account.ACCOUNT_RECORDTYPEID_CEPCARDS}
        );

        mocks.startStubbing();
        mocks.when(companyCodeRepository.getCompanyCodeInfo((Set<Id>) fflib_match.anyObject())).thenReturn(companyCodeList);
        mocks.stopStubbing();

        TW_Account_FillComplementaryFields jobExecutionWorker = new TW_Account_FillComplementaryFields();
        jobExecutionWorker = new TW_Account_FillComplementaryFields(companyCodeRepository);
        
        jobExecutionWorker.execute(accountList, null);

        ((IREP_CompanyCode)mocks.verify(companyCodeRepository, 1)).getCompanyCodeInfo((Set<Id>) fflib_match.anyObject());
    }
}