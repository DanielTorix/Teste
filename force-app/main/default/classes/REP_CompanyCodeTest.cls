@isTest
public with sharing class REP_CompanyCodeTest {
    @isTest
    static void REP_CompanyCodeTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){
            List<CompanyCode__c> listCompanyCode = FW_TestDataFactory.createCompanyCode(1, true);
            Set<Id> idCompanyCodes = new Set<Id>();
            idCompanyCodes.add(listCompanyCode[0].Id);
            
            test.startTest();
                REP_CompanyCode companyCodeRepository = new REP_CompanyCode();
                List<CompanyCode__c> companyCodeReturned = companyCodeRepository.getCompanyCodeInfo(idCompanyCodes);
            test.stopTest();
            System.assertEquals(1, companyCodeReturned.size());
        }
    }
}