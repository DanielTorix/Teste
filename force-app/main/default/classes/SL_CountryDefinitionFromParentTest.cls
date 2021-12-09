@isTest
public class SL_CountryDefinitionFromParentTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    public static void SL_CountryDefinitionFromParentTest() {
        IREP_Account accountRepository = (REP_Account)mocks.mock(REP_Account.class);
        IREP_Opportunity opportunityRepository = (REP_Opportunity)mocks.mock(REP_Opportunity.class);

        List<CompanyCode__c> companyCodeList = new List<CompanyCode__c>();
        companyCodeList.add(
            new CompanyCode__c(
                Country__c = 'HU',
                Language__c = 'de'
            )  
        );
        insert companyCodeList;

        List<Account> accountList = FW_TestDataFactory.createAccount(1, false);
        accountList.get(0).CompanyCode__c = companyCodeList.get(0).Id;
            
        insert accountList;

        List<Opportunity> oppList = FW_TestDataFactory.createOpportunity(2, true);
        oppList.get(0).AccountId = accountList.get(0).Id;

        SL_CountryDefinitionFromParent jobExecutionWorker = new SL_CountryDefinitionFromParent();
        Test.startTest();
        jobExecutionWorker.setCountryField(oppList, 'CompanyCodeCountry__c', 'AccountId');
        Test.stopTest();
    }
}