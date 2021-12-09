/**
* @description   Group Repository
* @testClass     REP_GroupTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               31/08/2021         Created Group Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_Group extends FW_SobjectRep implements IREP_Group{
   
    public List<Group> getGroupByName(Set<String> groupName) {

        return [SELECT Id, DeveloperName FROM Group WHERE DeveloperName =: groupName];
    }
}