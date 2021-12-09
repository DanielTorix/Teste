import { LightningElement, api } from 'lwc';

import getPrivacyPolicy from '@salesforce/apex/communityPrivacyPolicyController.getPrivacyPolicy';

export default class communityPrivacyPolicy extends LightningElement {
    @api displayCountryPrivacyPolicy;
    @api displayGlobalPrivacyPolicy;
    @api countryPrivacyPolicy;
    @api globalPrivacyPolicy;
    @api labelStyle

    connectedCallback(){
        //console.log('connected callback');

        getPrivacyPolicy (
            {
                browserTimeZone: Intl.DateTimeFormat().resolvedOptions().timeZone
            }
        ).then(
            result => {
                //console.log('setting country/global privacy policy');

                this.countryPrivacyPolicy = result.countryPrivacyPolicy;
                this.globalPrivacyPolicy = result.globalPrivacyPolicy;

                if (this.countryPrivacyPolicy !== undefined) {
                    this.displayCountryPrivacyPolicy = true;

                    //console.log('displayCountryPrivacyPolicy: TRUE');
                } else {
                    this.displayCountryPrivacyPolicy = false;

                    //console.log('displayCountryPrivacyPolicy: FALSE');
                }

                if (this.globalPrivacyPolicy !== undefined) {
                    this.displayGlobalPrivacyPolicy = true;

                    //console.log('displayGlobalPrivacyPolicy: TRUE');
                } else {
                    this.displayGlobalPrivacyPolicy = false;

                    //console.log('displayGlobalPrivacyPolicy: FALSE');
                }
            }
        ).catch(
            error => {
                //console.error('Error getting related record: ' + error);
            }
        );
    }

    renderedCallback() {
        //console.log('rendered callback');
        //console.log('rendered: displayCountry=' + this.displayCountryPrivacyPolicy);
        //console.log('rendered: displayGlobal=' + this.displayGlobalPrivacyPolicy);

        /*
        this.template
            .querySelector(".headertext")
            .style.fontsize = this.customFont;
        */
       
        if (this.displayCountryPrivacyPolicy === true) {
            let titleElem = document.createElement('p');
            let bodyElem = document.createElement('p');

            titleElem.innerHTML = this.countryPrivacyPolicy.title;
            bodyElem.innerHTML = this.countryPrivacyPolicy.bodyText;

            this.template.querySelector('.countryTitle').appendChild(titleElem);
            this.template.querySelector('.countryBody').appendChild(bodyElem);
        }

        if (this.displayGlobalPrivacyPolicy === true) {
            let titleElem = document.createElement('p');
            let bodyElem = document.createElement('p');

            titleElem.innerHTML = this.globalPrivacyPolicy.title;
            bodyElem.innerHTML = this.globalPrivacyPolicy.bodyText;

            this.template.querySelector('.globalTitle').appendChild(titleElem);
            this.template.querySelector('.globalBody').appendChild(bodyElem);
        }
    }
}