@isTest
public class REP_GroupTest {
    @isTest
    static void GroupTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Group> listGroup = FW_TestDataFactory.createGroup(2, true);
            system.debug(listGroup);
            
            
            test.startTest();
            REP_Group groupRepository = new REP_Group();
                
            List<Group> groupList = groupRepository.getGroupByName(new Set<String> {listGroup[0].DeveloperName,listGroup[1].DeveloperName});
            test.stopTest();
            System.assertEquals(2, groupList.size());
           
        }
    }
}