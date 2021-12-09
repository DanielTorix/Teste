/**
@author Hugo Rodrigues  
@date   04/11/2021 
@description Test class for REP_Lead
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               04/11/2021           Original Version                         100
*/
@isTest
public class REP_LeadTest {
    @isTest
    static void LeadTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Lead> leadList = FW_TestDataFactory.createLead(1, false);
            leadList[0].OwnerId = runningUser.Id;
            insert leadList;
            
            
            
            test.startTest();
                Rep_Lead leadRepository = new Rep_Lead();
                List<Lead> leadReturned = leadRepository.getLeadNotConvertedByUserID(new Set<ID> {leadList[0].OwnerId});
            test.stopTest();
            System.assertEquals(1, leadReturned.size());
        }
    }
}