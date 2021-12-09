/**
@author Guilherme Charro 
@date   06/09/2021 
@description Test class for TW_OMVEntityEmployee_UpdateUniqueID
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro              08/09/2021            Original Version                         100
Hugo Rodrigues                28/10/2021          Updated to work with RecordType of Cards   100
*/
@isTest
public with sharing class TW_Account_UpdateRelObjCountryTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void TW_Account_UpdateRelObjCountryTest() {
        List<CompanyCode__c> listCompanyCode = new List<CompanyCode__c>{
            new CompanyCode__c(
                Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType)
            ),
            new CompanyCode__c(
                Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType)
            )
        };

        List<Account> listAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                CompanyCode__c = listCompanyCode[1].Id,
                RecordTypeID= Do_Account.ACCOUNT_RECORDTYPEID_CEPCARDS
            )
        };
        List<Account> listAccounts2 = new List<Account>{
            new Account(
                Id = listAccounts[0].Id,
                CompanyCode__c = listCompanyCode[0].Id,
                RecordTypeID= Do_Account.ACCOUNT_RECORDTYPEID_CEPCARDS
            )
        };

        Map<Id,Account> oldAccountMap = new Map<Id,Account>();
        oldAccountMap.put(listAccounts[0].Id, listAccounts[0]);
        mocks.startStubbing();
        mocks.stopStubbing();

        TW_Account_UpdateRelatedObjectsCountry jobExecutionWorker = new TW_Account_UpdateRelatedObjectsCountry();
        jobExecutionWorker = new TW_Account_UpdateRelatedObjectsCountry();
        
        jobExecutionWorker.execute(listAccounts2, oldAccountMap);
    }
}