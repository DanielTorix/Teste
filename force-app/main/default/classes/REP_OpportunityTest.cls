@isTest
public class REP_OpportunityTest {
    @isTest
    static void OpportunityTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Opportunity> listOpportunities = FW_TestDataFactory.createOpportunity(1, true);
            
            
            
            test.startTest();
                Rep_Opportunity opportunityRepository = new REP_Opportunity();
                List<Opportunity> opportunitiesReturned = opportunityRepository.getOpportunityByID(new Set<ID> {listOpportunities[0].Id});
                List<Opportunity> opportunitiesReturnedSecond = opportunityRepository.getQuoteByOpportunityID(new Set<ID> {listOpportunities[0].Id});
            test.stopTest();
            System.assertEquals(1, opportunitiesReturned.size());
        }
    }
}