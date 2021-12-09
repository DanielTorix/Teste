public interface IREP_EmailMessage extends FW_ISObjectRep{
    List<EmailMessage> getEmailMessagesById(List<Id> emailIdList);
    
}