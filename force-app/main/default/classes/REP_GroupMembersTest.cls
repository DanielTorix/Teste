@isTest
public class REP_GroupMembersTest {
    @isTest
    static void GroupMembersTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Group> listGroup = FW_TestDataFactory.createGroup(1, true);
            List<GroupMember> listGroupMember = FW_TestDataFactory.createGroupMember(1, true,listGroup[0].id ,runningUser.id);
            
            
            
            test.startTest();
            REP_GroupMember groupMemberRepository = new REP_GroupMember();
            List<GroupMember> groupMemberList = groupMemberRepository.getUserByGroupID(new Set<ID> {listGroup[0].Id});
            test.stopTest();
            System.assertEquals(1, groupMemberList.size());
           
        }
    }
}