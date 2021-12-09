/**
@description    worker class to automatically fill needed fields
@testClass      TW_Account_FillComplementaryFieldsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                08/09/2021          Created the class
* David Favinha                   24/11/2021          Adding logic for CTI UserStory
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Account_FillComplementaryFields {
    private IREP_CompanyCode companyCodeRepository;

    public TW_Account_FillComplementaryFields(){
        this.companyCodeRepository = new REP_CompanyCode();
    }
    
    @TestVisible
    private TW_Account_FillComplementaryFields(IREP_CompanyCode companyCodeRepository){
        this.companyCodeRepository = companyCodeRepository;
    }

    public void execute( List<Account> accountList, Map<Id,Account> oldAccountMap ) {
        Id accountCardsId = DO_Account.ACCOUNT_RECORDTYPEID_CEPCARDS;
        Set<Id> companyCodeIdsSet = new Set<Id>();
        List<Account> newAccountList = new List<Account>();
        for (Account accountInserted : accountList) {
            if (String.isBlank(accountInserted.CompanyCode__c) && accountInserted.RecordTypeId == accountCardsId) {
                accountInserted.CompanyCodeCountry__c = null;
            }else if( accountInserted.RecordTypeId == accountCardsId && !String.isBlank(accountInserted.CompanyCode__c) && accountInserted.CompanyCode__c!=null ){
                companyCodeIdsSet.add(accountInserted.CompanyCode__c);
                newAccountList.add( accountInserted );
            }
            
            if( oldAccountMap == null || oldAccountMap.get(accountInserted.Id).Phone != accountInserted.Phone ){
                accountInserted.CTITechnicalPhone__c = accountInserted.Phone?.right(7);
            }
        }

        Map<Id,CompanyCode__c> companyCodeMap = new Map<Id,CompanyCode__c>();

        if (!companyCodeIdsSet.isEmpty()) {
            companyCodeMap = new Map<Id,CompanyCode__c>(companyCodeRepository.getCompanyCodeInfo(companyCodeIdsSet));
        }

        for ( Account accountInserted : newAccountList ) {
            if ( companyCodeMap.containsKey(accountInserted.CompanyCode__c)
                && ( oldAccountMap == null ||(oldAccountMap !=null && accountInserted.CompanyCode__c != oldAccountMap.get(accountInserted.Id).CompanyCode__c))){
                accountInserted.CompanyCodeCountry__c = companyCodeMap.get(accountInserted.CompanyCode__c).Country__c;

                if (accountInserted.CurrencyIsoCode != companyCodeMap.get(accountInserted.CompanyCode__c).CurrencyIsoCode) {
                    accountInserted.CurrencyIsoCode = companyCodeMap.get(accountInserted.CompanyCode__c).CurrencyIsoCode;
                }

                if (String.isBlank(accountInserted.Language__c)) {
                    accountInserted.Language__c = companyCodeMap.get(accountInserted.CompanyCode__c).Language__c;
                } 
            }          
        }  
    }
}