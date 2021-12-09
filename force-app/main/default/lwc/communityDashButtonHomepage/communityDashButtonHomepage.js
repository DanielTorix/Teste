import { LightningElement, api } from 'lwc';

export default class CommunityDashButtonHomepage extends LightningElement {

    @api buttonText;

handleClick() {
   console.log("Button Clicked!");
 }
}