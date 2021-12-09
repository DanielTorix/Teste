/**
@description    worker class to update the related records Country field for sharing rules
@testClass      TW_Account_UpdateRelatedObjectsCountryTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                06/09/2021          Created the class
* Hugo Rodrigues                  28/10/2021          Updated to work with RecordType of Cards                 
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Account_UpdateRelatedObjectsCountry {
    public void execute(List<Account> accountList, Map<Id,Account> oldAccountMap) {
        Set<Id> accountIds = new Set<Id>();
        ID recordTypeAccountID = Do_Account.ACCOUNT_RECORDTYPEID_CEPCARDS;
        for (Account acc : accountList) {
            if (!String.isBlank(acc.CompanyCode__c) && acc.CompanyCode__c != oldAccountMap.get(acc.Id).CompanyCode__c && acc.RecordTypeID==recordTypeAccountID) {
                accountIds.add(acc.Id);
            }
        }

        if (!accountIds.isEmpty()) {
            Async_UpdateAccCompanyCode updateRelatedRecordsBatch = new Async_UpdateAccCompanyCode();
            updateRelatedRecordsBatch.accountIdsSet = accountIds;
            Database.executeBatch(updateRelatedRecordsBatch);
        }        
    }
}