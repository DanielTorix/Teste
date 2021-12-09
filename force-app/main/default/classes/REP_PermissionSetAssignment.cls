/**
* @description   Interface for the PermissionSetAssignment Repository
* @testClass     REP_PermissionSetAssignmentTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Alencar                    14/09/2021          CreatedClass
* ------------------------------------------------------------------------------------ 
*/
public inherited sharing class REP_PermissionSetAssignment extends FW_SobjectRep implements IREP_PermissionSetAssignment {
    
	public List<PermissionSetAssignment> getPermissionSetGroupsAssignedToUserByUserId(Set<Id> userIds, List<String> PermissionSetLabels){
        return [SELECT Id, PermissionSetGroupId, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN: userIds AND( PermissionSetGroupId != null OR PermissionSet.Label IN:PermissionSetLabels) ];
    }
}