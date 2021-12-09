/**
@description    worker class to copy default parameter to the job execution record
@testClass      TW_Case_CloseChildCasesTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                26/05/2021          Created the class
* Hugo Rodrigues                  15/09/2021            updated class
* ------------------------------------------------------------------------------------        
*/
public class TW_Case_CloseChildCases {
    
    private IREP_Case caseRepository;
    private ISL_ChatterNotifications caseChatterNotifications;
    
    public TW_Case_CloseChildCases(){
        this.caseRepository = new REP_Case();
        this.caseChatterNotifications = new SL_ChatterNotifications();
    }
    
    @TestVisible
    private TW_Case_CloseChildCases(IREP_Case caseRepository, ISL_ChatterNotifications caseChatterNotifications){
        this.caseRepository = caseRepository;
        this.caseChatterNotifications = caseChatterNotifications;
    }
    
    public void execute(List<Case> caseList, Map<Id,Case> oldCaseMap) {
        Map<Id,Case> casesClosedMap = new Map<Id,Case>();
        Set<Id> closedCasesIdSet = new Set<Id>();
        ID caseRecordTypeCase = DO_Case.CASE_RECORDTYPEID_CASE;
        ID caseRecordTypeClaim = DO_Case.CASE_RECORDTYPEID_CLAIM;
        ID caseRecordTypeComplaint = DO_Case.CASE_RECORDTYPEID_COMPLAINT;
        for(Case caseUpdated : caseList){
            if(caseUpdated.Status != oldCaseMap.get(caseUpdated.Id).Status && caseUpdated.IsClosed == true){
                closedCasesIdSet.add(caseUpdated.Id);
                casesClosedMap.put(caseUpdated.Id, caseUpdated);
            }
        }
        if(!closedCasesIdSet.isEmpty()){
            List<Case> casesToUpdateList = caseRepository.getChildCases(closedCasesIdSet);
            
            for(Case caseToClose: casesToUpdateList){
            
                if (String.isBlank(caseToClose.Source__c) || String.isBlank(caseToClose.CategoryT1__c) || 
                (caseToClose.CategoryT1__c != DO_Case.CASE_CATEGORY1_SPAM && (String.isBlank(caseToClose.CategoryT2__c) || String.isBlank(caseToClose.CategoryT3__c)))) {
                    casesClosedMap.get(caseToClose.ParentId).addError(Label.CloseChildCasesTriggerErrorMessage);
                }else{
                    if (caseToClose.RecordTypeID == caseRecordTypeCase) {
                        caseToClose.Status = DO_Case.CASE_STATUS_CLOSED;
                    }else if (caseToClose.RecordTypeID== caseRecordTypeClaim || caseToClose.RecordTypeID == caseRecordTypeComplaint) {
                        caseToClose.Status = DO_Case.CASE_STATUS_COMPLETED;
                    }
                    
                    if(caseToClose.Parent.OwnerId != caseToClose.OwnerId){
                        //validar traduções
                        SL_ChatterNotifications caseChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                        .setPreText(System.Label.CloseCaseText + ' ')
                        .setPosText(System.Label.CloseCaseText2 + ' ' + caseToClose.CaseNumber +System.Label.CloseCaseText3 + ' ' + caseToClose.Parent.CaseNumber + ' ' + System.Label.CloseCaseText4 + ' ' +caseToClose.Parent.Owner.Name)
                        .setMentionIds(new List<String>{caseToClose.OwnerId})
                        .setSubjectId(caseToClose.Id)
                        .build();
    
                        caseChatterNotifications.addFeedItemInputList( caseChatterNotificationPost.getFeedItemInputList() );
                    }
                }   
            } 
         
            if(!casesToUpdateList.isEmpty()){
                caseRepository.updateSObjects(casesToUpdateList);
                caseChatterNotifications.persistChatterPosts();            
            }
        }
    }
}