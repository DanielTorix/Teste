/**
* @description   Interface for the PermissionSetGroupComponent Repository
* @testClass     REP_PermissionSetGroupComponentTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Alencar                    14/09/2021          CreatedClass
* ------------------------------------------------------------------------------------ 
*/
public inherited sharing class REP_PermissionSetGroupComponent extends FW_SobjectRep implements IREP_PermissionSetGroupComponent {
    
	public List<PermissionSetGroupComponent> getPermissionSetsByGroupIdsAndLabels(Set<Id> PermissionSetGroupIds, List<String> PermissionSetLabels){
        return [SELECT Id, PermissionSetId, PermissionSet.Label, PermissionSetGroupId, PermissionSetGroup.MasterLabel FROM PermissionSetGroupComponent WHERE PermissionSetGroupId IN:PermissionSetGroupIds AND PermissionSet.Label IN:PermissionSetLabels ];
    }
}