/**
* @description   Interface for the Case Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                26/05/2021          Interface for the Case Repository
* João Alencar                    14/09/2021          added method getCaseWithChildCasesById as part of US36697
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Case extends FW_ISObjectRep{
    List<Case> getChildCases(Set<Id> parentCase);
    List<Case> getParentCase(Set<Id> parentCase);
    List<Case> getCasesById(Set<Id> casesIds);
    List<Case> getCaseWithChildCasesById(Set<Id> casesIds);
    
}