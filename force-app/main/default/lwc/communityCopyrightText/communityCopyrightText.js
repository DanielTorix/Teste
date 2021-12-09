import { LightningElement, api } from 'lwc';
import OMV_LOGO from '@salesforce/resourceUrl/OMVLogo';

export default class CommunityCopyrightText extends LightningElement {
    @api isWhiteColor;
    @api phoneNumber;
    @api facebookLink;
    @api twitterLink;
    @api linkedinLink;
    @api instagramLink;
    @api youtubeLink;
    @api imprintLink;
    @api PrivacyPolicyLink;
    year = (new Date()).getFullYear();
    OMVLogoUrl = OMV_LOGO;
}