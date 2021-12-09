/**
* @description   worker class to map fields from Lead to Contact
* @testClass     TW_LeadContactMappingTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               13/10/2021          Created Lead Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_LeadContactMapping {
    //interface definition
    private IREP_Contact contactRepository;
    
    //constructor
     public TW_LeadContactMapping(){
         this.contactRepository = new REP_Contact();
      
    }
    
    //to use on test
    @TestVisible
    private TW_LeadContactMapping(IREP_Contact contactRepository){
        this.contactRepository = contactRepository;
        
    }
    
    //method execute
    public void execute(List<Lead> leadList, Map<Id,Lead> leadOldMap) {

        Set<Id> contactIDSet = new Set<Id>();
        List <Contact> contactListToUpdate = new List<Contact>();
        for(Lead leadRecord : leadList){
            if(leadOldMap.get(leadRecord.Id).IsConverted ==false && leadRecord.IsConverted == true){
                contactIDSet.add(leadRecord.ConvertedContactId);
                system.debug(leadRecord.ConvertedContactId);
            }
        }
        if(!contactIDSet.isEmpty()){
            Map<ID,Contact> contactMap=  New Map<ID,Contact>( contactRepository.getContactById(contactIDSet));
        
            if(!contactMap.isEmpty()){
            
                for(Lead leadRecord : leadList){
                    contactMap.get(leadRecord.ConvertedContactId).Title = leadRecord.Job_Title__c;
                    contactMap.get(leadRecord.ConvertedContactId).MobilePhone = leadRecord.MobilePhone;
                    contactMap.get(leadRecord.ConvertedContactId).OtherPhone = leadRecord.Phone;
                    contactMap.get(leadRecord.ConvertedContactId).MailingCity = leadRecord.City;
                    contactMap.get(leadRecord.ConvertedContactId).MailingCountry = leadRecord.Country;
                    contactMap.get(leadRecord.ConvertedContactId).MailingPostalCode = leadRecord.PostalCode;
                    contactMap.get(leadRecord.ConvertedContactId).MailingState = leadRecord.State;
                    contactMap.get(leadRecord.ConvertedContactId).MailingStreet = leadRecord.Street;
                
                    if(!contactListToUpdate.contains(contactMap.get(leadRecord.ConvertedContactId))){
                        contactListToUpdate.add(contactMap.get(leadRecord.ConvertedContactId));
                    }
                }
   
            }
            if(!contactListToUpdate.isEmpty()){
                contactRepository.updateSObjects(contactListToUpdate);
            }
        }
    }
}