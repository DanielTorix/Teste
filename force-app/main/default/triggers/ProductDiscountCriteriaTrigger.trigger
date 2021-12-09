/**
* @description   ProductDiscountCriteria Trigger
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               04/08/2021          Created ProductDiscountCriteria Trigger
* ------------------------------------------------------------------------------------ 
*/
trigger ProductDiscountCriteriaTrigger on ProductDiscountCriteria__c (before insert) {
    new TH_ProductDiscountCriteria().execute();
}