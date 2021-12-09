trigger ContactTrigger on Contact (before insert, after update, before update) {
    new TH_Contact().execute();
}