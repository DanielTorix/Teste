/**
* @description   interface for OMV Portal Menu Item repository
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               24/11/2021         Created OMV Portal Menu Item Interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_OMVPortalMenuItem  extends FW_ISObjectRep{
    list<OMVPortalMenuItem__c> getOMVPortalMenubyLayout(Set<ID> omvPortalLayout);
}