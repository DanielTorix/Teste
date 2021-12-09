import { LightningElement, track, wire, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from "lightning/navigation";

export default class navigateToExternalURL extends NavigationMixin(LightningElement) {
   @api urlAddress;

   renderedCallback() { 
     
      var urlAddress = this.urlAddress;

      // Open the record
      this[NavigationMixin.Navigate]({
         type: "standard__webPage",
         
         attributes: {
            url: urlAddress
         }
        
      });
   }

   helperMethod() {

   }
}