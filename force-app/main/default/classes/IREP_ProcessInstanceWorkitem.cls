/**
* @description   Interface for the ProcessInstanceWorkitem Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                30/08/2021           Interface for the ProcessInstanceWorkitem Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_ProcessInstanceWorkitem extends FW_ISObjectRep{
    
    List<ProcessInstanceWorkitem> processInstanceWorkitemByObjectID(Set<ID> processInstanceWorkitemIDSet);
}