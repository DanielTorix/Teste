/**
* @description   Interface for the Case Repository
* @testClass     REP_CaseTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                26/05/2021          Created Case Repository
* João Alencar                    14/09/2021          added method getCaseWithChildCasesById as part of US36697
* ------------------------------------------------------------------------------------ 
*/
//adicionar inherited sharing
public class REP_Case extends FW_SobjectRep implements IREP_Case{  
    
	/*Method to get the child cases based on a parent Case*/    
    public List<Case> getChildCases(Set<Id> parentCase){
        return [SELECT Id, OwnerId, ParentId, Subject, CaseNumber, 
                Parent.Owner.Name, Parent.CaseNumber, Parent.OwnerId, 
                ClosureReason__c, Parent.ClosureReason__c, RecordTypeId, 
                RecordType.DeveloperName, Source__c, CategoryT1__c,
                CategoryT2__c, CategoryT3__c 
                FROM Case 
                WHERE ParentId IN :parentCase 
                AND IsClosed = false];
    }

    /*Method to get the info from the parent case*/
    public List<Case> getParentCase(Set<Id> parentCase){
        return [SELECT Id, OpenChildCases__c FROM Case WHERE Id IN :parentCase];
    }

    /*Method to get the info from the parent case*/
    public List<Case> getCasesById(Set<Id> casesIds){
        return [SELECT Id, IsClosed, OwnerId, CaseNumber, Status, Source__c, AccountId FROM Case WHERE Id IN :casesIds];
    }
    public List<Case> getCaseWithChildCasesById(Set<Id> caseIds){
        return [SELECT Id, ParentId, (SELECT Id, ParentId FROM Cases) FROM Case WHERE Id IN: caseIds];
    }
}