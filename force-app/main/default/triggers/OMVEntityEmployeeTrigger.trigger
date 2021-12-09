trigger OMVEntityEmployeeTrigger on OMVEntityEmployee__c (before insert,before update, before delete) {

    new TH_OMVEntityEmployee().execute();

}