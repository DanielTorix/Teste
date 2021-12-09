/**
* @description   Account Repository
* @testClass     REP_CaseTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               25/08/2021          Account Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_Account extends FW_SobjectRep implements IREP_Account{
    public static final List<SObjectField> ACCOUNT_FIELDS = new SObjectField[] {
        Account.Id,
        Account.OwnerId
    };

    public List<Account> getAccountsById(Set<Id> accountsIds){
        return [SELECT Id, AccountCategory__c, Type, Company__c, 
        Website, OwnerId, CurrencyIsoCode, Name, BillingAddress, 
        BillingCity, BillingCountry, BillingGeocodeAccuracy, BillingLatitude, 
        BillingLongitude, BillingPostalCode, BillingState, BillingStreet, 
        ShippingAddress, ShippingCity, ShippingCountry, ShippingGeocodeAccuracy, 
        ShippingLatitude, ShippingLongitude, ShippingPostalCode, ShippingState, 
        ShippingStreet
        FROM Account Where Id IN :accountsIds];
    }

    public List<Account> getAccountCompanyCode(Set<Id> accountsIds){ 
        return [SELECT Id, CompanyCode__r.Country__c
        FROM Account WHERE Id IN :accountsIds];
    }

    public Map<Id,Account> getAccountFromInvoice(Set<Id> accountIdSet){
        return (new Map<ID, Account>([SELECT Id, BillingEmail__c FROM Account WHERE Id IN:accountIdSet]));
    }
}