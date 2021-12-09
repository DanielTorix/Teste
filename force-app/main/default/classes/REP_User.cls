/**
* @description   User Repository
* @testClass     REP_UserTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               30/08/2021           Created User Repository
* João Alencar                 22/09/2021           Added getUserAndAccountCountryAssociated Method
* António Santos               03/11/2021           Replaced method to obtain portal user company code.
* António Santos               30/11/2021           Updated the method 'getPortalUserAndCompanyCode'.
* Guilherme Charro             03/12/2021           Added getPortalUsers
* ------------------------------------------------------------------------------------ 
*/
public class REP_User extends FW_SobjectRep implements IREP_User{
    
    public List<User> getUsersByRoleID(Set<ID> roleIdSet) {

        return [SELECT ID,UserRoleId FROM User WHERE UserRoleId =: roleIdSet];
    }

    public List<User> getUsersByID(Set<ID> userIdSet) {

        return [SELECT ID FROM User WHERE Id =: userIdSet];
    }

    public List<User> getPortalUserAndCompanyCode(Set<Id> userIdSet) {
        return [
            SELECT
                Id,
                FirstName,
                LastName,
                Name,
                Username,
                Email,
                Contact.AccountId,
                Contact.Account.CompanyCodeCountry__c,
                Contact.Account.Name
            FROM
                User
            WHERE
                Id IN :userIdSet
        ];
    }

    public List<User> getPortalUsers(Set<Id> contactIdsSet){
        return [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ContactId IN :contactIdsSet AND IsActive = true AND IsPortalEnabled = true];
    }
}