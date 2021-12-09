/**
* @description   Organization Repository
* @testClass     REP_Organization
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos                  09/08//2021         Created the Organization Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_Organization extends FW_SobjectRep implements IREP_Organization {
    public static final List<SObjectField> ORGANIZATION_FIELDS = new SObjectField[] {
        Organization.Id
    };
    
    public Organization getOrganization() {
        return [SELECT Id FROM Organization LIMIT 1];
    }
}