/**
* @description   AccountCountryRelatedSetting Repository
* @testClass     REP_AccountCountryRelatedSettingTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               02/09/2021          AccountCountryRelatedSetting Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_AccountCountryRelatedSetting extends FW_SobjectRep implements IREP_AccountCountryRelatedSetting{
    public static final List<SObjectField> ACCOUNTCOUNTRYRELATEDSETTING_FIELDS = new SObjectField[] {
        AccountCountryRelatedSetting__mdt.MasterLabel,
        AccountCountryRelatedSetting__mdt.AccountLookupAPIName__c,
        AccountCountryRelatedSetting__mdt.CountryAPIName__c,
        AccountCountryRelatedSetting__mdt.ObjectFilter__c
    };

    public List<AccountCountryRelatedSetting__mdt> getAllAccountCountryRelated(){
        return [SELECT MasterLabel,AccountLookupAPIName__c,CountryAPIName__c,ObjectFilter__c,AccountRelationshipName__c FROM AccountCountryRelatedSetting__mdt];
    }
}