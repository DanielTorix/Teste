public class TW_EmailMessage_PreventLoops {
    
    private IREP_Case caseRepository;
    private IREP_EmailMessage emailMessageRepository;
    
    public TW_EmailMessage_PreventLoops(){
        this.caseRepository = new REP_Case();
        this.emailMessageRepository = new REP_EmailMessage();
    }
    
    @TestVisible
    private TW_EmailMessage_PreventLoops(IREP_Case caseRepository, IREP_EmailMessage emailMessageRepository){
        this.caseRepository = caseRepository;
        this.emailMessageRepository = emailMessageRepository;
    } 
    
    public void execute(List<EmailMessage> emailMessageList) {
        getSetIdsfromList(emailMessageList);
        if(!emailMessageList.isEmpty()){ 
            List<EmailMessage> emailMessageFromSendedList = [Select id, FromAddress,ValidatedFromAddress, Incoming, IsOpened,ParentId, Status , Subject, TextBody  from emailMessage Where createdDate > :Datetime.now().addMinutes(-1)];
            System.debug(emailMessageFromSendedList);
            
        }  
    }
    
    private Set<Id> getSetIdsfromList(List<EmailMessage> emailMessageList){ 
        Set<Id> setIdsEmailMessage = new Set<Id>();
        for(EmailMessage emLoop:emailMessageList){
            setIdsEmailMessage.add(emLoop.Id);
        }
        return setIdsEmailMessage;
    }
    
    private Set<Id> getCases(Set<Id> setEmailMessageIds){
        Set<Id> setIdsEmailMessage = new Set<Id>();
        for(ID emLoop:setEmailMessageIds){
            setIdsEmailMessage.add(emLoop);
        }
        return setIdsEmailMessage;        
    }
    
}