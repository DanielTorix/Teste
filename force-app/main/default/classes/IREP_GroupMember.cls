/**
* @description   Interface for the Group  Members Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                31/08/2021           Interface for the Group Members Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_GroupMember {

    List<GroupMember> getUserByGroupID(Set<ID> groupID) ;
}