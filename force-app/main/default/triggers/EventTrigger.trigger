trigger EventTrigger on Event (after insert, after update) {
    new TH_Event().execute();
}