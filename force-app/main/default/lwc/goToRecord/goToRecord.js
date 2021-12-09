import { LightningElement, track, wire, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from "lightning/navigation";

export default class goToRecord extends NavigationMixin(LightningElement) {
   @api
   recordId;
   @api pageMode;
   @api objectApiNameVar;
  


  
   renderedCallback() { 

      
        
      // Get the record ID attribute
      var record = this.recordId;
      var pageMode = this.pageMode;
      var objectApiNameVar = this.objectApiNameVar;
     
      // Open the record
      this[NavigationMixin.Navigate]({
         type: "standard__recordPage",
         
         attributes: {
            recordId: record,
            objectApiName: objectApiNameVar,
            actionName: pageMode
         }
        
         
          
      
      });
   }

   helperMethod() {

   }
}