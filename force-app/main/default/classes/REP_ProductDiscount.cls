/**
* @description   ProductDiscount Repository
* @testClass     REP_ProductDiscountTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                28/07/2021          Created ProductDiscount Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_ProductDiscount extends FW_SobjectRep implements IREP_ProductDiscount{
    public List<ProductDiscount__c> getProductDiscountsCriteria(Set<Id> productIdSet){
        return [SELECT Id, QuantityOfCriteria__c, DiscountUnit__c, DiscountValue__c, Product__c, 
                (SELECT Name, FieldValue__c FROM ProductsDiscountCriteria__r WHERE IsActive__c = true) 
                FROM ProductDiscount__c 
                WHERE IsActive__c = true 
                AND Product__c IN :productIdSet];
    }
}