@isTest
public class FW_SObjectSelectorTest {

    @isTest
    static void testAccountSelector() {
        FW_SObjectSelector accountSelector = new FW_AccountSelector();

        Test.startTest();
            String query = accountSelector.getQuery();
        Test.stopTest();

        system.assertEquals('SELECT Id,Name FROM Account', query);
    }

    private class FW_AccountSelector extends FW_SObjectSelector {

        public Schema.SObjectType getSObjectType() {
            return Account.SObjectType;
        }

        public List<Schema.SObjectField> getSObjectFieldList() {
            return new List<SObjectField> {
                    Account.Id,
                    Account.Name
            };
        }
    }
}