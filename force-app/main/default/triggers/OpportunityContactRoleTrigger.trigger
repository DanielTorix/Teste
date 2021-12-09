trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert, after update) {
    new TH_OpportunityContactRole().execute();
}