/**
    * @description   Interface selector for Object Selector
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_ISObjectSelector {

    /**
        *  @description:    Get the SObject type that this selector is selecting. The SOBject type being selected
    */
    SObjectType getSObjectType();

    /**
        *  @description:    Get the standard list of fields that is being selected for 
                            the SObjectType from this selector. Standard field list being selected.
    */
    List<SObjectField> getSObjectFieldList();
}