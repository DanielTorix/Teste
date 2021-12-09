import { LightningElement, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import bannercss from '@salesforce/resourceUrl/bannercss';
import bannerjs from '@salesforce/resourceUrl/bannerjs';

export default class CommunityCookieBanner extends LightningElement {
    renderedCallback() {
        console.log('Rendered START');

/*
(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-NMWRQSK');
*/

        Promise.all(
            [
                loadStyle(this, bannercss),
                loadScript(this, bannerjs)
            ]
        ).then(
            () => {
                console.log('promise success');

                window.cookieconsent.initialise(dr_cookiebanner_options);

                console.log('after cookieconsent init');
            }
        ).catch(
            error => {
                console.log('promise error: ' + error);
                console.log('promise error stacktrace: ' + error.stack);
            }
        );

        console.log('Rendered END');
    }
}