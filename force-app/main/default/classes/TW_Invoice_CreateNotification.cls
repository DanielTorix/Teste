/**
@description    worker class to create a notification for an Invoice
@testClass      TW_Invoice_CreateNotificationTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Carolina Resende                28/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/

public without sharing class TW_Invoice_CreateNotification {
    private IREP_Contact contactRepository;
    private IREP_User userRepository;
    private ISL_ChatterNotifications contactChatterNotifications;

    public TW_Invoice_CreateNotification(){
        contactChatterNotifications = new SL_ChatterNotifications();   
        contactRepository = new REP_Contact();
        userRepository = new REP_User();
    }

    @testVisible
    private TW_Invoice_CreateNotification( ISL_ChatterNotifications contactChatterNotifications, IREP_Contact contactRepository, IREP_User userRepository){
        this.contactChatterNotifications = contactChatterNotifications;  
        this.contactRepository = contactRepository;
        this.userRepository = userRepository;
    }

    public void execute(List<Invoice__c> invoiceList) {
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accountMapByID = new Map<Id,Account>();

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
            for (Invoice__c invoice : invoicelist) {
                for (User userFound : accountUsersMap.get(Invoice.Account__C)) {
                    SL_ChatterNotifications contactChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                        .setPreText('')
                        .setPosText(' ' + System.Label.ChatterNewInvoiceMessage)
                        .setMentionIds(new List<String>{userFound.Id})
                        .setSubjectId(invoice.Id)
                        .build();
                    contactChatterNotifications.addFeedItemInputList( contactChatterNotificationPost.getFeedItemInputList());
                }
            }
        
            contactChatterNotifications.persistChatterPosts();
        }
    }
}