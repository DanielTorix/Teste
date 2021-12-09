/**
* @description   Interface for the Opportunity Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                23/06/2021          Interface for the Opportunity Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Opportunity extends FW_ISObjectRep{
    List<Opportunity> getQuoteByOpportunityID(Set<ID> opportunityIdSet);
    List<Opportunity> getOpportunityByID(Set<ID> opportunityIdSet);
}