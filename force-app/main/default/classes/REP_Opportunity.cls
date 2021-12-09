/**
* @description   Opportunity Repository
* @testClass     REP_OpportunityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               23/06/2021          Created Opportunity Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_Opportunity extends FW_SobjectRep implements IREP_Opportunity{
    public static final List<SObjectField> OPPORTUNITY_FIELDS = new SObjectField[] {
        Opportunity.Id,
        Opportunity.Name,
        Opportunity.CreatedDate,
        Opportunity.IsClosed,
        Opportunity.OwnerId,
        Opportunity.TotalPotentialFuelVolume__c
        
    };
    
    public List<Opportunity> getOpportunityByID(Set<ID> opportunityIdSet) {
        
		
        return [SELECT iD,OwnerId, Name, CreatedDate,IsClosed,TotalPotentialFuelVolume__c From Opportunity Where Id=:opportunityIdSet];
        

    }
    public List<Opportunity> getQuoteByOpportunityID(Set<ID> opportunityIdSet) {
        return [SELECT ID,CreatedDate,OwnerId, Name,(SELECT Id, ClosedDate__c,Status FROM Quotes ORDER BY ClosedDate__c DESC LIMIT 1) FROM Opportunity WHERE Id IN :opportunityIdSet ];
    }
    
}