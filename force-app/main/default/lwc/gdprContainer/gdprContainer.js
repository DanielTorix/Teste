import { api, wire, track, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import showGDPR from '@salesforce/apex/GDPRController.showGDPR';
import getContentDocumentId from '@salesforce/apex/GDPRController.getContentDocumentId';
import updateGDPRConsent from '@salesforce/apex/GDPRController.updateGDPRConsent';

import header from '@salesforce/label/c.GDPR_Header';
import body from '@salesforce/label/c.GDPR_Body';
import openFile from '@salesforce/label/c.GDPR_OpenFileBtn';
import accept from '@salesforce/label/c.GDPR_AcceptBtn';

export default class GdprContainer extends NavigationMixin(LightningElement) {

    label = {
        header,
        body,
        openFile,
        accept
    }

    @api contentDocId;
    @api contentVersionId;
    @api isLoading = false;
    @api showGDPR = false;
    @api disableButton = false;

    connectedCallback(){
        try{
              this.showPopup();
        }catch(ex){
            console.error(ex);
             this.showNotification('Error', ex.message, 'error');
        }

    }

    showPopup(){
        this.disableButton = true;
        this.isLoading = true;
        showGDPR()
        .then(result => {
             this.showGDPR = result;
             if(this.showGDPR){
                  getContentDocumentId()
                  .then(data => {
                      let obj = JSON.parse(data);
                      this.contentDocId = obj.ContentDocumentId;
                      this.contentVersionId = obj.Id;
                      this.isLoading = false;
                  });
            }
            this.isLoading = false;
    });
    }

     showGDPRFile() {
          this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://'+location.host+'/customerportal/sfc/servlet.shepherd/version/renditionDownload?rendition=pdf&versionId='+this.contentVersionId
            }
          },false);
          this.disableButton = false;
        }

    signConsent(){
        updateGDPRConsent({
            contentDocumentId : this.contentDocId
        })
        .then(resp =>{
            this.isLoading = false;
            if(resp == 'OK'){
                 this.showGDPR = false;
            }else{
               this.showNotification('Error', resp, 'error');
            }
        })
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}