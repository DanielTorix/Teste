/**
* @description   Privacy Policy Country 
* @testClass     REP_PrivacyPolicyCountry
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos               28/09/2021           Created Privacy Policy Country Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_PrivacyPolicyCountry extends FW_SobjectRep implements IREP_PrivacyPolicyCountry {
    public List<PrivacyPolicyCountry__mdt> getPrivacyPolicyCountries() {
        return [
            SELECT
                Id,
                MasterLabel,
                CountryIsoCode__c,
                TimeZone__c,
                Title__c,
                Body__c,
                Title_English__c,
                Body_English__c
            FROM
                PrivacyPolicyCountry__mdt
        ];
    }
}