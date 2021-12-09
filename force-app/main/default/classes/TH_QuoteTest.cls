/**
@author Hugo Rodrigues
@date   06/07/2021
@description Test class for TH_Quote
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                Date               Description                                    Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues           06/07/2021        Original Version                                      100
Hugo Rodrigues           23/09/2021    changed status to other field because validation rule    100
*/
@isTest
public class TH_QuoteTest {
    @isTest
    static void TH_QuoteTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        User testUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Quote> quoteList = FW_TestDataFactory.createQuote(1, true);
            
            User adminUser = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null)[0];
            test.startTest();
            System.runAs(adminUser){
                quoteList[0].NonFuelCompetitivePackage__c = DO_Quote.QUOTE_NON_FUEL_PACKAGE_NF1;
                update quoteList;
            }
            test.stopTest();
            System.assertNotEquals(null, quoteList[0].Id);
        }
    }
}