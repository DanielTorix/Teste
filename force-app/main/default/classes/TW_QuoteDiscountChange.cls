/**
* @description   worker class to change disccount on QuoteLineItems depending on discount criteria
* @testClass     TW_QuoteDiscountChangeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               05/08/2021          Created Quote Worker
* Hugo Rodrigues               28/08/2021          Adjustment on class for best pratices
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_QuoteDiscountChange {
    
    //interface calls
    private IREP_ProductDiscount productDiscountRepository;
    private IREP_QuoteLineItem quoteLineItemRepository;
    private IREP_Quote quoteRepository;
    private IREP_PricebookEntry pricebookEntryRepository;
    private IDO_QuoteLineItem quoteLineItemDomain;
    
    //constructor
    public TW_QuoteDiscountChange(){
        this.productDiscountRepository = new REP_ProductDiscount();
        this.quoteRepository = new REP_Quote();
        this.pricebookEntryRepository = new REP_PricebookEntry();
        this.quoteLineItemDomain = new DO_QuoteLineItem();
        this.quoteLineItemRepository = new REP_QuoteLineItem();
    }
    
    //to use on test
    @TestVisible
    private TW_QuoteDiscountChange(IREP_ProductDiscount productDiscountRepository, IREP_Quote quoteRepository, IREP_PricebookEntry pricebookEntryRepository, IDO_QuoteLineItem quoteLineItemDomain, IREP_QuoteLineItem quoteLineItemRepository){
        this.productDiscountRepository = productDiscountRepository;
        this.quoteRepository = quoteRepository;
        this.pricebookEntryRepository = pricebookEntryRepository;
        this.quoteLineItemDomain = quoteLineItemDomain;
        this.quoteLineItemRepository = quoteLineItemRepository;
    }
    
    
    //method execute
    public void execute(List<Quote> quoteList, Map<ID,Quote> quoteOldMap){
        
        //variables
        Set<Id> pricebookEntryToQueryIdSet = new Set<Id>();
        Set<Id> productToQueryIdSet = new Set<Id>();
        List<Quote> quoteToUpdateList = new List<Quote>();
        List<QuoteLineItem> quoteLineItemToUpdateList = new List<QuoteLineItem>();
        ID recordTypeID = DO_Quote.QUOTE_CARDS_RECORDTYPE_ID;
        ID recordTypeWithApprovalID = DO_Quote.QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_ID;
        Map<Id,List<ProductDiscount__c>> discountsMap = new Map<Id,List<ProductDiscount__c>>();
        Boolean isToUpdateDiscount = false;
        
        //check if the RecordType is Cards if yes keep the quote on a List
        for(Quote quoteRecord : quoteList){
            if(quoteRecord.RecordTypeId == recordTypeID || quoteRecord.RecordTypeId == recordTypeWithApprovalID){
                quoteToUpdateList.add(quoteRecord);
            }
        }
        if(!quoteToUpdateList.isEmpty()){
            Map<ID,Quote> quoteNewMAp=  New Map<ID,Quote>(quoteRepository.getQuoteWithItemsById(new Map<ID,Quote>(quoteToUpdateList).keySet()));
        
            //get QuoteLineItems and add it to a List and Add pricebookEntry to a Set
            for(Quote quoteRecord :quoteNewMAp.Values()) {
                for(QuoteLineItem quoteLineItemRecord : quoteRecord.QuoteLineItems){
                    pricebookEntryToQueryIdSet.add(quoteLineItemRecord.PricebookEntryId);
                }  
            }
        
            if(!pricebookEntryToQueryIdSet.isEmpty()){
                Map<Id,PricebookEntry> pricebookEntryMap = new Map<Id,PricebookEntry>(pricebookEntryRepository.getPricebookEntryInformation(pricebookEntryToQueryIdSet));
                
                //Add product to a List
                for (PricebookEntry entries : pricebookEntryMap.values()) {
                    productToQueryIdSet.add(entries.Product2Id);
                }
                
                //Key = Product ID, Value = List Product Discount
                if(!productToQueryIdSet.isEmpty()){
                    for(ProductDiscount__c prodDiscount : productDiscountRepository.getProductDiscountsCriteria(productToQueryIdSet)) {
                        if(discountsMap.containsKey(prodDiscount.Product__c)){
                            discountsMap.get(prodDiscount.Product__c).add(prodDiscount);
                        } else {
                            discountsMap.put(prodDiscount.Product__c, new List<ProductDiscount__c>{prodDiscount});
                        }
                    }
                }
                
                //check if the quoteLineItem will need to be updated or not
                for(Quote quoteRecord :quoteNewMAp.Values()) {
                    for (QuoteLineItem quoteLineItem : quoteRecord.QuoteLineItems) {
                        if ( discountsMap.get(pricebookEntryMap.get(quoteLineItem.PricebookEntryId).Product2Id) != null ) {
                            for (ProductDiscount__c discount : discountsMap.get(pricebookEntryMap.get(quoteLineItem.PricebookEntryId).Product2Id)) {
                                isToUpdateDiscount = false;
                                for(ProductDiscountCriteria__c productdiscountCriteriaRecord : discount.ProductsDiscountCriteria__r){
                                    if ( quoteRecord.get(productdiscountCriteriaRecord.Name) != quoteOldMap.get(quoteRecord.Id).get(productdiscountCriteriaRecord.Name) ) {
                                        isToUpdateDiscount = true;
                                    }
                                }
                                if(isToUpdateDiscount){
                                        
                                    if(!quoteLineItemToUpdateList.contains(quoteLineItem)){

                                        if (discount.Product__c == pricebookEntryMap.get(quoteLineItem.PricebookEntryId).Product2Id) {
                                        
                                            if (quoteLineItemDomain.isToApplyDiscountToQuoteItem(quoteRecord, discount.ProductsDiscountCriteria__r, (Integer)discount.QuantityOfCriteria__c) && discount.DiscountValue__c !=null) {
                                                quoteLineItem.DiscountValue__c = discount.DiscountValue__c;
                                                quoteLineItem.DiscountUnit__c = discount.DiscountUnit__c;
                                                Do_Quote.QUOTE_QUOTELINEITEMID.add(quoteLineItem.ID);
                                                quoteLineItemToUpdateList.add(quoteLineItem);
                                            }
                                            else{
                                                quoteLineItem.DiscountValue__c =null;
                                                quoteLineItem.DiscountUnit__c =null; 
                                            }
                                        }
                                    }
                                }
                            } 
                            if(quoteLineItem.DiscountValue__c ==null && !quoteLineItemToUpdateList.contains(quoteLineItem) && isToUpdateDiscount) {
                                Do_Quote.QUOTE_QUOTELINEITEMID.add(quoteLineItem.ID);
                                quoteLineItemToUpdateList.add(quoteLineItem);
                            }    
                        }
                    }    
                    //if the list isn't empty it will update
                    if(!quoteLineItemToUpdateList.isEmpty()){
                        quoteLineItemRepository.updateSObjects(quoteLineItemToUpdateList);           
                    }
                }
            }
        }            
    }
}