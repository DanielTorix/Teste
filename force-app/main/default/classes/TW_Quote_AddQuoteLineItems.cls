/**
* @description   worker class to add mandatory products to the quote
* @testClass     TW_Quote_AddQuoteLineItemsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               20/07/2021          Created Quote Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_Quote_AddQuoteLineItems {

    private IREP_PricebookEntry pricebookEntryRepository;
    private IREP_QuoteLineItem quoteLineItemRepository;
    
    //constructor
     public TW_Quote_AddQuoteLineItems(){
         this.pricebookEntryRepository = new REP_PricebookEntry();
         this.quoteLineItemRepository = new REP_QuoteLineItem();
    }
    
    //to use on test
    @TestVisible
    private TW_Quote_AddQuoteLineItems(IREP_PricebookEntry pricebookEntryRepository, IREP_QuoteLineItem quoteLineItemRepository){
        this.pricebookEntryRepository = pricebookEntryRepository;
        this.quoteLineItemRepository = quoteLineItemRepository;
    }

    //Method Execute
    public void execute(List<Quote> quoteList){
        List<Quote> quotesToAddProducts = new List<Quote>();
        List<String> quoteTypes = new List<String>();
        List<String> pricebookIds = new List<String>();
        ID quoteWithApprovalID  =DO_Quote.QUOTE_CARDS_RECORDTYPE_ID;
        ID quoteWithoutApprovalID =DO_Quote.QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_ID;

        for (Quote quoteInserted : quoteList) {
            if ((quoteInserted.RecordTypeId == quoteWithoutApprovalID ||quoteInserted.RecordTypeId == quoteWithApprovalID) && !String.isBlank(quoteInserted.QuoteType__c)) {
                quoteTypes.add(quoteInserted.QuoteType__c);
                quotesToAddProducts.add(quoteInserted);
                pricebookIds.add(quoteInserted.Pricebook2Id);
            }
        }

        List<PricebookEntry> productsList = new List<PricebookEntry>();

        if (!quoteTypes.isEmpty() && !pricebookIds.isEmpty()) {
            productsList = pricebookEntryRepository.getMandatoryProducts(quoteTypes, pricebookIds);
        }
        
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();

        for (Quote quoteToAddProduct : quotesToAddProducts) {
            for (PricebookEntry productToAdd : productsList) {
                if (productToAdd.Product2.MandatoryQuoteType__c.contains(quoteToAddProduct.QuoteType__c) && productToAdd.Pricebook2Id == quoteToAddProduct.Pricebook2Id) {
                    QuoteLineItem quoteLineItem = new QuoteLineItem();
                    quoteLineItem.PricebookEntryId = productToAdd.Id;
                    quoteLineItem.QuoteId = quoteToAddProduct.Id;
                    quoteLineItem.UnitPrice = productToAdd.UnitPrice;
                    quoteLineItem.Quantity = 1;
                    quoteLineItem.IsMandatoryProduct__c=true;
                    if (productToAdd.Product2.Family == DO_Product.PRODUCT_FAMILY_FUEL) {
                        quoteLineItem.FuelPrice__c = productToAdd.UnitPrice;
                    }
                    quoteLineItemList.add(quoteLineItem);
                }
            }
        }

        if (!quoteLineItemList.isEmpty()) {
            quoteLineItemRepository.insertSObjects(quoteLineItemList);
        }
    }
}