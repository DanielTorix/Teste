/**
* @description   worker class to add discounts to the quote
* @testClass     TW_QuoteLineItem_AddDiscountsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               28/07/2021          Created QuoteLineItem Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_QuoteLineItem_AddDiscounts {

    private IREP_ProductDiscount productDiscountRepository;
    private IREP_Quote quoteRepository;
    private IREP_PricebookEntry pricebookEntryRepository;
    private IDO_QuoteLineItem quoteLineItemDomain;
    
    //constructor
     public TW_QuoteLineItem_AddDiscounts(){
         this.productDiscountRepository = new REP_ProductDiscount();
         this.quoteRepository = new REP_Quote();
         this.pricebookEntryRepository = new REP_PricebookEntry();
         this.quoteLineItemDomain = new DO_QuoteLineItem();
    }
    
    //to use on test
    @TestVisible
    private TW_QuoteLineItem_AddDiscounts(IREP_ProductDiscount productDiscountRepository, IREP_Quote quoteRepository, IREP_PricebookEntry pricebookEntryRepository, IDO_QuoteLineItem quoteLineItemDomain){
        this.productDiscountRepository = productDiscountRepository;
        this.quoteRepository = quoteRepository;
        this.pricebookEntryRepository = pricebookEntryRepository;
        this.quoteLineItemDomain = quoteLineItemDomain;
    }

    public void execute(List<QuoteLineItem> quoteLineItemList){
        Set<Id> quoteToQueryIDSet = new Set<Id>();
        Set<Id> pricebookEntryToQueryIdSet = new Set<Id>(); 
        for (QuoteLineItem quoteLineItemInserted : quoteLineItemList) {
            quoteToQueryIDSet.add(quoteLineItemInserted.QuoteId);
            pricebookEntryToQueryIdSet.add(quoteLineItemInserted.PricebookEntryId);
        }

        Map<Id,PricebookEntry> pricebookEntryMap = new Map<Id,PricebookEntry>();

        if (!pricebookEntryToQueryIdSet.isEmpty()) {
            pricebookEntryMap = new Map<Id,PricebookEntry>(pricebookEntryRepository.getPricebookEntryInformation(pricebookEntryToQueryIdSet));
        }
        
        Set<Id> productToQueryIdSet = new Set<Id>();
        for (PricebookEntry entries : pricebookEntryMap.values()) {
            productToQueryIdSet.add(entries.Product2Id);
        }

        Map<id,Quote> cardQuoteMap = New Map<id,Quote>();

        if (!quoteToQueryIDSet.isEmpty()) {
            cardQuoteMap = New Map<id,Quote>(quoteRepository.getCardsQuotes(quoteToQueryIDSet));
        }
        
        //Key = Product ID, Value = List Product Discount
        Map<Id,List<ProductDiscount__c>> discountsMap = new Map<Id,List<ProductDiscount__c>>();
        for(ProductDiscount__c prodDiscount : productDiscountRepository.getProductDiscountsCriteria(productToQueryIdSet)) {
            if(discountsMap.containsKey(prodDiscount.Product__c)){
                discountsMap.get(prodDiscount.Product__c).add(prodDiscount);
            } else {
                discountsMap.put(prodDiscount.Product__c, new List<ProductDiscount__c>{prodDiscount});
            }
        }

        for (QuoteLineItem quoteLineItem : quoteLineItemList) {
            if(cardQuoteMap.containsKey(quoteLineItem.QuoteId)
                && discountsMap.containsKey(pricebookEntryMap.get(quoteLineItem.PricebookEntryId).Product2Id)){
                for (ProductDiscount__c discount : discountsMap.get(pricebookEntryMap.get(quoteLineItem.PricebookEntryId).Product2Id)) {
                    
                        if (quoteLineItemDomain.isToApplyDiscountToQuoteItem(cardQuoteMap.get(quoteLineItem.QuoteId), discount.ProductsDiscountCriteria__r, (Integer)discount.QuantityOfCriteria__c)) {
                            quoteLineItem.DiscountValue__c = discount.DiscountValue__c;
                            quoteLineItem.DiscountUnit__c = discount.DiscountUnit__c;
                        }
                    
                }
            }
        }
    }
}