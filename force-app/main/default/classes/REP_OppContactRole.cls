/**
* @description   Opportunity Contact Role Repository
* @testClass     REP_OppContactRoleTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               09/11/2021          Created Opportunity Contact Role Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_OppContactRole extends FW_SobjectRep implements IREP_OppContactRole{
    public List<OpportunityContactRole> getOppContactRoleByOppId(Set<Id> oppIdsSet){
        return [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId IN :oppIdsSet];
    }
}