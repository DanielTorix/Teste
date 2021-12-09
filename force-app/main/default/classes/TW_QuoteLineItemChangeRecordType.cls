/**
* @description   worker class to change RecordType on Quote depending on discount changed manually
* @testClass     TW_QuoteLineItemChangeRecordTypeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               10/08/2021          Created QuoteLineItem Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_QuoteLineItemChangeRecordType {
    
    //interface calls
    private IREP_Quote quoteRepository;


     //constructor
    public TW_QuoteLineItemChangeRecordType() {
        
        this.quoteRepository = new REP_Quote();

    }

    //to use on test
    @TestVisible
    private TW_QuoteLineItemChangeRecordType(IREP_Quote quoteRepository) {

        this.quoteRepository = quoteRepository;

    }

    public void execute(List<QuoteLineItem> quoteLineItemList, Map<ID,QuoteLineItem> quoteLineItemOldMap){

        //variables used
        Set<Id> quoteToQueryIDSet = new Set<Id>();
        List<Quote> quoteToUpdateList = new List<Quote>();
        
        //check if the Discount was updated manually or via trigger by checking the Set
        for(QuoteLineItem quoteLineItemRecord : quoteLineItemList){
            if( !DO_Quote.QUOTE_QUOTELINEITEMID.contains(quoteLineItemRecord.ID ) && quoteLineItemRecord.DiscountValue__c != quoteLineItemOldMap.get(quoteLineItemRecord.ID).DiscountValue__c ){
                quoteToQueryIDSet.add(quoteLineItemRecord.QuoteId);
            }
        }

        //if the Set isn't empty will change the recordType of the quote
        if(!quoteToQueryIDSet.isEmpty()){
            for( Id quoteId : quoteToQueryIDSet ){
                quoteToupdateList.add( new Quote( Id = quoteId, RecordTypeId = DO_Quote.QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_ID ) );
            }
            quoteRepository.updateSObjects(quoteToupdateList);
        }

    }
}