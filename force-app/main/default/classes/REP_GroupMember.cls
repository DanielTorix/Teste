/**
* @description   Group Members Repository
* @testClass     REP_GroupMembersTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               31/08/2021         Created Group Members Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_GroupMember extends FW_SobjectRep implements IREP_GroupMember{

    public List<GroupMember> getUserByGroupID(Set<ID> groupID) {

        return [SELECT Id, GroupId, UserOrGroupId FROM GroupMember Where GroupId =: groupID];
    }
}