/**
* @description   Interface for the Opportunity Contact Role Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               09/11/2021          Interface for the Opportunity Contact Role Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_OppContactRole extends FW_ISObjectRep{
    List<OpportunityContactRole> getOppContactRoleByOppId(Set<Id> oppIdsSet);
}