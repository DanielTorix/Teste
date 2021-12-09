/**
* @description   Interface for the Group Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                31/08/2021           Interface for the Group Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Group {

    List<Group> getGroupByName(Set<String> groupName);   
}