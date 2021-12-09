trigger FW_BatchDefinitionTrigger on Batch_Definition__c (after insert) {
    new FW_TH_BatchDefinition().execute();
}