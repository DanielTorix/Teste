/**
* @description   Quote Trigger
* @testClass     TH_QuoteTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               06/06/2021          Created Quote Trigger
* ------------------------------------------------------------------------------------ 
*/
trigger QuoteTrigger on Quote (before update , before insert, after insert, after update){

    new TH_Quote().execute();
}