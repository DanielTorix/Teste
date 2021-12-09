/**
* @description   Interface for the UserRole Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                30/08/2021           Interface for the UserRole Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_UserRole {

    List<UserRole> getUsersRolesByRoleName(Set<String> roleNameSet);
}