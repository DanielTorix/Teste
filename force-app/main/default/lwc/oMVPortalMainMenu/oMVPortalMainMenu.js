import { LightningElement, api  } from 'lwc';
import OMV_LOGO from '@salesforce/resourceUrl/OMVLogo';
import getOMVPortalLayout from '@salesforce/apex/oMVPortalMainMenuControler.getOMVPortalLayout';

export default class OMVPortalMainMenu extends LightningElement {

    @api portalObject = new Object;
    energycolor;
    OMVLogoUrl = OMV_LOGO;
    connectedCallback() {
        getOMVPortalLayout({ }).then( result => {        
                this.portalObject = result;
                this.energycolor=result.MenuEnergyLineColor__c;
            }).catch(
            error => {
                console.error('Error getting Portal info: ' + error);
            }
        );
    }
    get EnergyStyle() {
        return `background-color:${this.energycolor};width:100%;height: 4px;`;
    }
}