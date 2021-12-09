/**
* @description   ProductDiscountCriteria trigger handler
* @testClass     TH_ProductDiscountCriteriaTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                04/08/2021          Created ProductDiscountCriteria Handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_ProductDiscountCriteria extends FW_TriggerHandler{
    private List<ProductDiscountCriteria__c> newList;
    private Map<Id,ProductDiscountCriteria__c> oldMap;

    public TH_ProductDiscountCriteria(){
        this.newList = (List<ProductDiscountCriteria__c>) Trigger.New;
        this.oldMap = (Map<Id,ProductDiscountCriteria__c>) Trigger.OldMap;
    }

    protected override void executeBeforeInsert() {
        new TW_ProductDiscountCriteria_CheckAPIName().execute(newList);
    }
}