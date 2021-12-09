/**
* @description   CEPFPSEmailBranding Repository
* @testClass     REP_CEPFPSEmailBrandingTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               15/11/2021         Created CEPFPSEmailBranding Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_CEPFPSEmailBranding extends FW_SobjectRep implements IREP_CEPFPSEmailBranding{
    public CEPFPSEmailBranding__mdt getCEPFPSEmailBranding(String CustomerCountry){
        return [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CountryIsoCode__c, LogoHeight__c, LogoWidth__c,
        HeaderLogoImage__c, BrandingPrimaryColor__c, EnergyFlashColor__c, FontFamily__c, ButtonsColor__c, ButtonsTextColor__c, FooterURL__c, CopyrightText__c,
        TelephoneContact__c, ImprintText__c, ImprintURL__c, FooterLogoImage__c, FontSize__c FROM CEPFPSEmailBranding__mdt Where CountryIsoCode__c=:CustomerCountry LIMIT 1];
    }
}