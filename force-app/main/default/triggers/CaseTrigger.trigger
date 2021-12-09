trigger CaseTrigger on Case (after update, after insert, before insert, before update) {
    new TH_Case().execute();
}