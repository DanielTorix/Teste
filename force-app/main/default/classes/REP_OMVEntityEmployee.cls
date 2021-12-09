/**
* @description   OMV Entity Employee Repository
* @testClass     REP_OMVEntityEmployeeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               20/10/2021         Created OMV Entity Employee Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_OMVEntityEmployee extends FW_SobjectRep implements IREP_OMVEntityEmployee{

    public List<OMVEntityEmployee__c> getCompanyCodeByUserID(Set<ID> userID) {

        return [SELECT Id, EmployeeUser__c, UniqueKey__c,OMVEntity__c, OMVEntity__r.Name FROM OMVEntityEmployee__c Where EmployeeUser__c IN: userID];
    }
}