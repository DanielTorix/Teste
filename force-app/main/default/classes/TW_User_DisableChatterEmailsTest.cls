/**
@author João Lopes
@date   01/07/2021
@description Test class for TW_QuoteUpdateTotalFuelField
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                Date                Description                                    Coverage
----------------------------------------------------------------------------------------------------
João Lopes               01/07/2021          Original version                                   100
Hugo Rodrigues           02/11/2021          updated to meet the US41124 requirements           100
*/
@isTest
public with sharing class TW_User_DisableChatterEmailsTest {
    
    @isTest
    private static void TW_Case_FillSourceTest() {

       	

        List<User> testingUserList = new List<User>();
        testingUserList.add(
            new User(
                ID = fflib_IDGenerator.generate(User.sObjectType),
                UserPreferencesDisableAllFeedsEmail = true,
                EmailPreferencesAutoBcc = true

            )
        );
        Test.startTest();

        TW_User_DisableChatterEmails jobExecutionWorker = new TW_User_DisableChatterEmails();
        
        jobExecutionWorker.execute(testingUserList);
        Test.stopTest();
    }
}