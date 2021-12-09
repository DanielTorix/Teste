/**
* @description   Service class to define the country field from accounts
* @testClass     SL_CountryDefinitionFromParentTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               02/09/2021           Created service class
* ------------------------------------------------------------------------------------ 
*/
public with sharing class SL_CountryDefinitionFromParent implements ISL_CountryDefinitionFromParent{
    public void setCountryField(List<SObject> sobjectList, String countryAPIname, String accountLookupAPIname) {
        IREP_Account accountRepository;
        accountRepository = new REP_Account();

        Set<Id> accountIdsSet = new Set<Id>();

        for (SObject objectProvided : sobjectList) {
            if (String.isBlank((String)objectProvided.get(accountLookupAPIname))) {
                objectProvided.put(countryAPIname, null);
            }else{
                accountIdsSet.add((Id)objectProvided.get(accountLookupAPIname));
            }            
        }
        
        Map<Id,Account> accountsMap = new Map<Id,Account>(accountRepository.getAccountCompanyCode(accountIdsSet));

        for (SObject objectProvided : sobjectList) {
            if (accountsMap.containsKey((Id)objectProvided.get(accountLookupAPIname))) {
                objectProvided.put(countryAPIname, (String)accountsMap.get((Id)objectProvided.get(accountLookupAPIname)).CompanyCode__r.Country__c);
            }
        }
    }
}