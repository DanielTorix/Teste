import { LightningElement, api } from 'lwc';

import FetchAccount from '@salesforce/apex/communityPrivacyPolicyController.FetchAccount';

import PrivacyPolicyEnglish01 from '@salesforce/label/c.PrivacyPolicyEnglish01';
import PrivacyPolicyEnglish1 from '@salesforce/label/c.PrivacyPolicyEnglish1';
import PrivacyPolicyEnglish2 from '@salesforce/label/c.PrivacyPolicyEnglish2';
import PrivacyPolicyEnglish3 from '@salesforce/label/c.PrivacyPolicyEnglish3';
import PrivacyPolicyEnglish4 from '@salesforce/label/c.PrivacyPolicyEnglish4';
import PrivacyPolicyEnglish5 from '@salesforce/label/c.PrivacyPolicyEnglish5';
import PrivacyPolicyEnglish6 from '@salesforce/label/c.PrivacyPolicyEnglish6';

import PrivacyPolicyHungarian01 from '@salesforce/label/c.PrivacyPolicyHungarian01';
import PrivacyPolicyHungarian1 from '@salesforce/label/c.PrivacyPolicyHungarian1';
import PrivacyPolicyHungarian2 from '@salesforce/label/c.PrivacyPolicyHungarian2';
import PrivacyPolicyHungarian3 from '@salesforce/label/c.PrivacyPolicyHungarian3';
import PrivacyPolicyHungarian4 from '@salesforce/label/c.PrivacyPolicyHungarian4';
import PrivacyPolicyHungarian5 from '@salesforce/label/c.PrivacyPolicyHungarian5';
import PrivacyPolicyHungarian6 from '@salesforce/label/c.PrivacyPolicyHungarian6';

export default class ScreenPrivacyPolicy extends LightningElement {

    @api title;
    @api text1;
    @api text2;
    @api text3;
    @api text4;
    @api text5;
    @api text6;
    @api background;

    connectedCallback(){
        
        FetchAccount ({}).then(
            result => {
                console.log('result = ' + JSON.stringify(result));
                var returnCountry = JSON.stringify(result).toString();
                if(returnCountry === 'HU'){
                    this.title = PrivacyPolicyHungarian01;
                    this.text1 = PrivacyPolicyHungarian1;
                    this.text2 = PrivacyPolicyHungarian2;
                    this.text3 = PrivacyPolicyHungarian3;
                    this.text4 = PrivacyPolicyHungarian4;
                    this.text5 = PrivacyPolicyHungarian5;
                    this.text6 = PrivacyPolicyHungarian6;
                    console.log('HUNGARIAN');
                }else{
                    this.title = PrivacyPolicyEnglish01;
                    this.text1 = PrivacyPolicyEnglish1;
                    this.text2 = PrivacyPolicyEnglish2;
                    this.text3 = PrivacyPolicyEnglish3;
                    this.text4 = PrivacyPolicyEnglish4;
                    this.text5 = PrivacyPolicyEnglish5;
                    this.text6 = PrivacyPolicyEnglish6;
                    console.log('ENGLISH');
                }           
            }
        ).catch(
            error => {
                console.error('Error getting related record: ' + error);
            }
        );

    }
 
}