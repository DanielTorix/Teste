@isTest
public class REP_OrganizationTest {
    @isTest
    static void organizationTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        
        System.runAs(runningUser) {
            Test.startTest();

            REP_Organization organizationRepository = new REP_Organization();

            Organization org = organizationRepository.getOrganization();
            List<SObjectField> orgFields = REP_Organization.ORGANIZATION_FIELDS;

            System.assert(org != null);
            System.assert(orgFields != null && !orgFields.isEmpty());

            Test.stopTest();
        }
    }
}