/**
    * @description   Framework super class of all the repositories. It contains all kind of DML methods of Database class
    * @testClass     FW_SObjectRepTest
    * Modification Log 
        * ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public virtual inherited sharing class FW_SObjectRep implements FW_ISObjectRep {

        private Boolean allOrNone = true;

        /**
                * @description:         this is a generic method to insert list of sobjects
        */
        public virtual List<Database.SaveResult> insertSObjects(List<SObject> sObjectList) {
                List<Database.SaveResult> resultList = Database.insert(sobjectList, this.allOrNone);
                return resultList;
        }

        /**
                * @description:         this is a generic method to update list of sobjects
        */
        public List<Database.SaveResult> updateSObjects(List<SObject> sobjectList) {          
                List<Database.SaveResult> resultList = Database.update(sobjectList, this.allOrNone);
                return resultList;
        }

        /**
                * @description:         this is a generic method to upsert list of sobjects
        */
        public List<Database.UpsertResult> upsertSObjects(List<SObject> sobjectList) {
                List<Database.UpsertResult> resultList = Database.upsert(sobjectList, this.allOrNone);
                return resultList;
        }    

        /**
                * @description:         this is a generic method to upsert list of sobjects by external id field
        */
        public List<Database.UpsertResult> upsertSObjects(List<SObject> sobjectList, SObjectField externalIdField) {
                List<Database.UpsertResult> resultList = Database.upsert(sobjectList, externalIdField);
                return resultList;
        } 

        /**
                * @description:         this is a generic method to delete list of sobjects
        */
        public List<Database.DeleteResult> deleteSObjects(List<SObject> sobjectList) {
                List<Database.DeleteResult> resultList = Database.delete(sobjectList, this.allOrNone);
                return resultList;
        }    

        /**
                * @description:         this is a method to set the allOrNone to a different value if needed
        */
        public void setAllOrNone(Boolean value) {
                this.allOrNone = value;
        }   
}