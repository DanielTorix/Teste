/**
* @description   Interface for the CompanyCode Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                08/09/2021          Interface for the CompanyCode Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_CompanyCode {
    List<CompanyCode__c> getCompanyCodeInfo(Set<Id> idsSet);
}