/**
* @description   worker class to check if Criteria Name is ok or not
* @testClass     TW_ProductDiscountCriteria_CheckAPITest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               04/08/2021          Created ProductDiscountCriteria Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_ProductDiscountCriteria_CheckAPIName {
    public void execute(List<ProductDiscountCriteria__c>  productDiscountCriteriaList){
        List<String> quoteFields = new List<String>(Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap().keySet());

        for (ProductDiscountCriteria__c criteriaInserted : productDiscountCriteriaList) {
            String name = criteriaInserted.Name;
            if (!quoteFields.contains(name.toLowerCase())) {
                criteriaInserted.addError(Label.DiscountCriteriaErrorMsg);
            }
        }
    }
}