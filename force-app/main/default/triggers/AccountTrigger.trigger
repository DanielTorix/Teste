trigger AccountTrigger on Account (after update, before insert, before update) {
    new TH_Account().execute();
}