trigger TaskTrigger on Task (after insert, after update) {
    new TH_Task().execute();
}