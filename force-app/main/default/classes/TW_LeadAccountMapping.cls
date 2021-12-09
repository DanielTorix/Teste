/**
* @description   worker class to map fields from Lead to Account
* @testClass     TW_LeadAccountMappingTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               25/08/2021          Created Lead Worker
* Hugo Rodrigues               28/08/2021          Adjustment on class for best pratices
* Hugo Rodrigues               13/10/2021          updated for optimization
* ------------------------------------------------------------------------------------ 
*/
public without sharing class TW_LeadAccountMapping {

    //interface definition
    private IREP_Account accountRepository;
    
    //constructor
     public TW_LeadAccountMapping(){
         this.accountRepository = new REP_Account();
      
    }
    
    //to use on test
    @TestVisible
    private TW_LeadAccountMapping(IREP_Account accountRepository){
        this.accountRepository = accountRepository;
        
    }
    
    //method execute
    public void execute(List<Lead> leadList, Map<Id,Lead> leadOldMap) {

        Set<Id> accountIDSet = new Set<Id>();
        List <Account> accountListToUpdate = new List<Account>();
        for(Lead leadRecord : leadList){
            if(leadOldMap.get(leadRecord.Id).IsConverted ==false && leadRecord.IsConverted == true){
                accountIDSet.add(leadRecord.ConvertedAccountId);
            }
        }
        if(!accountIDSet.isEmpty()){
            Map<ID,Account> accounttMap=  New Map<ID,Account>( accountRepository.getAccountsById(accountIDSet));
        
            if(!accounttMap.isEmpty()){
                for(Lead leadRecord : leadList){
                    accounttMap.get(leadRecord.ConvertedAccountId).Website = leadRecord.Website;
                    accounttMap.get(leadRecord.ConvertedAccountId).BillingCity = leadRecord.City;
                    accounttMap.get(leadRecord.ConvertedAccountId).BillingCountry = leadRecord.Country;
                    accounttMap.get(leadRecord.ConvertedAccountId).BillingPostalCode = leadRecord.PostalCode;
                    accounttMap.get(leadRecord.ConvertedAccountId).BillingState = leadRecord.State;
                    accounttMap.get(leadRecord.ConvertedAccountId).BillingStreet = leadRecord.Street;
                    accounttMap.get(leadRecord.ConvertedAccountId).CurrencyIsoCode = leadRecord.CurrencyIsoCode;
                    accounttMap.get(leadRecord.ConvertedAccountId).OwnerId = leadRecord.OwnerId;
                    accounttMap.get(leadRecord.ConvertedAccountId).Type = DO_Account.ACCOUNT_TYPE_PROSPECT;
                
                    if(!accountListToUpdate.contains(accounttMap.get(leadRecord.ConvertedAccountId))){
                        accountListToUpdate.add(accounttMap.get(leadRecord.ConvertedAccountId));
                    }
                }
            }
   
        }
        if(!accountListToUpdate.isEmpty()){
            accountRepository.updateSObjects(accountListToUpdate);
        }
    }
}