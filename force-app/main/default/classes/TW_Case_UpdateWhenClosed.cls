/**
@description    worker class to update fields when the Case is Closed
@testClass      TW_Case_UpdateWhenClosedTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Hugo Rodrigues               14/09/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public  class TW_Case_UpdateWhenClosed {
    private IREP_Case caseRepository;
    
    
    public TW_Case_UpdateWhenClosed(){
        this.caseRepository = new REP_Case();
        
    }
    
    @TestVisible
    private TW_Case_UpdateWhenClosed(IREP_Case caseRepository){
        this.caseRepository = caseRepository;
        
    }
    public void execute(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap) {
        ID caseRecordType = Do_case.CASE_RECORDTYPEID_CASE;
        Set<ID> caseIDSet = new Set<ID>();
        for(Case caseRecord : newCaseMap.values() ){
            if(caseRecord.Status == Do_case.CASE_STATUS_CLOSED && caseRecord.Status!=oldCaseMap.get(caseRecord.Id).Status && caseRecord.RecordTypeID==caseRecordType){
                caseIDSet.add(caseRecord.Id);
                caseRecord.ClosureReason__c = DO_Case.CASE_CLOSURE_REASON_COMPLETED_NORMALLY;
            }
            
        }
        if(!caseIDSet.isEmpty()){
            List<Case> casesWithChildren = caseRepository.getCaseWithChildCasesById(caseIDSet);

            for(Case caseRecordWithChild : casesWithChildren){
                if( !caseRecordWithChild.Cases.isEmpty() ){
                    newCaseMap.get( caseRecordWithChild.Id ).ClosureReason__c = DO_Case.CASE_CLOSURE_REASON_COMPLETED_PARENT;
                }
            }
        }
        
    }
}