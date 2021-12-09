trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before delete, after update) {
    new TH_QuoteLineItem().execute();
}