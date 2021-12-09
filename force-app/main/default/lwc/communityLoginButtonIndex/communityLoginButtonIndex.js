import { LightningElement, api } from 'lwc';

export default class communityLoginButtonIndex extends LightningElement {
  @api width;
  @api height;
  @api labelStyle;
  @api valueStyle;
  @api cardStyle;

  @api baseObject;
  @api recordFilter;
  @api relatedRecord;
  
  @api button;
  @api buttonStyle;
  @api buttonDivStyle;
  @api buttonAction;

  resolve(path, obj) {
      return path.split('.').reduce(function(prev, curr) {
          return prev ? prev[curr] : null
      }, obj || self);
  }

  get computedCardStyle() {
      return `width: ${this.width}; height: ${this.height}; ${this.cardStyle}`;
  }
}