@isTest
public with sharing class REP_AccountCountryRelatedSettingTest {
    @isTest
    static void REP_AccountCountryRelatedSettingTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            test.startTest();
                REP_AccountCountryRelatedSetting accountCountryRepository = new REP_AccountCountryRelatedSetting();
                List<AccountCountryRelatedSetting__mdt> accountCountriesReturned = accountCountryRepository.getAllAccountCountryRelated();
            test.stopTest();
            System.assertNotEquals(null, accountCountriesReturned);
        }
    }
}