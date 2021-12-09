/**
* @description   Service class check if the given user is assigned to the permission set asked
* @testClass     SL_PermissionSetVerificationTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Alencar                    14/09/2021          Created Class
* ------------------------------------------------------------------------------------ 
*/
public with sharing class SL_PermissionSetVerification {

    @invocableMethod(label='Verify if user has Permission set')
    public static List<List<String>> VerifyPermissionSet(List<wrapperVerificationInputs> verificationInputs){
        IREP_PermissionSetAssignment permissionSetAssignmentRepository = new REP_PermissionSetAssignment();
        IREP_PermissionSetGroupComponent permissionSetGroupComponentRepository = new REP_PermissionSetGroupComponent();
        List<String> permissionsAssignedToUser = new List<String>();
        Set<Id> PermissionSetGroupIdSet = new Set<Id>();
        List<List<String>> returnPermissions;
        
        for(PermissionSetAssignment PermissionSetAssignedToUser : permissionSetAssignmentRepository.getPermissionSetGroupsAssignedToUserByUserId(new Set<Id>{verificationInputs.get(0).CurrentUserId}, verificationInputs.get(0).PermissionSetsLabels ) ){
            //if the permissionSetGroupId is null it means that the query found a permission set assigned to the user with one of the labels provided
            if( PermissionSetAssignedToUser.PermissionSetGroupId == null ){
                permissionsAssignedToUser.add(PermissionSetAssignedToUser.PermissionSetId);
            }else{
                //add to the list all the permission set groups the user is assigned to
                PermissionSetGroupIdSet.add( PermissionSetAssignedToUser.PermissionSetGroupId );
            }
            
        }
        for (PermissionSetGroupComponent permissionSetsVerified : permissionSetGroupComponentRepository.getPermissionSetsByGroupIdsAndLabels(PermissionSetGroupIdSet, verificationInputs.get(0).PermissionSetsLabels) ) {
            permissionsAssignedToUser.add(permissionSetsVerified.PermissionSetId);
        }
        if( !permissionsAssignedToUser.isEmpty() ){
            returnPermissions = new List<List<String>>();
            returnPermissions.add(permissionsAssignedToUser);
        }
        
        return returnPermissions;
    }

    public class wrapperVerificationInputs{
        @invocableVariable
        public List<String> PermissionSetsLabels = new List<String>();
        @invocableVariable
        public String currentUserId;
    }
}