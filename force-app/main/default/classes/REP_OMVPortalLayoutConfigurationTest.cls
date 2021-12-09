/**
@author Hugo Rodrigues  
@date   24/11/2021 
@description Test class for REP_OMVPortalLayoutConfiguration
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               24/11/2021           Original Version                         100
*/
@isTest
public class REP_OMVPortalLayoutConfigurationTest {
    @isTest
    static void OMVPortalLayoutConfigurationTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<OMVPortalLayoutConfiguration__c> listOMVPortalLayout =new  List<OMVPortalLayoutConfiguration__c>{
                new OMVPortalLayoutConfiguration__c(
                    CustomerCountryISOCode__c='TE'
                ) };
                insert listOMVPortalLayout;
            test.startTest();
            REP_OMVPortalLayoutConfiguration omvPortalLayoutRepository = new REP_OMVPortalLayoutConfiguration();
            List<OMVPortalLayoutConfiguration__c> omvPortalLayoutList = omvPortalLayoutRepository.getOMVPortalLayoutbyCountry('TE');
            test.stopTest();
            System.assertEquals(1, omvPortalLayoutList.size());
           
        }
    }
}