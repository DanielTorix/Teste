/**
* @description   Interface for the PermissionSetGroupComponent Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Alencar                    14/09/2021          Created Class
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_PermissionSetGroupComponent extends FW_ISObjectRep{
    List<PermissionSetGroupComponent> getPermissionSetsByGroupIdsAndLabels(Set<Id> PermissionSetGroupIds, List<String> PermissionSetLabels);    
}