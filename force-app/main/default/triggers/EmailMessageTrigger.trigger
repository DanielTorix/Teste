trigger EmailMessageTrigger on EmailMessage (after insert, before insert) {
    new TH_EmailMessage().execute();
}