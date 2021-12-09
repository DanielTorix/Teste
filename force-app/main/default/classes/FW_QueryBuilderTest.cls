@isTest
public class FW_QueryBuilderTest {

    @isTest
    public static void getQuery_simpleQuery_shouldReturnValidQuery(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Job_Execution__c.SObjectType);
        
        
        String query = builder
            .selectField(Job_Execution__c.Id)
            .selectField(Job_Execution__c.AsyncApexJobId__c	)
            .setLimit(10)
            .setOffset(0)
            .getQuery();

        
        System.assertEquals('SELECT Id,AsyncApexJobId__c FROM Job_Execution__c LIMIT 10 OFFSET 0', query);
    }

    @isTest
    public static void getQuery_withFieldsFromRelatedObject_shouldReturnValidQuery(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Job_Execution__c.SObjectType);

        
        Test.startTest();
        String query = builder
            .selectField(Job_Execution__c.Id)
            .selectFields(Job_Execution__c.Batch_Definition__c, new SObjectField[]{ Batch_Definition__c.Job_Size__c, Batch_Definition__c.Name })
            .orderbyparentfieldDesc(Job_Execution__c.Batch_Definition__c,Batch_Definition__c.Job_Size__c)
            .orderbyparentfieldAsc(Job_Execution__c.Batch_Definition__c,Batch_Definition__c.Name)
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT Id,Batch_Definition__r.Job_Size__c,Batch_Definition__r.Name FROM Job_Execution__c ORDER BY Batch_Definition__r.Job_Size__c DESC,Batch_Definition__r.Name ASC', query);
    }

    @isTest
    public static void getQuery_doubleNestedJoin_shouldReturnValidQuery(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Job_Execution__c.SObjectType);

        
        Test.startTest();
        String query = builder
            .selectField(Job_Execution__c.Id)
            .join(Job_Execution__c.Batch_Definition__c,
                new FW_QueryBuilder(Batch_Definition__c.SObjectType)
                    .selectField(Batch_Definition__c.Id)
                    .join(Batch_Definition__c.LastModifiedById,
                        new FW_QueryBuilder(User.SObjectType)
                            .selectField(User.Id))
            ).getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT Id,Batch_Definition__r.Id,Batch_Definition__r.LastModifiedBy.Id FROM Job_Execution__c', query);
    }

    @isTest
    public static void getQuery_JoinWithSecurity_shouldReturnInValidQuery(){
        
        List<User> userList = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null);

        FW_QueryBuilder builder = new FW_QueryBuilder(Job_Execution__c.SObjectType);
        builder.setcheckSecurity(true) ;
        String sbQueryException='';
        
        Test.startTest();
        System.runAs(userList[0]) {
            try{
                builder.selectField(Job_Execution__c.Id)
                    .join(Job_Execution__c.Batch_Definition__c,
                        new FW_QueryBuilder(Batch_Definition__c.SObjectType)
                        .selectField(Batch_Definition__c.Id)
                    );

            }catch(Exception ex){

                sbQueryException = 'exception in the query';
            }

        }
        
        Test.stopTest();
        
        
        System.assertEquals('exception in the query', sbQueryException);
    }

    @isTest
    public static void getQuery_withWhereClause_shouldReturnValidQuery(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Job_Execution__c.SObjectType);
        String name = '0';

        
        Test.startTest();
        String query = builder
            .selectField(Job_Execution__c.Id)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .setWhere('Name = :name')
            .getQuery();
        Test.stopTest();
        
        
        System.assertEquals('SELECT Id,AsyncApexJobId__c FROM Job_Execution__c WHERE Name = :name', query);
    }

    @isTest
    public static void getQuery_withWhereEquals_shouldReturnValidQuery(){
        
        Test.startTest();
        String query =  new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .whereEquals(Job_Execution__c.Id, 'ID')
            .orderbyDesc('AsyncApexJobId__c',false)
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT Id,AsyncApexJobId__c FROM Job_Execution__c WHERE Id = \'ID\' ORDER BY AsyncApexJobId__c DESC', query);
    }

    @isTest
    public static void getQuery_withWhereIn_shouldReturnValidQuery(){
        
        Test.startTest();
        String query =  new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .whereIn(Job_Execution__c.AsyncApexJobId__c, new Object[]{ '1', '2' })
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT Id,AsyncApexJobId__c FROM Job_Execution__c WHERE AsyncApexJobId__c in (\'1\',\'2\')', query);
    }

    @isTest
    public static void getQuery_withWhereInEmptyList_shouldReturnValidQuery(){
        
        Test.startTest();
        String query =  new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .whereIn(Job_Execution__c.AsyncApexJobId__c, new Object[]{})
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT Id,AsyncApexJobId__c FROM Job_Execution__c WHERE AsyncApexJobId__c in (\'\')', query);
    }

    @isTest
    public static void getQuery_withWhereEqualsAndIn_shouldReturnValidQuery(){
        
        Test.startTest();
        String query =  new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .whereEquals(Job_Execution__c.Id, 'ID')
            .whereIn(Job_Execution__c.AsyncApexJobId__c, new Object[]{ '1', '2' })
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT Id,AsyncApexJobId__c FROM Job_Execution__c WHERE Id = \'ID\' AND AsyncApexJobId__c in (\'1\',\'2\')', query);
    }

    @isTest
    public static void getQuery_withGroupByClause_shouldReturnValidQuery(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .selectField(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT)
            .groupBy(Job_Execution__c.AsyncApexJobId__c)
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT AsyncApexJobId__c,COUNT(Id) FROM Job_Execution__c GROUP BY AsyncApexJobId__c', query);
    }
 
    @isTest
    public static void getQuery_withGroupByAndWhereClause_shouldReturnValidQuery(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .selectField(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT)
            .groupBy(Job_Execution__c.AsyncApexJobId__c)
            .setWhere('Status = :status')
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT AsyncApexJobId__c,COUNT(Id) FROM Job_Execution__c WHERE Status = :status GROUP BY AsyncApexJobId__c', query);
    }

    @isTest
    public static void getQuery_withGroupByRollUpAndWhereClause_shouldReturnValidQuery(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .selectField(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT)
            .groupByRollUp(new List<String>{'AsyncApexJobId__c'})
            .setWhere('Status = :status')
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT AsyncApexJobId__c,COUNT(Id) FROM Job_Execution__c WHERE Status = :status GROUP BY ROLLUP (AsyncApexJobId__c)', query, 'Different query');
    }

    @isTest
    public static void getQuery_withGroupByRollUpAndWhereClause_String(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .selectField(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT)
            .groupByRollUp('AsyncApexJobId__c')
            .setWhere('Status = :status')
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT AsyncApexJobId__c,COUNT(Id) FROM Job_Execution__c WHERE Status = :status GROUP BY ROLLUP (AsyncApexJobId__c)', query, 'Different query');
    }

    @isTest
    public static void getQuery_withGroupByRollUpAndWhereClause_Field(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.AsyncApexJobId__c)
            .selectField(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT)
            .groupByRollUp(Job_Execution__c.AsyncApexJobId__c)
            .setWhere('Status = :status')
            .getQuery();
        Test.stopTest();

        
        System.assertEquals('SELECT AsyncApexJobId__c,COUNT(Id) FROM Job_Execution__c WHERE Status = :status GROUP BY ROLLUP (AsyncApexJobId__c)', query, 'Different query');
    }

    @isTest
    public static void getQuery_selectFieldsWithSubselect_shouldReturnValidQuery(){
        
        Test.startTest();
        FW_QueryBuilder qb = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .selectFields(Job_Execution__c.Batch_Definition__c, new SObjectField[]{ Batch_Definition__c.Batch_Name__c, Batch_Definition__c.Name })
            .selectFields('Job_Executions__r', new SObjectField[]{ Job_Execution__c.Id, Job_Execution__c.AsyncApexJobId__c });
		 Test.stopTest();
        
        
        System.assertEquals('SELECT Id,Batch_Definition__r.Batch_Name__c,Batch_Definition__r.Name,(SELECT Id,AsyncApexJobId__c FROM Job_Executions__r) FROM Job_Execution__c', qb.getQuery());
    }

    @isTest
    public static void getQuery_selectFieldsWithAscSorting_shouldReturnValidQueryWithOrderBy(){
        
        Test.startTest();
        FW_QueryBuilder qb = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .orderByAsc(Job_Execution__c.Id);
		Test.stopTest();
        
        
        System.assertEquals('SELECT Id FROM Job_Execution__c ORDER BY Id ASC', qb.getQuery());
    }

    @isTest
    public static void getQuery_selectFieldsWithDescSorting_shouldReturnValidQueryWithOrderByDesc(){
        
        Test.startTest();
        FW_QueryBuilder qb = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .orderByDesc(Job_Execution__c.Id)
            .orderBy('Type', FW_QueryBuilder.SortOrder.DESCENDING);
		Test.stopTest();
        
        
        System.assertEquals('SELECT Id FROM Job_Execution__c ORDER BY Id DESC,Type DESC', qb.getQuery());
    }

    @isTest
    public static void getQuery_selectFieldsWithSubQuery_shouldReturnValidQueryWithChildRecords(){
        
        FW_ISObjectSelector selector = new FW_QueryBuilder(Job_Execution__c.SObjectType);
        String contactChildRelName;
        ChildRelationship contactRelationship;
        for(ChildRelationship rel: Job_Execution__c.SObjectType.getDescribe().getChildRelationships()) {
    		if(rel.getChildSObject() == Job_Execution__c.SObjectType) {
                    contactChildRelName = rel.getRelationshipName();
                	contactRelationship = rel;
                	break;
            }
        }
        Test.startTest();

        FW_QueryBuilder queryBase = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id);

        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .setWhere('Id = :accountId')
            .selectSubquery(contactRelationship, selector)
            .getQuery();
        
		FW_QueryBuilder queryb = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .setWhere('Id = :accountId')
            .selectSubquery(contactChildRelName, new SObjectField[]{ Job_Execution__c.Id, Job_Execution__c.Name })
            .getParent();
        
        String sbQuery= queryb.getquery();
        FW_QueryBuilder sbSubQuery=queryb.getsubquery(contactChildRelName);
        
      
        String sqQuery2 = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .setWhere('Id = :accountId')
            .selectSubquery(contactRelationship, queryBase)
            .getQuery();
       Test.stopTest();

        String sbQueryValidRel = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .setWhere('Id = :accountId')
            .selectSubquery(contactChildRelName, selector)
            .getParent()
            .getQuery();
        
       
       System.assertEquals('SELECT Id,(SELECT Id,Name FROM Job_Executions__r) FROM Job_Execution__c WHERE Id = :accountId', sbQuery);
       System.assertEquals('SELECT Id,(SELECT  FROM Job_Executions__r) FROM Job_Execution__c WHERE Id = :accountId', sbQueryValidRel);
       System.assertEquals('SELECT Id FROM Job_Execution__c', sqQuery2);

       
    }
    
    @isTest
    public static void getQuery_selectFieldAs_shouldReturnValidQueryWithAlias(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Job_Execution__c.SObjectType);
        
        
        Test.startTest();
		String query = builder
            .selectFieldAs(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT, 'Job_Executions__r')
            .orderBy(Job_Execution__c.Id)
            .getQuery();
        Test.stopTest();
        
        
        system.assertEquals('SELECT COUNT(Id) Job_Executions__r FROM Job_Execution__c ORDER BY Id', query);
    }
    
    @isTest
    public static void getQuery_selectFieldsWithSubQueryException_shouldReturnNoSuchRelationshipException(){
        
        FW_ISObjectSelector selector = new FW_QueryBuilder(Job_Execution__c.SObjectType);
        String sbQueryException = '';
        
        
        Test.startTest();
        try{
             sbQueryException = new FW_QueryBuilder(Job_Execution__c.SObjectType)
                .selectField(Job_Execution__c.Id)
                .setWhere('Id = :accountId')
                .selectSubquery('ContactsList', selector)
                .getQuery();
        }
        catch(Exception ex){
            sbQueryException = 'exception in the query';
        }
        Test.stopTest();
        
        
        System.assertEquals('exception in the query', sbQueryException);
        
    }
    
    @isTest
    public static void getQuery_selectFieldsWithSubQueryNullException_shouldThrowNoSuchRelationshipException(){
        
        String sbQueryException = '';
        
        
        Test.startTest();
        try{
             sbQueryException = new FW_QueryBuilder(Job_Execution__c.SObjectType)
                .selectField(Job_Execution__c.Id)
                .setWhere('Id = :accountId')
                .selectSubquery('badrelationshipname', new SObjectField[]{ Job_Execution__c.Id, Job_Execution__c.Name })
                .getQuery();
        }
        catch(Exception ex){
            sbQueryException = 'exception in the query';
        }
        Test.stopTest();
        
        
        System.assertEquals('exception in the query', sbQueryException);
    }

    
    @isTest
    public static void getQuery_withGroupByFieldsAndWhereClause_shouldReturnValidQuery(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Batch_Definition__c)
            .selectField(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT)
            .groupBy(new SObjectField[]{ Job_Execution__c.Id, Job_Execution__c.Batch_Definition__c })
            .setWhere('Status = :status')
            .orderBy('Batch_Definition__c')
            .getQuery();
		Test.stopTest();
        
        
        System.assertEquals('SELECT Batch_Definition__c,COUNT(Id) FROM Job_Execution__c WHERE Status = :status GROUP BY Id,Batch_Definition__c ORDER BY Batch_Definition__c', query);
        
    }
    
    @isTest
    public static void getQuery_withGroupByFieldNameAndWhereClause_shouldReturnValidQuery(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Batch_Definition__c)
            .selectField(Job_Execution__c.Id, FW_QueryBuilder.AggregateOperation.COUNT)
            .groupBy('Id')
            .setWhere('Status = :status')
            .orderByAsc('Id', true)
            .getQuery();
		Test.stoptest();
        
        
        System.assertEquals('SELECT Batch_Definition__c,COUNT(Id) FROM Job_Execution__c WHERE Status = :status GROUP BY Id ORDER BY Id ASC NULLS LAST', query);
        
    }
    
     @isTest
    public static void getQuery_selectFieldAndMultipleWhereClauses_shouldReturnValidQuery(){
        
        Test.startTest();
        String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
            .selectField(Job_Execution__c.Id)
            .whereNotEquals(Job_Execution__c.Id, '128797349876545')
            .whereNotEquals('Batch_Definition_Name__r.Name', 'Home Maintenance')
            .whereNotIn(Job_Execution__c.Queried_Records__c , new Object[]{'123', '321'})
            .whereNotIn('Job_Size__c', new Object[]{'111', '112'})
            .whereLike(Job_Execution__c.AsyncApexJobId__c , 'teste')
            .getQuery();
		Test.stoptest();
        
        
        System.assertEquals('SELECT Id FROM Job_Execution__c WHERE Id != \'128797349876545\' AND Batch_Definition_Name__r.Name != \'Home Maintenance\' AND Queried_Records__c not in (\'123\',\'321\') AND Job_Size__c not in (\'111\',\'112\') AND AsyncApexJobId__c LIKE \'teste\'', query);
        
    }
    
    
    
    @isTest
    public static void callQBUtilityMethods(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Account.SObjectType);
        
        
		builder.getSObjectType();
        
    }

    @isTest
    public static void getCountQueryTest(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Job_Execution__c.SObjectType);
        
        
        String query = builder
            .selectField(Job_Execution__c.Id)
            .selectField(Job_Execution__c.AsyncApexJobId__c	)
            .setWhere('Name = :name')
            .setLimit(10)
            .setOffset(0)
            .getCountQuery();

        
        System.assertEquals('SELECT count()  FROM Job_Execution__c WHERE Name = :name LIMIT 10', query);
    
    
    }

    @isTest
    public static void getQuery_Selectfields_Selector_Test(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Batch_Definition__c.SObjectType);
        FW_ISObjectSelector selector =new FW_QueryBuilder(Job_Execution__c.SObjectType);
        
        String query = builder
            .selectField(Batch_Definition__c.Id)
            .selectFields(Job_Execution__c.Batch_Definition__c,	selector)
            .setWhere('Name = :name')
            .setLimit(10)
            .getQuery();

        
        System.assertEquals('SELECT Id FROM Batch_Definition__c WHERE Name = :name LIMIT 10', query);
        

    }
    @isTest
    public static void getQuery_Selectfields_Query_Test(){
        
        FW_QueryBuilder builder = new FW_QueryBuilder(Batch_Definition__c.SObjectType);
        FW_QueryBuilder innerquery =new FW_QueryBuilder(Batch_Definition__c.SObjectType, new SObjectField[]{Batch_Definition__c.id});
        
        String query = builder
            .selectField(Job_Execution__c.Id)
            .selectFields(Job_Execution__c.Batch_Definition__c,	innerquery)
            .setWhere('Name = :name')
            .setLimit(10)
            .getQuery();

        
        System.assertEquals('SELECT Id,Batch_Definition__r.Id FROM Batch_Definition__c WHERE Name = :name LIMIT 10', query);
        

    }

}