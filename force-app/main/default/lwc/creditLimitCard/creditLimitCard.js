import { LightningElement, api } from 'lwc';

import getCreditLimitDetails from '@salesforce/apex/creditLimitCardController.getCreditLimitDetails';

export default class CreditLimitCard extends LightningElement {
    @api accountId;
    @api creditLimit;
    @api cenas;
    @api hasCreditLimit = false;

    connectedCallback() {
        getCreditLimitDetails(
            {}
        ).then(
            result => {
                // success
                this.hasCreditLimit = true;
                this.creditLimit = result;

                console.log('creditLimit: ' + JSON.stringify(this.creditLimit));
            }
        ).catch(
            error => {
                // error
                console.log('got error: ' + JSON.stringify(error));
            }
        )
    }
}