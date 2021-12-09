/**
* @description   Interface for the PermissionSetAssignment Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Alencar                    14/09/2021          Created Class
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_PermissionSetAssignment extends FW_ISObjectRep{
    List<PermissionSetAssignment> getPermissionSetGroupsAssignedToUserByUserId(Set<Id> userIds, List<String> PermissionSetLabels);    
}