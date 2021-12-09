/**
* @description   UserRole Repository
* @testClass     REP_UserRoleTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               30/08/2021         Created UserRole Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_UserRole extends FW_SobjectRep implements IREP_UserRole{

    public List<UserRole> getUsersRolesByRoleName(Set<String> roleNameSet) {

        return [SELECT DeveloperName, Id FROM UserRole WHERE DeveloperName =: roleNameSet];
    }
}