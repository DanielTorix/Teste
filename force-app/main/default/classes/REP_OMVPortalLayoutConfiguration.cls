/**
* @description   OMV Portal Layout Configuration Repository
* @testClass     REP_OMVPortalLayoutConfigurationTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               24/11/2021         Created OMV Portal Layout Configuration Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_OMVPortalLayoutConfiguration extends FW_SobjectRep implements IREP_OMVPortalLayoutConfiguration{
    public OMVPortalLayoutConfiguration__c getOMVPortalLayoutbyCountry(String country) {
        return [SELECT Id, OwnerId, Name, CurrencyIsoCode, CustomerCountryISOCode__c, MenuEnergyLineColor__c, 
        HeaderLogo__c, FooterLogo__c, HeaderText__c, HeroText__c,(SELECT Id,Name, PortalLayout__c,ItemType__c, OrderItem__c FROM OMVPortalMenuItems__r ORDER BY OrderItem__c) FROM OMVPortalLayoutConfiguration__c Where CustomerCountryISOCode__c =: country];

    }
}