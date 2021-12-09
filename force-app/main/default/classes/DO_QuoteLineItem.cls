/**
* @description   QuoteLineItem domain object class
* @testClass     DO_QuoteLineItemTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                03/08/2021          Created QuoteLineItem domain
* ------------------------------------------------------------------------------------ 
*/
public class DO_QuoteLineItem implements IDO_QuoteLineItem{
    /*
    * @author      Guilherme Charro
    * @description    method to check if the discounts criterias all match up with quote info
    */
    public Boolean isToApplyDiscountToQuoteItem(Quote quoteInfo, List<ProductDiscountCriteria__c> criteriasList, Integer quantityOfCriterias){
        Boolean returnValue = false;
        Integer criteriasMet = 0;
        for (ProductDiscountCriteria__c criteria : criteriasList) {
            String quoteFieldValue = (String)quoteInfo.get(criteria.Name);
            if (criteria.FieldValue__c == quoteFieldValue) {
                criteriasMet++;
            }
        }
        if (criteriasMet == quantityOfCriterias && quantityOfCriterias!=0 ) {
            returnValue = true;
        }
        
        return returnValue;
    }
}