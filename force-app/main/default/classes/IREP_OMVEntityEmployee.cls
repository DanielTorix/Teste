/**
* @description   interface for OMV Entity Employee repository
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               20/10/2021         Created OMV Entity Employee Interface Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_OMVEntityEmployee extends FW_ISObjectRep{
    List<OMVEntityEmployee__c> getCompanyCodeByUserID(Set<ID> userID);
}