/**
* @description   Interface for the User Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                30/08/2021           Interface for the User Repository
* João Alencar                  22/09/2021           Added getUserAndAccountCountryAssociated Method
* António Santos                03/11/2021           Replaced method to obtain the portal user company code.
* Guilherme Charro              03/12/2021           Added getPortalUsers
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_User extends FW_ISObjectRep{

    List<User> getUsersByRoleID(Set<ID> roleIdSet);
    List<User> getUsersByID(Set<ID> userIdSet);
    List<User> getPortalUserAndCompanyCode( Set<Id> userIds );
    List<User> getPortalUsers(Set<Id> contactIdsSet);
}