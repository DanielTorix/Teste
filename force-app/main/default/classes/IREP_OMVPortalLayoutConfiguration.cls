/**
* @description   interface for OMV Portal Layout Configuration repository
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               24/11/2021         Created OMV Portal Layout Configuration Interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_OMVPortalLayoutConfiguration  extends FW_ISObjectRep{
    OMVPortalLayoutConfiguration__c getOMVPortalLayoutbyCountry(String country);
}