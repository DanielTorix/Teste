/**
* @description   Interface for the ProductDiscount Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                28/07/2021          Interface for the ProductDiscount Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_ProductDiscount extends FW_ISObjectRep{
    List<ProductDiscount__c> getProductDiscountsCriteria(Set<Id> productIdSet);
}