/**
    @description   
    @TestClass     FW_SObjectSelectorTest
 */
public abstract class FW_SObjectSelector implements FW_IQuerySpecification, FW_ISObjectSelector {
    
    private FW_QueryBuilder builder;

    /**
        * Gets the active query builder for this Selector; created during class construction.
    */
    public FW_QueryBuilder queryBuilder { 
        get {
            // Use lazy initialization to only create the QB when we really need it
            // this way we can avoid a CTOR for this class making it easier to inherit from it
            if (this.builder == null) {
                 this.builder = new FW_QueryBuilder(
                    ((FW_ISObjectSelector)this).getSObjectType(), 
                    ((FW_ISObjectSelector)this).getSObjectFieldList());
            }
            return this.builder;
        }
    }

    /**
        * Method name:          getQuery
        * @description:         Get the SOQL string from the underlying QueryBuilder
        * @param                
        * @return               String
    */
    public String getQuery() {
        return queryBuilder.getQuery();
    }
}