/**
* @description   Batch created to notify the owner of the account of the target closure date
* @testClass     Async_FPSInvoiceRemainderTest
* @ScheduleClass Async_FPSInvoiceRemainderSchedule
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Carolina Resende                28/11/2021          Class created
* ------------------------------------------------------------------------------------ 
*/
  
global  class Async_FPSInvoiceRemainder extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{
    private IREP_User userRepository;
    private IREP_Contact contactRepository;
    private ISL_ChatterNotifications invoiceChatterNotifications;


    global Async_FPSInvoiceRemainder(){
        userRepository = new REP_User();
        contactRepository = new REP_Contact();
        invoiceChatterNotifications = new SL_ChatterNotifications();
    }

    @testVisible
    private Async_FPSInvoiceRemainder(IREP_User userRepository, IREP_Contact contactRepository, FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep, ISL_ChatterNotifications invoiceChatterNotifications){
        this.userRepository = userRepository;
        this.contactRepository = contactRepository;
        this.jobExecutionRep = jobExecutionRep; 
        this.parameterRep = parameterRep;
        this.invoiceChatterNotifications = invoiceChatterNotifications;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        setAsyncApexJobId(bc.getJobId());

        FW_QueryBuilder query = new FW_QueryBuilder(Invoice__c.SObjectType)
        .selectFields(REP_Invoice.INVOICE_FIELDS)
        .SetWhere('DueDate__c = ' + string.valueOf( Date.today().addDays(3) ));
        return executeQuery(query);
    }

    global void execute(Database.BatchableContext bc, List<Invoice__c> invoiceList) {
        Set<Id> accountIdSet = new Set<Id>();
        for (Invoice__c invoice : invoiceList) {
            accountIdSet.add(invoice.Account__c); 
        }

        Map<Id,List<User>> accountUsersMap = new Map<Id,List<User>>();

        if (!accountIdSet.isEmpty()) {
            Set<Id> contactIdSet = new Set<Id>();
            for(Contact contactReturned : contactRepository.getContactByAccountId(accountIdSet)) {
                contactIdSet.add(contactReturned.Id);
            }
            
            if (!contactIdSet.isEmpty()) {
                //Key = Account ID, Value = List Users
                for(User userReturned : userRepository.getPortalUsers(contactIdSet)) {
                    if(accountUsersMap.containsKey(userReturned.Contact.AccountId)){
                        accountUsersMap.get(userReturned.Contact.AccountId).add(userReturned);
                    } else {
                        accountUsersMap.put(userReturned.Contact.AccountId, new List<User>{userReturned});
                    }
                }
            }            
        }

        if (!accountUsersMap.isEmpty()) {
        for(Invoice__c invoiceRecord : invoiceList){
            for (User userFound : accountUsersMap.get(invoiceRecord.Account__C)) {
                SL_ChatterNotifications contactChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                    .setPreText('')
                    .setPosText(' ' + System.Label.ChatterReminderInvoiceMessage)
                    .setMentionIds(new List<String>{userFound.Id})
                    .setSubjectId(invoiceRecord.Id)
                    .build();
                invoiceChatterNotifications.addFeedItemInputList( contactChatterNotificationPost.getFeedItemInputList());
            }
        }
        invoiceChatterNotifications.persistChatterPosts();
    }
}
    global void finish(Database.BatchableContext bc) {
        finishBatch(bc.getJobId());
    }
}