/**
* @description   CompanyCode Repository
* @testClass     REP_CompanyCodeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               08/09/2021          CompanyCode Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_CompanyCode extends FW_SobjectRep implements IREP_CompanyCode{
    public List<CompanyCode__c> getCompanyCodeInfo(Set<Id> idsSet){
        return [SELECT Id, Country__c, Language__c, CurrencyIsoCode FROM CompanyCode__c WHERE Id IN :idsSet];
    }
}