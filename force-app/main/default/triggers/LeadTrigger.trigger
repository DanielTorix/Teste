/**
* @description   Lead Trigger
* @testClass     TH_LeadTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               26/05/2021          Created Lead RTrigger
* ------------------------------------------------------------------------------------ 
*/
trigger LeadTrigger on Lead (after update, before insert, before update) {
    new TH_Lead().execute();
}