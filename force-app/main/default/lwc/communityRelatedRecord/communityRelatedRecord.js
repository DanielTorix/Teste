import { LightningElement, api } from 'lwc';
import getRelatedRecord from '@salesforce/apex/communityRelatedRecordController.getRelatedRecord';

export default class CommunityRelatedRecord extends LightningElement {
    @api width;
    @api height;
    @api labelStyle;
    @api valueStyle;
    @api cardStyle;

    @api baseObject;
    @api recordFilter;
    @api relatedRecord;

    @api label1;
    @api label2;
    @api label3;
    @api label4;
    @api label5;

    @api field1;
    @api field2;
    @api field3;
    @api field4;
    @api field5;

    @api value1;
    @api value2;
    @api value3;
    @api value4;
    @api value5;

    @api field1DateFormat;
    @api field2DateFormat;
    @api field3DateFormat;
    @api field4DateFormat;
    @api field5DateFormat;
    
    @api button;
    @api buttonStyle;
    @api buttonDivStyle;
    @api buttonAction;

    resolve(path, obj) {
        return path.split('.').reduce(function(prev, curr) {
            return prev ? prev[curr] : null
        }, obj || self);
    }

    connectedCallback() {
        getRelatedRecord(
            {
                baseObject: this.baseObject,
                recordFilter: this.recordFilter,
                relatedRecord: this.relatedRecord,
                fieldList: [
                    this.field1,
                    this.field2,
                    this.field3,
                    this.field4,
                    this.field5
                ]
            }
        ).then(
            result => {
                console.log('got related record result=' + JSON.stringify(result));
                
                this.value1 = this.resolve(this.relatedRecord + '.' + this.field1, result);
                if(this.field1DateFormat){         
                    this.value1 = new Date( Date.parse(this.value1) ).toLocaleDateString();
                }
                this.value2 = this.resolve(this.relatedRecord + '.' + this.field2, result);
                if(this.field2DateFormat){
                    this.value2 = new Date( Date.parse(this.value2) ).toLocaleDateString();
                }
                this.value3 = this.resolve(this.relatedRecord + '.' + this.field3, result);
                if(this.field3DateFormat){
                    this.value3 = new Date( Date.parse(this.value3) ).toLocaleDateString();
                }
                this.value4 = this.resolve(this.relatedRecord + '.' + this.field4, result);
                if(this.field4DateFormat){
                    this.value4 = new Date( Date.parse(this.value4) ).toLocaleDateString();
                }
                this.value5 = this.resolve(this.relatedRecord + '.' + this.field5, result);
                if(this.field5DateFormat){
                    this.value5 = new Date( Date.parse(this.value5) ).toLocaleDateString();
                }
                
            }
        ).catch(
            error => {
                console.error('Error getting related record: ' + error);
            }
        );
    }

    get computedCardStyle() {
        return `width: ${this.width}; height: ${this.height}; ${this.cardStyle}`;
    }
}