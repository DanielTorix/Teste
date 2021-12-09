trigger UserTrigger on User (before insert) {
    new TH_User().execute();
}