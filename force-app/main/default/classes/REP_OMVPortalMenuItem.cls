/**
* @description   OMV Portal Menu Item Repository
* @testClass     REP_OMVPortalMenuItemTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               24/11/2021         Created OMV Portal Menu Item Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_OMVPortalMenuItem  extends FW_SobjectRep implements IREP_OMVPortalMenuItem{
    public list<OMVPortalMenuItem__c> getOMVPortalMenubyLayout(Set<ID> omvPortalLayout) {
        return [SELECT Id, Name, PortalLayout__c,ItemType__c, OrderItem__c FROM OMVPortalMenuItem__c Where PortalLayout__c IN: omvPortalLayout Order By OrderItem__c];

    }
}