/**
* @description   ProcessInstanceWorkitem Repository
* @testClass     REP_ProcessInstanceWorkitemTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               30/08/2021         Created ProcessInstanceWorkitem Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_ProcessInstanceWorkitem extends FW_SobjectRep implements IREP_ProcessInstanceWorkitem{

    public List<ProcessInstanceWorkitem> processInstanceWorkitemByObjectID(Set<ID> processInstanceWorkitemIDSet) {

        return [SELECT Id,actorID FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: processInstanceWorkitemIDSet];
    }
}