@isTest
public class REP_PermissionSetGroupComponentTest {
    @isTest
    static void PermissionSetGroupComponentTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);

        List<String> permSetLabelList = new List<String>(); 
        REP_PermissionSetGroupComponent PermissionSetGroupComponentRepository = new REP_PermissionSetGroupComponent();
        PermissionSetGroup permGroup = FW_TestDataFactory.createPermissionSetGroupWithComponent();

        System.runAs(runningUser){  
            permissionSet permSet = new PermissionSet(name='testFactoryGroup',Label='testFactoryGroup');
            insert permSet;
            
            PermissionSetGroupComponent permGroupComponent = new PermissionSetGroupComponent( PermissionSetGroupId = permGroup.Id, PermissionSetId = permSet.Id );
            insert permGroupComponent;
            test.startTest();
                
                List<PermissionSetGroupComponent> permSetGroupComponents = PermissionSetGroupComponentRepository.getPermissionSetsByGroupIdsAndLabels( new Set<Id>{permGroup.Id}, new List<String>{'testFactoryGroup'} );
            test.stopTest();
            System.assertEquals( 1, permSetGroupComponents.size() );
            
        }
    }
}