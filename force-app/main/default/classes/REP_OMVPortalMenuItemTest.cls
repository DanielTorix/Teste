/**
@author Hugo Rodrigues  
@date   24/11/2021 
@description Test class for REP_OMVPortalMenuItem
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               24/11/2021           Original Version                         100
*/
@isTest
public class REP_OMVPortalMenuItemTest {
    @isTest
    static void REP_OMVPortalMenuItemTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<OMVPortalLayoutConfiguration__c> listOMVPortalLayout =new  List<OMVPortalLayoutConfiguration__c>{
                new OMVPortalLayoutConfiguration__c(
                    CustomerCountryISOCode__c='TE'
                ) };
                insert listOMVPortalLayout;
            List<OMVPortalMenuItem__c> listOMVPortalMenu =new  List<OMVPortalMenuItem__c>{
                new OMVPortalMenuItem__c(
                    PortalLayout__c=listOMVPortalLayout[0].id
                ) };
                insert listOMVPortalMenu;
            test.startTest();
            REP_OMVPortalMenuItem omvPortalMenuRepository = new REP_OMVPortalMenuItem();
            List<OMVPortalMenuItem__c> omvPortalMenuList = omvPortalMenuRepository.getOMVPortalMenubyLayout(new Set<Id> {listOMVPortalLayout[0].id});
            test.stopTest();
            System.assertEquals(1, omvPortalMenuList.size());
           
        }
    }
}