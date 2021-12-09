
if (dr_generated_banner) {
  throw new Error("Cookie banner integration was included more than once!");
}



(function(cc) {

  // stop from running again, if accidently included more than once.
  if (cc.hasInitialised) return;

  var util = {
    // https://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex
    escapeRegExp: function(str) {
      return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');
    },

    hasClass: function(element, selector) {
      var s = ' ';
      return (
        element.nodeType === 1 &&
        (s + element.className + s)
          .replace(/[\n\t]/g, s)
          .indexOf(s + selector + s) >= 0
      );
    },

    addClass: function(element, className) {
      element.className += ' ' + className;
    },

    removeClass: function(element, className) {
      var regex = new RegExp('\\b' + this.escapeRegExp(className) + '\\b');
      element.className = element.className.replace(regex, '');
    },

    interpolateString: function(str, callback) {
      var marker = /{{([a-z][a-z0-9\-_]*)}}/gi;
      return str.replace(marker, function(matches) {
        return callback(arguments[1]) || '';
      });
    },

    getCookie: function(name) {

      if (dr_cookiebanner_options) {
        if (dr_cookiebanner_options.cookieLocalStorage === true) {
          return localStorage.getItem(name);
        }
      }

      var value = '; ' + document.cookie;
      var parts = value.split('; ' + name + '=');
      var result = parts.length < 2
        ? undefined
        : parts
          .pop()
          .split(';')
          .shift();

      if (dr_cookiebanner_options) {
        dr_cookiebanner_options.log("GetCookie " + name + "=" + result);
      }
      return result;
    },

    setCookie: function(name, value, expiryDays, domain, path, secure) {

      if (dr_cookiebanner_options) {
        if (dr_cookiebanner_options.cookieLocalStorage === true) {
          if (value == null || value === "") {
            localStorage.removeItem(name);
          } else {
            localStorage.setItem(name, value);
          }
          return;
        }
      }

      var exdate = new Date();
      exdate.setDate(exdate.getDate() + (expiryDays || 365));

      var cookie = [
        name + '=' + value,
        'expires=' + exdate.toUTCString(),
        'path=' + (path || '/')
      ];

      if (domain) {
        cookie.push('domain=' + domain);
      }
      /*
      if (secure) {
        cookie.push('secure');
      }*/
      if (location.protocol === 'https:') {
        cookie.push('secure');
        cookie.push('SameSite=none');
      }

      document.cookie = cookie.join(';');

      if (dr_cookiebanner_options) {
        dr_cookiebanner_options.logJson("SetCookie", cookie);
      }
    },

    // only used for extending the initial options
    deepExtend: function(target, source) {
      for (var prop in source) {
        if (source.hasOwnProperty(prop)) {
          if (
            prop in target &&
            this.isPlainObject(target[prop]) &&
            this.isPlainObject(source[prop])
          ) {
            this.deepExtend(target[prop], source[prop]);
          } else {
            target[prop] = source[prop];
          }
        }
      }
      return target;
    },

    // only used for throttling the 'mousemove' event (used for animating the revoke button when `animateRevokable` is true)
    throttle: function(callback, limit) {
      var wait = false;
      return function() {
        if (!wait) {
          callback.apply(this, arguments);
          wait = true;
          setTimeout(function() {
            wait = false;
          }, limit);
        }
      };
    },

    // only used for hashing json objects (used for hash mapping palette objects, used when custom colours are passed through JavaScript)
    hash: function(str) {
      var hash = 0,
        i,
        chr,
        len;
      if (str.length === 0) return hash;
      for (i = 0, len = str.length; i < len; ++i) {
        chr = str.charCodeAt(i);
        hash = (hash << 5) - hash + chr;
        hash |= 0;
      }
      return hash;
    },

    normaliseHex: function(hex) {
      if (hex[0] == '#') {
        hex = hex.substr(1);
      }
      if (hex.length == 3) {
        hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
      }
      return hex;
    },

    // used to get text colors if not set
    getContrast: function(hex) {
      hex = this.normaliseHex(hex);
      var r = parseInt(hex.substr(0, 2), 16);
      var g = parseInt(hex.substr(2, 2), 16);
      var b = parseInt(hex.substr(4, 2), 16);
      var yiq = (r * 299 + g * 587 + b * 114) / 1000;
      return yiq >= 128 ? '#000' : '#fff';
    },

    // used to change color on highlight
    getLuminance: function(hex) {
      var num = parseInt(this.normaliseHex(hex), 16),
        amt = 38,
        R = (num >> 16) + amt,
        B = ((num >> 8) & 0x00ff) + amt,
        G = (num & 0x0000ff) + amt;
      var newColour = (
        0x1000000 +
        (R < 255 ? (R < 1 ? 0 : R) : 255) * 0x10000 +
        (B < 255 ? (B < 1 ? 0 : B) : 255) * 0x100 +
        (G < 255 ? (G < 1 ? 0 : G) : 255)
      )
        .toString(16)
        .slice(1);
      return '#' + newColour;
    },

    isMobile: function() {
      return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
        navigator.userAgent
      );
    },

    isPlainObject: function(obj) {
      // The code "typeof obj === 'object' && obj !== null" allows Array objects
      return (
        typeof obj === 'object' && obj !== null && obj.constructor == Object
      );
    },

    traverseDOMPath: function(elem, className) {
      if (!elem || !elem.parentNode) return null;
      if (util.hasClass(elem, className)) return elem;

      return this.traverseDOMPath(elem.parentNode, className);
    }
  };

  // valid cookie values
  cc.status = {
    deny: 'deny',
    allow: 'allow',
    dismiss: 'dismiss'
  };

  // detects the `transitionend` event name
  cc.transitionEnd = (function() {
    var el = document.createElement('div');
    var trans = {
      t: 'transitionend',
      OT: 'oTransitionEnd',
      msT: 'MSTransitionEnd',
      MozT: 'transitionend',
      WebkitT: 'webkitTransitionEnd'
    };

    for (var prefix in trans) {
      if (
        trans.hasOwnProperty(prefix) &&
        typeof el.style[prefix + 'ransition'] != 'undefined'
      ) {
        return trans[prefix];
      }
    }
    return '';
  })();

  cc.hasTransition = !!cc.transitionEnd;

  // array of valid regexp escaped statuses
  var __allowedStatuses = Object.keys(cc.status).map(util.escapeRegExp);

  // contains references to the custom <style> tags
  cc.customStyles = {};

  cc.Popup = (function() {
    var defaultOptions = {
      // if false, this prevents the popup from showing (useful for giving to control to another piece of code)
      enabled: true,

      // optional (expecting a HTML element) if passed, the popup is appended to this element. default is `document.body`
      container: null,

      // defaults cookie options - it is RECOMMENDED to set these values to correspond with your server
      cookie: {
        // This is the name of this cookie - you can ignore this
        name: 'cookieconsent_status',

        // This is the url path that the cookie 'name' belongs to. The cookie can only be read at this location
        path: '/',

        // This is the domain that the cookie 'name' belongs to. The cookie can only be read on this domain.
        //  - Guide to cookie domains - https://www.mxsasha.eu/blog/2014/03/04/definitive-guide-to-cookie-domains/
        domain: '',

        // The cookies expire date, specified in days (specify -1 for no expiry)
        expiryDays: 365,

        // If true the cookie will be created with the secure flag. Secure cookies will only be transmitted via HTTPS.
        secure: false
      },

      // these callback hooks are called at certain points in the program execution
      onPopupOpen: function() {},
      onPopupClose: function() {},
      onInitialise: function(status) {},
      onStatusChange: function(status, chosenBefore) {},
      onRevokeChoice: function() {},
      onNoCookieLaw: function(countryCode, country) {},

      // each item defines the inner text for the element that it references
      content: {
        header: 'Cookies used on the website!',
        message:
          'This website uses cookies to ensure you get the best experience on our website.',
        dismiss: 'Got it!',
        allow: 'Allow cookies',
        deny: 'Decline',
        link: 'Learn more',
        href: 'https://cookiesandyou.com',
        close: '&#x274c;',
        target: '_blank',
        policy: 'Cookie Policy',
        mobilePolicy: "Mobile",
      },

      // This is the HTML for the elements above. The string {{header}} will be replaced with the equivalent text below.
      // You can remove "{{header}}" and write the content directly inside the HTML if you want.
      //
      //  - ARIA rules suggest to ensure controls are tabbable (so the browser can find the first control),
      //    and to set the focus to the first interactive control (https://w3c.github.io/using-aria/)
      elements: {
        header: '<span class="cc-header">{{header}}</span>&nbsp;',
        message:
          '<span id="cookieconsent:desc" class="cc-message">{{message}}</span>',
        messagelink:
          '<span id="cookieconsent:desc" class="cc-message">{{message}} <a aria-label="learn more about cookies" role=button tabindex="0" class="cc-link" href="{{href}}" rel="noopener noreferrer nofollow" target="{{target}}">{{link}}</a></span>',
        dismiss:
          '<a aria-label="dismiss cookie message" role=button tabindex="0" class="cc-btn cc-dismiss">{{dismiss}}</a>',
        allow:
          '<a aria-label="allow cookies" role=button tabindex="0"  class="cc-btn cc-allow">{{allow}}</a>',
        deny:
          '<a aria-label="deny cookies" role=button tabindex="0" class="cc-btn cc-deny">{{deny}}</a>',
        link:
          '<a aria-label="learn more about cookies" role=button tabindex="0" class="cc-link" href="{{href}}" rel="noopener noreferrer nofollow" target="{{target}}">{{link}}</a>',
        close:
          '<span aria-label="dismiss cookie message" role=button tabindex="0" class="cc-close">{{close}}</span>'

        //compliance: compliance is also an element, but it is generated by the application, depending on `type` below
      },

      // The placeholders {{classes}} and {{children}} both get replaced during initialisation:
      //  - {{classes}} is where additional classes get added
      //  - {{children}} is where the HTML children are placed
      window:
        '<div role="dialog" aria-live="polite" aria-label="cookieconsent" aria-describedby="cookieconsent:desc" class="cc-window {{classes}}"><!--googleoff: all-->{{children}}<!--googleon: all--></div>',

      // This is the html for the revoke button. This only shows up after the user has selected their level of consent
      // It can be enabled of disabled using the `revokable` option
      revokeBtn: '<div class="cc-revoke {{classes}}">{{policy}}</div>',

      // define types of 'compliance' here. '{{value}}' strings in here are linked to `elements`
      compliance: {
        info: '<div class="cc-compliance">{{dismiss}}</div>',
        'opt-in':
          '<div class="cc-compliance cc-highlight">{{deny}}{{allow}}</div>',
        'opt-out':
          '<div class="cc-compliance cc-highlight">{{deny}}{{allow}}</div>'
      },

      // select your type of popup here
      type: 'info', // refers to `compliance` (in other words, the buttons that are displayed)

      // define layout layouts here
      layouts: {
        // the 'block' layout tend to be for square floating popups
        basic: '{{messagelink}}{{compliance}}',
        'basic-close': '{{messagelink}}{{compliance}}{{close}}',
        'basic-header': '{{header}}{{message}}{{link}}{{compliance}}'

        // add a custom layout here, then add some new css with the class '.cc-layout-my-cool-layout'
        //'my-cool-layout': '<div class="my-special-layout">{{message}}{{compliance}}</div>{{close}}',
      },

      // default layout (see above)
      layout: 'basic',

      // this refers to the popup windows position. we currently support:
      //  - banner positions: top, bottom
      //  - floating positions: top-left, top-right, bottom-left, bottom-right
      //
      // adds a class `cc-floating` or `cc-banner` which helps when styling
      position: 'bottom', // default position is 'bottom'

      policyPosition: 'bottom', // MIKE: default popup policy position

      // Available styles
      //    -block (default, no extra classes)
      //    -edgeless
      //    -classic
      // use your own style name and use `.cc-theme-STYLENAME` class in CSS to edit.
      // Note: style "wire" is used for the configurator, but has no CSS styles of its own, only palette is used.
      theme: 'block',

      // The popup is `fixed` by default, but if you want it to be static (inline with the page content), set this to false
      // Note: by default, we animate the height of the popup from 0 to full size
      static: false,

      // if you want custom colours, pass them in here. this object should look like this.
      // ideally, any custom colours/themes should be created in a separate style sheet, as this is more efficient.
      //   {
      //     popup: {background: '#000000', text: '#fff', link: '#fff'},
      //     button: {background: 'transparent', border: '#f8e71c', text: '#f8e71c'},
      //     highlight: {background: '#f8e71c', border: '#f8e71c', text: '#000000'},
      //   }
      // `highlight` is optional and extends `button`. if it exists, it will apply to the first button
      // only background needs to be defined for every element. if not set, other colors can be calculated from it
      palette: null,

      // Some countries REQUIRE that a user can change their mind. You can configure this yourself.
      // Most of the time this should be false, but the `cookieconsent.law` can change this to `true` if it detects that it should
      revokable: false,

      // if true, the revokable button will tranlate in and out
      animateRevokable: true,

      // used to disable link on existing layouts
      // replaces element messagelink with message and removes content of link
      showLink: true,

      // set value as scroll range to enable
      dismissOnScroll: false,

      // set value as time in milliseconds to autodismiss after set time
      dismissOnTimeout: false,

      // set value as click anything on the page, excluding the `ignoreClicksFrom` below (if we click on the revoke button etc)
      dismissOnWindowClick: false,

      // If `dismissOnWindowClick` is true, we can click on 'revoke' and we'll still dismiss the banner, so we need exceptions.
      // should be an array of class names (not CSS selectors)
      ignoreClicksFrom: ['cc-revoke', 'cc-btn'], // already includes the revoke button and the banner itself

      // The application automatically decide whether the popup should open.
      // Set this to false to prevent this from happening and to allow you to control the behaviour yourself
      autoOpen: true,

      // By default the created HTML is automatically appended to the container (which defaults to <body>). You can prevent this behaviour
      // by setting this to false, but if you do, you must attach the `element` yourself, which is a public property of the popup instance:
      //
      //     var instance = cookieconsent.factory(options);
      //     document.body.appendChild(instance.element);
      //
      autoAttach: true,

      // simple whitelist/blacklist for pages. specify page by:
      //   - using a string : '/index.html'           (matches '/index.html' exactly) OR
      //   - using RegExp   : /\/page_[\d]+\.html/    (matched '/page_1.html' and '/page_2.html' etc)
      whitelistPage: [],
      blacklistPage: [],

      // If this is defined, then it is used as the inner html instead of layout. This allows for ultimate customisation.
      // Be sure to use the classes `cc-btn` and `cc-allow`, `cc-deny` or `cc-dismiss`. They enable the app to register click
      // handlers. You can use other pre-existing classes too. See `src/styles` folder.
      overrideHTML: null
    };

    function CookiePopup() {
      this.initialise.apply(this, arguments);
    }

    CookiePopup.prototype.initialise = function(options) {

      if (this.options) {
        this.destroy(); // already rendered
      }
      // ---- START MIKE: change in original code to prevent opening twice ----
      if (options._optionsWereUsed == true) {
        this.destroy(); // already rendered
        return;
      } else {
        options._optionsWereUsed = true;
      }
      // ---- END MIKE

      window.dr_isInitialized = false;

      // set options back to default options
      util.deepExtend((this.options = {}), defaultOptions);

      // merge in user options
      if (util.isPlainObject(options)) {
        util.deepExtend(this.options, options);
      }

      // configure debug logging py parameter
      if (this.options.configureDebugLogOutput) {
        this.options.configureDebugLogOutput();
      }

      if (this.options.dr_autoAcceptCookies) {
        if (this.options.dr_autoAcceptCookies == "allow") {
          window.CookiesOK = true;
        } else if (this.options.dr_autoAcceptCookies == "deny") {
          window.CookiesDeny = true;
        }
      }

      // check for bots, autoAllow if it is a bot (as there are no humans involved)
      var botPattern = "(googlebot\/|bot|Googlebot-Mobile|Googlebot-Image|Google favicon|Mediapartners-Google|bingbot|msnbot|teoma|ia_archiver|GingerCrawler|webcrawler|grub.org|UsineNouvelleCrawler|antibot|netresearchserver|speedy|fluffy|bibnum.bnf|findlink|msrbot|panscient|yacybot|AISearchBot|IOI|ips-agent|tagoobot|MJ12bot|dotbot|woriobot|yanga|buzzbot|mlbot|yandexbot|purebot|Linguee Bot|Voyager|CyberPatrol|voilabot|baiduspider|citeseerxbot|spbot|twengabot|postrank|turnitinbot|scribdbot|page2rss|sitebot|linkdex|Adidxbot|blekkobot|ezooms|dotbot|Mail.RU_Bot|discobot|heritrix|findthatfile|europarchive.org|NerdByNature.Bot|sistrix crawler|ahrefsbot|Aboundex|domaincrawler|wbsearchbot|summify|ccbot|edisterbot|seznambot|ec2linkfinder|gslfbot|aihitbot|intelium_bot|facebookexternalhit|yeti|RetrevoPageAnalyzer|lb-spider|sogou|lssbot|careerbot|wotbox|wocbot|ichiro|DuckDuckBot|lssrocketcrawler|drupact|webcompanycrawler|acoonbot|openindexspider|gnam gnam spider|web-archive-net.com.bot|backlinkcrawler|coccoc|integromedb|content crawler spider|toplistbot|seokicks-robot|it2media-domain-crawler|ip-web-crawler.com|siteexplorer.info|elisabot|proximic|changedetection|blexbot|arabot|WeSEE:Search|niki-bot|CrystalSemanticsBot|rogerbot|360Spider|psbot|InterfaxScanBot|Lipperhey SEO Service|CC Metadata Scaper|g00g1e.net|GrapeshotCrawler|urlappendbot|brainobot|fr-crawler|binlar|SimpleCrawler|Livelapbot|Twitterbot|cXensebot|smtbot|bnf.fr_bot|A6-Indexer|ADmantX|Facebot|Twitterbot|OrangeBot|memorybot|AdvBot|MegaIndex|SemanticScholarBot|ltx71|nerdybot|xovibot|BUbiNG|Qwantify|archive.org_bot|Applebot|TweetmemeBot|crawler4j|findxbot|SemrushBot|yoozBot|lipperhey|y!j-asr|Domain Re-Animator Bot|AddThis)";
      var re = new RegExp(botPattern, 'i');
      var userAgent = navigator.userAgent;
      var userAgentIsBot = false;
      if (re.test(userAgent)) {
        // the user agent is a crawler bot
        window.CookiesOK = true;
        userAgentIsBot = true;
      }

      if (webcareCmp) {
        webcareCmp.initConsent();
      }


      this.options.cookie.name = this.options.cookieConsentName;

      if (!this.hasConsented()) {
        // check for url parameters
        var pconsent = this.options.dr_getConsentFromUrlParameter();
        if (pconsent) {
          if (pconsent.drAllow) {
            this.setStatus("allow");
            dr_cookiebanner_options.dr_acceptedCategories = ["statistic", "marketing", "unclassified"];
          } else {
            this.setStatus("deny");
            dr_cookiebanner_options.dr_acceptedCategories = [];
            if (pconsent.statistic === true) {
              dr_cookiebanner_options.dr_acceptedCategories.push("statistic");
            }
            if (pconsent.marketing === true) {
              dr_cookiebanner_options.dr_acceptedCategories.push("marketing");
            }
            if (pconsent.unknown === true) {
              dr_cookiebanner_options.dr_acceptedCategories.push("unclassified");
            }
          }

          var c = this.options.cookie;
          if (c) {
            util.setCookie(
              this.options.cookieConsentModeName,
              JSON.stringify(dr_cookiebanner_options.dr_acceptedCategories),
              c.expiryDays,
              c.domain,
              c.path,
              c.secure
            );
          }
        }
      }

      // returns true if `onComplete` was called
      if (checkCallbackHooks.call(this)) {
        // user has already answered
        this.options.enabled = false;
      }

      // apply blacklist / whitelist
      if (arrayContainsMatches(this.options.blacklistPage, location.pathname)) {
        this.options.enabled = false;
      }
      if (arrayContainsMatches(this.options.whitelistPage, location.pathname)) {
        this.options.enabled = true;
      }

      // the full markup either contains the wrapper or it does not (for multiple instances)
      var cookiePopup = this.options.window
        .replace('{{classes}}', getPopupClasses.call(this).join(' '))
        .replace('{{children}}', getPopupInnerMarkup.call(this));

      // if user passes html, use it instead
      var customHTML = this.options.overrideHTML;
      if (typeof customHTML == 'string' && customHTML.length) {
        cookiePopup = customHTML;
      }

      if (userAgentIsBot != true) {
        if (cookiePopup && cookiePopup.length > 5) {
          if (cookiePopup[0] == 'h' && cookiePopup[1] == 't' && cookiePopup[2] == 't' && cookiePopup[3] == 'p') {
            this.dynamicLoad(cookiePopup);
          } else {
            this.initialiseWaitForCSS(cookiePopup);
          }
        } else {
          this.initialiseWaitForCSS(null);
        }
      } else {
        console.log("WebCare deactivated for Crawlers and Bots")
      }
    }

    CookiePopup.prototype.dynamicLoad =  function (contentUrl) {
      console.debug("Dynamically load " + contentUrl);

      var caller = this;

      var xhr = new XMLHttpRequest();
      xhr.open('GET', contentUrl);
      xhr.timeout = 5000;
      xhr.send();
      xhr.onload = function() {
        var success = false;
        if (xhr.status == 200) {
          if (xhr.response && xhr.response.length > 200) {
            success = true;
          }
        }

        if (success) {
          caller.initialiseWaitForCSS(xhr.response);
        } else {
          caller.initialiseWaitForCSS(null);
        }

      };

      xhr.onprogress = function(event) {
        /*
        if (event.lengthComputable) {
          console.log("Received + " + event.loaded + " of " + event.total +" bytes");
        } else {
          console.log("Received " + event.loaded + " bytes");
        }*/
      };

      xhr.onerror = function() {
        console.error("Could not load language version: " + contentUrl);
        caller.initialiseWaitForCSS(null);
      };

    }

    CookiePopup.prototype.initialiseWaitForCSS =  function (cookiePopup) {
      var caller = this;
      // TODO: check if css styles are loaded properly
      caller.initialise2(cookiePopup);
    }

    CookiePopup.prototype.initialise2 =  function (cookiePopup) {


      if (cookiePopup == null || cookiePopup.length < 200) {
        if (dr_generated_banner["en"] && dr_generated_banner["en"].length > 200) {
          cookiePopup = dr_generated_banner["en"];
        } else if (dr_generated_banner["de"] && dr_generated_banner["de"].length > 200) {
          cookiePopup = dr_generated_banner["de"];
        } else {
          cookiePopup = dr_generated_banner[0];
        }
      }


      // if static, we need to grow the element from 0 height so it doesn't jump the page
      // content. we wrap an element around it which will mask the hidden content
      if (this.options.static) {
        // `grower` is a wrapper div with a hidden overflow whose height is animated
        var wrapper = appendMarkup.call(
          this,
          '<div class="cc-grower">' + cookiePopup + '</div>'
        );

        wrapper.style.display = ''; // set it to visible (because appendMarkup hides it)
        this.element = wrapper.firstChild; // get the `element` reference from the wrapper
        this.element.style.display = 'none';
        util.addClass(this.element, 'cc-invisible');
      } else {
        this.element = appendMarkup.call(this, cookiePopup);
      }

      // add custom logo if defined
      if (this.options.insertTopLogo != null && this.options.insertTopLogo.length > 0) {
        var insElm = document.getElementById("dr-insert-content");
        if (insElm) {
          insElm.innerHTML = this.options.insertTopLogo;
          util.removeClass(insElm, "dr-invisible-element");
        }

        insElm = document.getElementById("dr-pre-insert-content");
        if (insElm) {
          insElm.innerHTML = this.options.insertTopLogo;
          util.removeClass(insElm, "dr-invisible-element");
        }
      }

      this.options.dr_generateCountrySelectOptions();

      applyAutoDismiss.call(this);


      if (this.options.cookieDomain) {
        if (this.options.cookieDomain.length > 0) {
          this.options.cookie.domain = this.options.cookieDomain;
        }
      }

      if (this.options.cookieConsentName) {
        if (this.options.cookieConsentName.length > 0) {
          this.options.cookie.name = this.options.cookieConsentName;
        }
      }

      applyRevokeButton.call(this);

      window.dr_isInitialized = true;

      if (this.options.autoOpen) {
        this.autoOpen();
      }
    };

    CookiePopup.prototype.destroy = function() {
      if (this.onButtonClick && this.element) {
        this.element.removeEventListener('click', this.onButtonClick);
        this.onButtonClick = null;
      }

      if (this.dismissTimeout) {
        clearTimeout(this.dismissTimeout);
        this.dismissTimeout = null;
      }

      if (this.onWindowScroll) {
        window.removeEventListener('scroll', this.onWindowScroll);
        this.onWindowScroll = null;
      }

      if (this.onWindowClick) {
        window.removeEventListener('click', this.onWindowClick);
        this.onWindowClick = null;
      }

      if (this.onMouseMove) {
        window.removeEventListener('mousemove', this.onMouseMove);
        this.onMouseMove = null;
      }

      if (this.element && this.element.parentNode) {
        this.element.parentNode.removeChild(this.element);
      }
      this.element = null;

      if (this.revokeBtn && this.revokeBtn.parentNode) {
        this.revokeBtn.parentNode.removeChild(this.revokeBtn);
      }
      this.revokeBtn = null;

      removeCustomStyle(this.options.palette);
      this.options = null;
    };

    CookiePopup.prototype.open = function(callback) {
      if (!this.element) return;

      if (!this.isOpen()) {
        if (cc.hasTransition) {
          this.fadeIn();
        } else {
          this.element.style.display = '';
        }

        if (this.options.revokable) {
          this.toggleRevokeButton();
        }
        this.options.onPopupOpen.call(this);
      }

      return this;
    };

    CookiePopup.prototype.close = function(showRevoke) {
      if (!this.element) return;

      if (this.isOpen()) {
        if (cc.hasTransition) {
          this.fadeOut();
        } else {
          this.element.style.display = 'none';
        }

        if (showRevoke && this.options.revokable) {
          this.toggleRevokeButton(true);
        }

        // execute tags with close activation mode
        this.options.dr_activateTags(this.options.dr_hasConsent("statistic"), this.options.dr_hasConsent("marketing"), true);

        this.options.onPopupClose.call(this);
      }

      // do redirect after consent decision
      if (dr_cookiebanner_options.onRedirectAfterConsent) {
        // call event callback instead of redirecting
        if (window.dr_redirectAfterConsentOption) {

          var c = dr_cookiebanner_options.dr_getConsentFromBanner(this.getStatus(), dr_cookiebanner_options.dr_acceptedCategories);
          parameters = dr_cookiebanner_options.dr_addConsentParameterToUrl(" ", c).substring(2);

          var o = {
            key: window.dr_redirectAfterConsentOption.key,
            description: window.dr_redirectAfterConsentOption.description,
            redirect: window.dr_redirectAfterConsentOption.redirect,
            consent: parameters
          }

          setTimeout(function () {
            dr_cookiebanner_options.onRedirectAfterConsent(o);
          }, 100);

        }
      } else {
       if (window.dr_redirectAfterConsent) {
          var redirectUrl = window.dr_redirectAfterConsent;

          var c = dr_cookiebanner_options.dr_getConsentFromBanner(this.getStatus(), dr_cookiebanner_options.dr_acceptedCategories);
          redirectUrl = dr_cookiebanner_options.dr_addConsentParameterToUrl(redirectUrl, c);

          setTimeout(function () {
            location.href = redirectUrl;
          }, 100);
        }
      }

      return this;
    };

    CookiePopup.prototype.fadeIn = function() {
      var el = this.element;

      if (!cc.hasTransition || !el) return;

      // This should always be called AFTER fadeOut (which is governed by the 'transitionend' event).
      // 'transitionend' isn't all that reliable, so, if we try and fadeIn before 'transitionend' has
      // has a chance to run, then we run it ourselves
      if (this.afterTransition) {
        afterFadeOut.call(this, el);
      }

      if (util.hasClass(el, 'cc-invisible')) {
        el.style.display = '';

        if (this.options.static) {
          var height = this.element.clientHeight;
          this.element.parentNode.style.maxHeight = height + 'px';
        }

        var fadeInTimeout = 20; // (ms) DO NOT MAKE THIS VALUE SMALLER. See below

        // Although most browsers can handle values less than 20ms, it should remain above this value.
        // This is because we are waiting for a "browser redraw" before we remove the 'cc-invisible' class.
        // If the class is remvoed before a redraw could happen, then the fadeIn effect WILL NOT work, and
        // the popup will appear from nothing. Therefore we MUST allow enough time for the browser to do
        // its thing. The actually difference between using 0 and 20 in a set timeout is neglegible anyway
        this.openingTimeout = setTimeout(
          afterFadeIn.bind(this, el),
          fadeInTimeout
        );
      }
    };

    CookiePopup.prototype.fadeOut = function() {
      var el = this.element;

      if (!cc.hasTransition || !el) return;

      if (this.openingTimeout) {
        clearTimeout(this.openingTimeout);
        afterFadeIn.bind(this, el);
      }

      if (!util.hasClass(el, 'cc-invisible')) {
        if (this.options.static) {
          this.element.parentNode.style.maxHeight = '';
        }

        this.afterTransition = afterFadeOut.bind(this, el);
        el.addEventListener(cc.transitionEnd, this.afterTransition);

        util.addClass(el, 'cc-invisible');
      }
    };

    CookiePopup.prototype.isOpen = function() {
      return (
        this.element &&
        this.element.style.display == '' &&
        (cc.hasTransition ? !util.hasClass(this.element, 'cc-invisible') : true)
      );
    };

    CookiePopup.prototype.toggleRevokeButton = function(show) {

      if (this.options.dr_button_policy_hide) {
        if (this.options.dr_button_policy_hide == "true") {
          show = false;
        }
      }

      if (this.revokeBtn) this.revokeBtn.style.display = show ? '' : 'none';
    };

    CookiePopup.prototype.revokeChoice = function(preventOpen) {
      this.options.enabled = true;
      this.clearStatus();

      this.options.onRevokeChoice.call(this);

      if (!preventOpen) {
        this.autoOpen();
      }
    };

    // returns true if the cookie has a valid value
    CookiePopup.prototype.hasAnswered = function(options) {
      return Object.keys(cc.status).indexOf(this.getStatus()) >= 0;
    };

    // returns true if the cookie indicates that consent has been given
    CookiePopup.prototype.hasConsented = function(options) {
      if (window.CookiesOK) {
        return true;
      }

      if (window.CookiesDeny) {
        return false;
      }
      var val = this.getStatus();
      return val == cc.status.allow || val == cc.status.dismiss;
    };

    // opens the popup if no answer has been given
    CookiePopup.prototype.autoOpen = function(options) {
      if (!this.hasAnswered() && this.options.enabled) {
        this.open();
      } else if (this.hasAnswered() && this.options.revokable) {
        this.toggleRevokeButton(true);
      }
    };

    CookiePopup.prototype.setStatus = function(status) {
      var c = this.options.cookie;
      var value = util.getCookie(c.name);
      var chosenBefore = Object.keys(cc.status).indexOf(value) >= 0;

      // if `status` is valid
      if (Object.keys(cc.status).indexOf(status) >= 0) {
        util.setCookie(
          c.name,
          status,
          c.expiryDays,
          c.domain,
          c.path,
          c.secure
        );

        this.options.onStatusChange.call(this, status, chosenBefore);
      } else {
        this.clearStatus();
      }
    };

    CookiePopup.prototype.getStatus = function() {
      return util.getCookie(this.options.cookie.name);
    };

    CookiePopup.prototype.clearStatus = function() {
      var c = this.options.cookie;
      util.setCookie(c.name, '', -1, c.domain, c.path);
    };

    // This needs to be called after 'fadeIn'. This is the code that actually causes the fadeIn to work
    // There is a good reason why it's called in a timeout. Read 'fadeIn';
    function afterFadeIn(el) {
      this.openingTimeout = null;
      util.removeClass(el, 'cc-invisible');
    }

    // This is called on 'transitionend' (only on the transition of the fadeOut). That's because after we've faded out, we need to
    // set the display to 'none' (so there aren't annoying invisible popups all over the page). If for whenever reason this function
    // is not called (lack of support), the open/close mechanism will still work.
    function afterFadeOut(el) {
      el.style.display = 'none'; // after close and before open, the display should be none
      el.removeEventListener(cc.transitionEnd, this.afterTransition);
      this.afterTransition = null;
    }

    // this function calls the `onComplete` hook and returns true (if needed) and returns false otherwise
    function checkCallbackHooks() {
      var complete = this.options.onInitialise.bind(this);

      if (!window.navigator.cookieEnabled) {
        complete(cc.status.deny);
        return true;
      }

      if (window.CookiesOK || window.navigator.CookiesOK) {
        complete(cc.status.allow);
        return true;
      }

      if (window.CookiesDeny || window.navigator.CookiesDeny) {
        complete(cc.status.deny);
        return true;
      }

      var allowed = Object.keys(cc.status);
      var answer = this.getStatus();
      var match = allowed.indexOf(answer) >= 0;

      if (match) {
        complete(answer);
      }
      return match;
    }

    function getPositionClasses() {
      var positions = this.options.position.split('-'); // top, bottom, left, right
      var classes = [];

      // top, left, right, bottom
      positions.forEach(function(cur) {
        classes.push('cc-' + cur);
      });

      return classes;
    }


    function getPopupClasses() {
      var opts = this.options;
      var positionStyle =
        opts.position == 'top' || opts.position == 'bottom'
          ? 'banner'
          : 'floating';

      if (util.isMobile()) {
        positionStyle = 'floating';
      }

      var classes = [
        'cc-' + positionStyle, // floating or banner
        'cc-type-' + opts.type, // add the compliance type
        'cc-theme-' + opts.theme // add the theme
      ];

      if (opts.static) {
        classes.push('cc-static');
      }

      classes.push.apply(classes, getPositionClasses.call(this));

      // we only add extra styles if `palette` has been set to a valid value
      var didAttach = attachCustomPalette.call(this, this.options.palette);

      // if we override the palette, add the class that enables this
      if (this.customStyleSelector) {
        classes.push(this.customStyleSelector);
      }

      return classes;
    }

    function getPopupInnerMarkup() {
      var interpolated = {};
      var opts = this.options;

      // removes link if showLink is false
      if (!opts.showLink) {
        opts.elements.link = '';
        opts.elements.messagelink = opts.elements.message;
      }

      Object.keys(opts.elements).forEach(function(prop) {
        interpolated[prop] = util.interpolateString(
          opts.elements[prop],
          function(name) {
            var str = opts.content[name];
            return name && typeof str == 'string' && str.length ? str : '';
          }
        );
      });

      // checks if the type is valid and defaults to info if it's not
      var complianceType = opts.compliance[opts.type];
      if (!complianceType) {
        complianceType = opts.compliance.info;
      }

      // build the compliance types from the already interpolated `elements`
      interpolated.compliance = util.interpolateString(complianceType, function(
        name
      ) {
        return interpolated[name];
      });

      // checks if the layout is valid and defaults to basic if it's not
      var layout = opts.layouts[opts.layout];
      if (!layout) {
        layout = opts.layouts.basic;
      }

      return util.interpolateString(layout, function(match) {
        return interpolated[match];
      });
    }

    function appendMarkup(markup) {
      var opts = this.options;
      var div = document.createElement('div');
      var cont =
        opts.container && opts.container.nodeType === 1
          ? opts.container
          : document.body;

      if (cont) {
        // all OK
      } else {
        console.error("WebCare Integration Error: Please make sure to place the Cookie Banner Code in the BODY section of the page.")
      }

      div.innerHTML = markup;

      var el = div.children[0];

      el.style.display = 'none';

      if (util.hasClass(el, 'cc-window') && cc.hasTransition) {
        util.addClass(el, 'cc-invisible');
      }

      // save ref to the function handle so we can unbind it later
      this.onButtonClick = handleButtonClick.bind(this);

      el.addEventListener('click', this.onButtonClick);

      if (opts.autoAttach) {
        if (!cont.firstChild) {
          cont.appendChild(el);
        } else {
          cont.insertBefore(el, cont.firstChild);
        }
      }

      return el;
    }

    function handleButtonClick(event) {
      // returns the parent element with the specified class, or the original element - null if not found
      var btn = util.traverseDOMPath(event.target, 'cc-btn') || event.target;

      if (util.hasClass(btn, 'cc-btn')) {
        var matches = btn.className.match(
          new RegExp('\\bcc-(' + __allowedStatuses.join('|') + ')\\b')
        );
        var match = (matches && matches[1]) || false;

        if (match) {
          this.setStatus(match);
          this.close(true);
        }
      }
      if (util.hasClass(btn, 'cc-close')) {
        this.setStatus(cc.status.dismiss);
        this.close(true);
      }
      if (util.hasClass(btn, 'cc-revoke')) {
        this.revokeChoice();
      }
    }

    // I might change this function to use inline styles. I originally chose a stylesheet because I could select many elements with a
    // single rule (something that happened a lot), the apps has changed slightly now though, so inline styles might be more applicable.
    function attachCustomPalette(palette) {
      var hash = util.hash(JSON.stringify(palette));
      var selector = 'cc-color-override-' + hash;
      var isValid = util.isPlainObject(palette);

      this.customStyleSelector = isValid ? selector : null;

      if (isValid) {
        addCustomStyle(hash, palette, '.' + selector);
      }
      return isValid;
    }

    function addCustomStyle(hash, palette, prefix) {
      // only add this if a style like it doesn't exist
      if (cc.customStyles[hash]) {
        // custom style already exists, so increment the reference count
        ++cc.customStyles[hash].references;
        return;
      }

      var colorStyles = {};
      var popup = palette.popup;
      var button = palette.button;
      var highlight = palette.highlight;

      // needs background colour, text and link will be set to black/white if not specified
      if (popup) {
        // assumes popup.background is set
        popup.text = popup.text
          ? popup.text
          : util.getContrast(popup.background);
        popup.link = popup.link ? popup.link : popup.text;
        colorStyles[prefix + '.cc-window'] = [
          'color: ' + popup.text,
          'background-color: ' + popup.background
        ];
        colorStyles[prefix + '.cc-revoke'] = [
          'color: ' + popup.text,
          'background-color: ' + popup.background
        ];
        colorStyles[
          prefix +
            ' .cc-link,' +
            prefix +
            ' .cc-link:active,' +
            prefix +
            ' .cc-link:visited'
        ] = ['color: ' + popup.link];

        if (button) {
          // assumes button.background is set
          button.text = button.text
            ? button.text
            : util.getContrast(button.background);
          button.border = button.border ? button.border : 'transparent';
          colorStyles[prefix + ' .cc-btn'] = [
            'color: ' + button.text,
            'border-color: ' + button.border,
            'background-color: ' + button.background
          ];

          if (button.padding) {
            colorStyles[prefix + ' .cc-btn'].push('padding: ' + button.padding);
          }

          if (button.background != 'transparent') {
            colorStyles[
              prefix + ' .cc-btn:hover, ' + prefix + ' .cc-btn:focus'
            ] = [
              'background-color: ' +
                (button.hover || getHoverColour(button.background))
            ];
          }

          if (highlight) {
            //assumes highlight.background is set
            highlight.text = highlight.text
              ? highlight.text
              : util.getContrast(highlight.background);
            highlight.border = highlight.border
              ? highlight.border
              : 'transparent';
            colorStyles[prefix + ' .cc-highlight .cc-btn:first-child'] = [
              'color: ' + highlight.text,
              'border-color: ' + highlight.border,
              'background-color: ' + highlight.background
            ];
          } else {
            // sets highlight text color to popup text. background and border are transparent by default.
            colorStyles[prefix + ' .cc-highlight .cc-btn:first-child'] = [
              'color: ' + popup.text
            ];
          }
        }
      }

      // this will be interpretted as CSS. the key is the selector, and each array element is a rule
      var style = document.createElement('style');
      document.head.appendChild(style);

      // custom style doesn't exist, so we create it
      cc.customStyles[hash] = {
        references: 1,
        element: style.sheet
      };

      var ruleIndex = -1;
      for (var prop in colorStyles) {
        if (colorStyles.hasOwnProperty(prop)) {
          style.sheet.insertRule(
            prop + '{' + colorStyles[prop].join(';') + '}',
            ++ruleIndex
          );
        }
      }
    }

    function getHoverColour(hex) {
      hex = util.normaliseHex(hex);
      // for black buttons
      if (hex == '000000') {
        return '#222';
      }
      return util.getLuminance(hex);
    }

    function removeCustomStyle(palette) {
      if (util.isPlainObject(palette)) {
        var hash = util.hash(JSON.stringify(palette));
        var customStyle = cc.customStyles[hash];
        if (customStyle && !--customStyle.references) {
          var styleNode = customStyle.element.ownerNode;
          if (styleNode && styleNode.parentNode) {
            styleNode.parentNode.removeChild(styleNode);
          }
          cc.customStyles[hash] = null;
        }
      }
    }

    function arrayContainsMatches(array, search) {
      for (var i = 0, l = array.length; i < l; ++i) {
        var str = array[i];
        // if regex matches or string is equal, return true
        if (
          (str instanceof RegExp && str.test(search)) ||
          (typeof str == 'string' && str.length && str === search)
        ) {
          return true;
        }
      }
      return false;
    }

    function applyAutoDismiss() {
      var setStatus = this.setStatus.bind(this);
      var close = this.close.bind(this);

      var delay = this.options.dismissOnTimeout;
      if (typeof delay == 'number' && delay >= 0) {
        this.dismissTimeout = window.setTimeout(function() {
          setStatus(cc.status.dismiss);
          close(true);
        }, Math.floor(delay));
      }

      var scrollRange = this.options.dismissOnScroll;
      if (typeof scrollRange == 'number' && scrollRange >= 0) {
        var onWindowScroll = function(evt) {
          if (window.pageYOffset > Math.floor(scrollRange)) {
            setStatus(cc.status.dismiss);
            close(true);

            window.removeEventListener('scroll', onWindowScroll);
            this.onWindowScroll = null;
          }
        };

        if (this.options.enabled) {
          this.onWindowScroll = onWindowScroll;
          window.addEventListener('scroll', onWindowScroll);
        }
      }

      var windowClick = this.options.dismissOnWindowClick;
      var ignoredClicks = this.options.ignoreClicksFrom;
      if (windowClick) {
        var onWindowClick = function(evt) {
          var isIgnored = false;
          var pathLen = evt.path.length;
          var ignoredLen = ignoredClicks.length;
          for (var i = 0; i < pathLen; i++) {
            if (isIgnored) continue;

            for (var i2 = 0; i2 < ignoredLen; i2++) {
              if (isIgnored) continue;

              isIgnored = util.hasClass(evt.path[i], ignoredClicks[i2]);
            }
          }

          if (!isIgnored) {
            setStatus(cc.status.dismiss);
            close(true);

            window.removeEventListener('click', onWindowClick);
            this.onWindowClick = null;
          }
        }.bind(this);

        if (this.options.enabled) {
          this.onWindowClick = onWindowClick;
          window.addEventListener('click', onWindowClick);
        }
      }
    }

    function applyRevokeButton() {
      // revokable is true if advanced compliance is selected
      if (this.options.type != 'info') this.options.revokable = true;
      // animateRevokable false for mobile devices
      if (util.isMobile()) {
        this.options.animateRevokable = false;
      }

      if (this.options.revokable) {
        if (this.options.position == "middle") {
          var classes = [];
          if (this.options.policyPosition === "top") {
            classes.push("cc-top");
          } else {
            classes.push("cc-bottom");
          }
        } else {
          var classes = getPositionClasses.call(this);
        }

        if (util.isMobile()) {
          if (this.options.revokeOnMobile === false) {
            classes.push('cc-hide-revoke');
          }
        }

        if (this.options.animateRevokable) {
          classes.push('cc-animate');
        }
        if (this.customStyleSelector) {
          classes.push(this.customStyleSelector);
        }

        var usePolicy = this.options.content.policy;
        if (util.isMobile() && this.options.content.mobilePolicy) {
          usePolicy = this.options.content.mobilePolicy;
        }

        if (this.options.useRevokeCookieIcon === "true") {
          usePolicy = this.options.content.mobilePolicy;
        }

        var revokeBtn = this.options.revokeBtn
          .replace('{{classes}}', classes.join(' '))
          .replace('{{policy}}', usePolicy);


        this.revokeBtn = appendMarkup.call(this, revokeBtn);

        var btn = this.revokeBtn;
        if (this.options.animateRevokable) {
          var wait = false;
          var onMouseMove = util.throttle(function(evt) {
            var active = false;
            var minY = 20;
            var maxY = window.innerHeight - 20;

            if (util.hasClass(btn, 'cc-top') && evt.clientY < minY)
              active = true;
            if (util.hasClass(btn, 'cc-bottom') && evt.clientY > maxY)
              active = true;

            if (active) {
              if (!util.hasClass(btn, 'cc-active')) {
                util.addClass(btn, 'cc-active');
              }
            } else {
              if (util.hasClass(btn, 'cc-active')) {
                util.removeClass(btn, 'cc-active');
              }
            }
          }, 200);

          this.onMouseMove = onMouseMove;
          if (window.document.documentMode) {
            // IE of some version
            window.addEventListener('mousemove', onMouseMove);
          } else {
            window.addEventListener('mousemove', onMouseMove, {passive: true});
          }
        }
      }
    }

    return CookiePopup;
  })();

  cc.Location = (function() {
    // An object containing all the location services we have already set up.
    // When using a service, it could either return a data structure in plain text (like a JSON object) or an executable script
    // When the response needs to be executed by the browser, then `isScript` must be set to true, otherwise it won't work.

    // When the service uses a script, the chances are that you'll have to use the script to make additional requests. In these
    // cases, the services `callback` property is called with a `done` function. When performing async operations, this must be called
    // with the data (or Error), and `cookieconsent.locate` will take care of the rest
    var defaultOptions = {
      // The default timeout is 5 seconds. This is mainly needed to catch JSONP requests that error.
      // Otherwise there is no easy way to catch JSONP errors. That means that if a JSONP fails, the
      // app will take `timeout` milliseconds to react to a JSONP network error.
      timeout: 5000,

      // the order that services will be attempted in
      services: [
        'ipinfo'

        /*

        // 'ipinfodb' requires some options, so we define it using an object
        // this object will be passed to the function that defines the service

        {
          name: 'ipinfodb',
          interpolateUrl: {
            // obviously, this is a fake key
            api_key: 'vOgI3748dnIytIrsJcxS7qsDf6kbJkE9lN4yEDrXAqXcKUNvjjZPox3ekXqmMMld'
          },
        },

        // as well as defining an object, you can define a function that returns an object

        function () {
          return {name: 'ipinfodb'};
        },

        */
      ],

      serviceDefinitions: {
        ipinfo: function() {
          return {
            // This service responds with JSON, so we simply need to parse it and return the country code
            url: '//ipinfo.io',
            headers: ['Accept: application/json'],
            callback: function(done, response) {
              try {
                var json = JSON.parse(response);
                return json.error
                  ? toError(json)
                  : {
                      code: json.country
                    };
              } catch (err) {
                return toError({error: 'Invalid response (' + err + ')'});
              }
            }
          };
        },

        // This service requires an option to define `key`. Options are proived using objects or functions
        ipinfodb: function(options) {
          return {
            // This service responds with JSON, so we simply need to parse it and return the country code
            url:
              '//api.ipinfodb.com/v3/ip-country/?key={api_key}&format=json&callback={callback}',
            isScript: true, // this is JSONP, therefore we must set it to run as a script
            callback: function(done, response) {
              try {
                var json = JSON.parse(response);
                return json.statusCode == 'ERROR'
                  ? toError({error: json.statusMessage})
                  : {
                      code: json.countryCode
                    };
              } catch (err) {
                return toError({error: 'Invalid response (' + err + ')'});
              }
            }
          };
        },

        maxmind: function() {
          return {
            // This service responds with a JavaScript file which defines additional functionality. Once loaded, we must
            // make an additional AJAX call. Therefore we provide a `done` callback that can be called asynchronously
            url: '//js.maxmind.com/js/apis/geoip2/v2.1/geoip2.js',
            isScript: true, // this service responds with a JavaScript file, so it must be run as a script
            callback: function(done) {
              // if everything went okay then `geoip2` WILL be defined
              if (!window.geoip2) {
                done(
                  new Error(
                    'Unexpected response format. The downloaded script should have exported `geoip2` to the global scope'
                  )
                );
                return;
              }

              geoip2.country(
                function(location) {
                  try {
                    done({
                      code: location.country.iso_code
                    });
                  } catch (err) {
                    done(toError(err));
                  }
                },
                function(err) {
                  done(toError(err));
                }
              );

              // We can't return anything, because we need to wait for the second AJAX call to return.
              // Then we can 'complete' the service by passing data or an error to the `done` callback.
            }
          };
        }
      }
    };

    function Location(options) {
      // Set up options
      util.deepExtend((this.options = {}), defaultOptions);

      if (util.isPlainObject(options)) {
        util.deepExtend(this.options, options);
      }

      this.currentServiceIndex = -1; // the index (in options) of the service we're currently using
    }

    Location.prototype.getNextService = function() {
      var service;

      do {
        service = this.getServiceByIdx(++this.currentServiceIndex);
      } while (
        this.currentServiceIndex < this.options.services.length &&
        !service
      );

      return service;
    };

    Location.prototype.getServiceByIdx = function(idx) {
      // This can either be the name of a default locationService, or a function.
      var serviceOption = this.options.services[idx];

      // If it's a string, use one of the location services.
      if (typeof serviceOption === 'function') {
        var dynamicOpts = serviceOption();
        if (dynamicOpts.name) {
          util.deepExtend(
            dynamicOpts,
            this.options.serviceDefinitions[dynamicOpts.name](dynamicOpts)
          );
        }
        return dynamicOpts;
      }

      // If it's a string, use one of the location services.
      if (typeof serviceOption === 'string') {
        return this.options.serviceDefinitions[serviceOption]();
      }

      // If it's an object, assume {name: 'ipinfo', ...otherOptions}
      // Allows user to pass in API keys etc.
      if (util.isPlainObject(serviceOption)) {
        return this.options.serviceDefinitions[serviceOption.name](
          serviceOption
        );
      }

      return null;
    };

    // This runs the service located at index `currentServiceIndex`.
    // If the service fails, `runNextServiceOnError` will continue trying each service until all fail, or one completes successfully
    Location.prototype.locate = function(complete, error) {
      var service = this.getNextService();

      if (!service) {
        error(new Error('No services to run'));
        return;
      }

      this.callbackComplete = complete;
      this.callbackError = error;

      this.runService(service, this.runNextServiceOnError.bind(this));
    };

    // Potentially adds a callback to a url for jsonp.
    Location.prototype.setupUrl = function(service) {
      var serviceOpts = this.getCurrentServiceOpts();
      return service.url.replace(/\{(.*?)\}/g, function(_, param) {
        if (param === 'callback') {
          var tempName = 'callback' + Date.now();
          window[tempName] = function(res) {
            service.__JSONP_DATA = JSON.stringify(res);
          };
          return tempName;
        }
        if (param in serviceOpts.interpolateUrl) {
          return serviceOpts.interpolateUrl[param];
        }
      });
    };

    // requires a `service` object that defines at least a `url` and `callback`
    Location.prototype.runService = function(service, complete) {
      var self = this;

      // basic check to ensure it resembles a `service`
      if (!service || !service.url || !service.callback) {
        return;
      }

      // we call either `getScript` or `makeAsyncRequest` depending on the type of resource
      var requestFunction = service.isScript ? getScript : makeAsyncRequest;

      var url = this.setupUrl(service);

      // both functions have similar signatures so we can pass the same arguments to both
      requestFunction(
        url,
        function(xhr) {
          // if `!xhr`, then `getScript` function was used, so there is no response text
          var responseText = xhr ? xhr.responseText : '';

          // if the resource is a script, then this function is called after the script has been run.
          // if the script is JSONP, then a time defined function `callback_{Date.now}` has already
          // been called (as the JSONP callback). This callback sets the __JSONP_DATA property
          if (service.__JSONP_DATA) {
            responseText = service.__JSONP_DATA;
            delete service.__JSONP_DATA;
          }

          // call the service callback with the response text (so it can parse the response)
          self.runServiceCallback.call(self, complete, service, responseText);
        },
        this.options.timeout,
        service.data,
        service.headers
      );

      // `service.data` and `service.headers` are optional (they only count if `!service.isScript` anyway)
    };

    // The service request has run (and possibly has a `responseText`) [no `responseText` if `isScript`]
    // We need to run its callback which determines if its successful or not
    // `complete` is called on success or failure
    Location.prototype.runServiceCallback = function(
      complete,
      service,
      responseText
    ) {
      var self = this;
      // this is the function that is called if the service uses the async callback in its handler method
      var serviceResultHandler = function(asyncResult) {
        // if `result` is a valid value, then this function shouldn't really run
        // even if it is called by `service.callback`
        if (!result) {
          self.onServiceResult.call(self, complete, asyncResult);
        }
      };

      // the function `service.callback` will either extract a country code from `responseText` and return it (in `result`)
      // or (if it has to make additional requests) it will call a `done` callback with the country code when it is ready
      var result = service.callback(serviceResultHandler, responseText);

      if (result) {
        this.onServiceResult.call(this, complete, result);
      }
    };

    // This is called with the `result` from `service.callback` regardless of how it provided that result (sync or async).
    // `result` will be whatever is returned from `service.callback`. A service callback should provide an object with data
    Location.prototype.onServiceResult = function(complete, result) {
      // convert result to nodejs style async callback
      if (result instanceof Error || (result && result.error)) {
        complete.call(this, result, null);
      } else {
        complete.call(this, null, result);
      }
    };

    // if `err` is set, the next service handler is called
    // if `err` is null, the `onComplete` handler is called with `data`
    Location.prototype.runNextServiceOnError = function(err, data) {
      if (err) {
        this.logError(err);

        var nextService = this.getNextService();

        if (nextService) {
          this.runService(nextService, this.runNextServiceOnError.bind(this));
        } else {
          this.completeService.call(
            this,
            this.callbackError,
            new Error('All services failed')
          );
        }
      } else {
        this.completeService.call(this, this.callbackComplete, data);
      }
    };

    Location.prototype.getCurrentServiceOpts = function() {
      var val = this.options.services[this.currentServiceIndex];

      if (typeof val == 'string') {
        return {name: val};
      }

      if (typeof val == 'function') {
        return val();
      }

      if (util.isPlainObject(val)) {
        return val;
      }

      return {};
    };

    // calls the `onComplete` callback after resetting the `currentServiceIndex`
    Location.prototype.completeService = function(fn, data) {
      this.currentServiceIndex = -1;

      fn && fn(data);
    };

    Location.prototype.logError = function(err) {
      var idx = this.currentServiceIndex;
      var service = this.getServiceByIdx(idx);

      console.warn(
        'The service[' +
          idx +
          '] (' +
          service.url +
          ') responded with the following error',
        err
      );
    };

    function getScript(url, callback, timeout) {
      var timeoutIdx,
        s = document.createElement('script');

      s.type = 'text/' + (url.type || 'javascript');
      s.src = url.src || url;
      s.async = false;

      s.onreadystatechange = s.onload = function() {
        // this code handles two scenarios, whether called by onload or onreadystatechange
        var state = s.readyState;

        clearTimeout(timeoutIdx);

        if (!callback.done && (!state || /loaded|complete/.test(state))) {
          callback.done = true;
          callback();
          s.onreadystatechange = s.onload = null;
        }
      };

      document.body.appendChild(s);

      // You can't catch JSONP Errors, because it's handled by the script tag
      // one way is to use a timeout
      timeoutIdx = setTimeout(function() {
        callback.done = true;
        callback();
        s.onreadystatechange = s.onload = null;
      }, timeout);
    }

    function makeAsyncRequest(
      url,
      onComplete,
      timeout,
      postData,
      requestHeaders
    ) {
      var xhr = new (window.XMLHttpRequest || window.ActiveXObject)(
        'MSXML2.XMLHTTP.3.0'
      );

      xhr.open(postData ? 'POST' : 'GET', url, 1);

      xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

      if (Array.isArray(requestHeaders)) {
        for (var i = 0, l = requestHeaders.length; i < l; ++i) {
          var split = requestHeaders[i].split(':', 2);
          xhr.setRequestHeader(
            split[0].replace(/^\s+|\s+$/g, ''),
            split[1].replace(/^\s+|\s+$/g, '')
          );
        }
      }

      if (typeof onComplete == 'function') {
        xhr.onreadystatechange = function() {
          if (xhr.readyState > 3) {
            onComplete(xhr);
          }
        };
      }

      xhr.send(postData);
    }

    function toError(obj) {
      return new Error('Error [' + (obj.code || 'UNKNOWN') + ']: ' + obj.error);
    }

    return Location;
  })();

  cc.Law = (function() {
    var defaultOptions = {
      // Make this false if you want to disable all regional overrides for settings.
      // If true, options can differ by country, depending on their cookie law.
      // It does not affect hiding the popup for countries that do not have cookie law.
      regionalLaw: true,

      // countries that enforce some version of a cookie law
      hasLaw: [
        'AT',
        'BE',
        'BG',
        'HR',
        'CZ',
        'CY',
        'DK',
        'EE',
        'FI',
        'FR',
        'DE',
        'EL',
        'HU',
        'IE',
        'IT',
        'LV',
        'LT',
        'LU',
        'MT',
        'NL',
        'PL',
        'PT',
        'SK',
        'ES',
        'SE',
        'GB',
        'UK',
        'GR',
        'EU'
      ],

      // countries that say that all cookie consent choices must be revokable (a user must be able too change their mind)
      revokable: [
        'HR',
        'CY',
        'DK',
        'EE',
        'FR',
        'DE',
        'LV',
        'LT',
        'NL',
        'PT',
        'ES'
      ],

      // countries that say that a person can only "consent" if the explicitly click on "I agree".
      // in these countries, consent cannot be implied via a timeout or by scrolling down the page
      explicitAction: ['HR', 'IT', 'ES']
    };

    function Law(options) {
      this.initialise.apply(this, arguments);
    }

    Law.prototype.initialise = function(options) {
      // set options back to default options
      util.deepExtend((this.options = {}), defaultOptions);

      // merge in user options
      if (util.isPlainObject(options)) {
        util.deepExtend(this.options, options);
      }
    };

    Law.prototype.get = function(countryCode) {
      var opts = this.options;
      return {
        hasLaw: opts.hasLaw.indexOf(countryCode) >= 0,
        revokable: opts.revokable.indexOf(countryCode) >= 0,
        explicitAction: opts.explicitAction.indexOf(countryCode) >= 0
      };
    };

    Law.prototype.applyLaw = function(options, countryCode) {
      var country = this.get(countryCode);

      if (!country.hasLaw) {
        // The country has no cookie law
        options.enabled = false;
        if (typeof options.onNoCookieLaw === 'function') {
          options.onNoCookieLaw(countryCode, country);
        }
      }

      if (this.options.regionalLaw) {
        if (country.revokable) {
          // We must provide an option to revoke consent at a later time
          options.revokable = true;
        }

        if (country.explicitAction) {
          // The user must explicitly click the consent button
          options.dismissOnScroll = false;
          options.dismissOnTimeout = false;
        }
      }
      return options;
    };

    return Law;
  })();

  // This function initialises the app by combining the use of the Popup, Locator and Law modules
  // You can string together these three modules yourself however you want, by writing a new function.
  cc.initialise = function(options, complete, error) {
    var law = new cc.Law(options.law);

    if (!complete) complete = function() {};
    if (!error) error = function() {};

    // I hardcoded this because I cba to refactor a fuck load of code.
    // Bad developer. Bad.
    var allowed = Object.keys(cc.status);
    var answer = util.getCookie(options.cookieConsentName);
    var match = allowed.indexOf(answer) >= 0;

    // if they have already answered
    if (match) {
      complete(new cc.Popup(options));
      return;
    }

    cc.getCountryCode(
      options,
      function(result) {
        // don't need the law or location options anymore
        delete options.law;
        delete options.location;

        if (result.code) {
          options = law.applyLaw(options, result.code);
        }

        complete(new cc.Popup(options));
      },
      function(err) {
        // don't need the law or location options anymore
        delete options.law;
        delete options.location;

        error(err, new cc.Popup(options));
      }
    );
  };

  // This function tries to find your current location. It either grabs it from a hardcoded option in
  // `options.law.countryCode`, or attempts to make a location service request. This function accepts
  // options (which can configure the `law` and `location` modules) and fires a callback with which
  // passes an object `{code: countryCode}` as the first argument (which can have undefined properties)
  cc.getCountryCode = function(options, complete, error) {
    if (options.law && options.law.countryCode) {
      complete({
        code: options.law.countryCode
      });
      return;
    }
    if (options.location) {
      var locator = new cc.Location(options.location);
      locator.locate(function(serviceResult) {
        complete(serviceResult || {});
      }, error);
      return;
    }
    complete({});
  };

  // export utils (no point in hiding them, so we may as well expose them)
  cc.utils = util;

  // prevent this code from being run twice
  cc.hasInitialised = true;


  window.cookieconsent = cc;
})(window.cookieconsent || {});


function dr_selectTab(id) {

  var selected = id;
  if (dr_hasClass("#dr_tab_" + id, "dr-overview-item-active")) {
    selected = -1;
  }

  for (var i=1; i<=6; i++) {
    if (i == selected || selected == -1) {
      // select tab
      dr_removeCssClass("#dr_tab_" + i, "dr-overview-item-inactive");
      dr_removeCssClass("#dr_tab_" + i +" .dr-overview-item-count", "dr-overview-item-count-inactive");



      if (selected == -1) {
        dr_removeCssClass("#dr_tab_" + i, "dr-overview-item-active");
        dr_addCssClass("#dr_tab_" + i + " .dr-arrow-id", "dr-overview-arrow-right");
        dr_removeCssClass("#dr_tab_" + i + " .dr-arrow-id", "dr-overview-arrow-right-inactive");
        dr_removeCssClass("#dr_tab_" + i + " .dr-arrow-id", "dr-overview-arrow-down");

        dr_removeCssClass("#dr-tab-" + i + "-details", "dr-tab-details-active");
      } else {
        dr_addCssClass("#dr_tab_" + i, "dr-overview-item-active");
        dr_removeCssClass("#dr_tab_" + i + " .dr-arrow-id", "dr-overview-arrow-right");
        dr_removeCssClass("#dr_tab_" + i + " .dr-arrow-id", "dr-overview-arrow-right-inactive");
        dr_addCssClass("#dr_tab_" + i + " .dr-arrow-id", "dr-overview-arrow-down");

        dr_addCssClass("#dr-tab-" + i + "-details", "dr-tab-details-active");
      }
    } else {
      // deselect tab
      dr_addCssClass("#dr_tab_" + i, "dr-overview-item-inactive");
      dr_addCssClass("#dr_tab_" + i +" .dr-overview-item-count", "dr-overview-item-count-inactive");
      dr_removeCssClass("#dr_tab_" + i, "dr-overview-item-active");
      dr_removeCssClass("#dr_tab_" + i + " .dr-arrow-id",  "dr-overview-arrow-down");
      dr_addCssClass("#dr_tab_" + i + " .dr-arrow-id", "dr-overview-arrow-right-inactive");
      dr_removeCssClass("#dr-tab-" + i + "-details", "dr-tab-details-active");
    }
  }
}

function dr_addCssClass(query, className) {
  var element, arr;

  var elements = dr_select(query);
  for (var i=0; i<elements.length; i++) {
    element = elements[i];
    if (element) {
      if (element.classList) {
        element.classList.add(className);
      }
    }
  }
}

function dr_removeCssClass(query, className) {
  var elements = dr_select(query);
  for (var i=0; i<elements.length; i++) {
    var element = elements[i];
    if (element) {
      if (element.classList) {
        element.classList.remove(className); // maybe IE9 incompatible
      }
    }
  }
}

function dr_hasClass(query, className) {
  var elements = dr_select(query);
  for (var i=0; i<elements.length; i++) {
    var element = elements[i];
    if (element) {
      if (element.classList) {
        if (element.classList.contains(className)) {
          return true;
        }
      }
    }
  }
  return false;
}

function dr_select(query) {
  var result = document.querySelectorAll(query);
  if (result) {
    return result;
  } else {
    return [];
  }
}

/**
 * Tool to reload all iframes on page (typically used when closing the consent banner)
 * @param conf Configuration (optional):
 *
 * {
 *   appendConsent: true | false,
 *   blacklist: [list of iframe urls or part of urls to ignore completely]
 *   whitelist: [list of iframe urls or part of urls to include] - null or undefined to include all urls except blacklisted
 *   whitelistAppendUrls: [list of urls to append to] - null or undefined to include all urls except blacklisted
 *   blacklistAppendUrls: [list of urls to not append to]
 * }
 *
 */
function dr_reloadAllIframesOnPage(conf) {
  var f_list = document.getElementsByTagName('iframe');
  if (f_list) {
    for (var i = 0; i < f_list.length; i++) {
      var f = f_list[i];
      if (f && f.src) {
        var doReload = true;
        var appendConsent = false;

        if (conf) {
          if (conf.appendConsent === true) {
            appendConsent = true;
          }

          if (conf.blacklist) {
            doReload = !dr_arrayFoundInUrl(conf.blacklist, f.src);
          }
          if (doReload === true) {
            if (conf.whitelist) {
              doReload = dr_arrayFoundInUrl(conf.whitelist, f.src);
            }
          }

          if (doReload === true) {
            if (conf.blacklistAppendUrls) {
              appendConsent = !dr_arrayFoundInUrl(conf.blacklistAppendUrls, f.src);
            }
            if (doReload === true) {
              if (conf.whitelistAppendUrls) {
                appendConsent = dr_arrayFoundInUrl(conf.whitelistAppendUrls, f.src);
              }
            }
          }

        }


        if (doReload === true) {
          var src = f.src;
          if (appendConsent === true) {
            src = dr_cookiebanner_options.dr_removeConsentParameterFromUrl(src);
            var status = null;
            if (window.cookieconsent && window.cookieconsent.utils) {
              status = window.cookieconsent.utils.getCookie(dr_cookiebanner_options.cookieConsentName);
            }

            var consent = dr_cookiebanner_options.dr_getConsentFromBanner(status, dr_cookiebanner_options.dr_acceptedCategories);
            src = dr_cookiebanner_options.dr_addConsentParameterToUrl(src, consent);
          }
          if (document._jestActive) {
            f.srcReload = true;
          }
          f.src = src;
        }
      }
    }
  }
}

function dr_stringContains(haystack, needle) {
  if (haystack && needle) {
    if (haystack.search(new RegExp(needle, "i")) === -1) {
      return false;
    } else {
      return true;
    }
  } else {
    return false;
  }
}

function dr_arrayFoundInUrl(needleArray, url) {
  if (needleArray && Array.isArray(needleArray) && needleArray.length > 0 && url) {
    for (var i=0; i<needleArray.length; i++) {
      var part = needleArray[i];
      if (dr_stringContains(url, part)) {
        return true;
      }
    }
    return false;
  } else {
    return false;
  }
}


function dr_showCookiebar() {
  var cbar = document.getElementById("dr-cookieBar");
  var cshow = document.getElementById("dr-cookieShow");

  if (cbar && cshow) {
    cbar.style.display = "flex";
    cbar.style.display = "-ms-flexbox";
    cbar.style.display = "-webkit-box";
    cshow.style.display = "none";
  }
}

function dr_ol_showDetails() {
  var oneline = document.getElementById("dr_oneline-banner");
  var details = document.getElementById("dr_detailed-banner");

  if (oneline && details) {
    oneline.style.display = "none";
    details.style.display = "block";
  }
}

function dr_pre_showDetails() {
  var pre = document.getElementById("dr_pre-banner");
  var details = document.getElementById("dr_detailed-banner");

  var option = dr_cookiebanner_options.dr_getSelectedPreBannerOption();

  if (option) {
    window.dr_redirectAfterConsentOption = option;
    if (option.redirect) {
      window.dr_redirectAfterConsent = option.redirect;
    }
  }

  if (pre && details) {
    pre.style.display = "none";
    details.style.display = "block";
  }
}


function dr_pre_selectCountry() {
  var pre = document.getElementById("dr-selectCountry-input");
  var btn = document.getElementById("dr-selectCountry-btn");

  if (pre) {
    if (btn) {
      if (pre.value && pre.value !== "") {
        btn.style.visibility="visible";
      } else {

        btn.style.visibility="hidden";
      }
    }
  }
}

function dr_openNewWindow(url) {
  if (url) {
    window.open(url);
  }
}

function dr_openPrivacyLink(url) {
  if (dr_cookiebanner_options.privacyLinkUrl) {
    if (dr_cookiebanner_options.privacyLinkUrl.length > 0) {
      url = dr_cookiebanner_options.privacyLinkUrl;
    }
  }
  dr_openNewWindow(url);
}

function dr_openImprintLink(url) {
  if (dr_cookiebanner_options.imprintLinkUrl) {
    if (dr_cookiebanner_options.imprintLinkUrl.length > 0) {
      url = dr_cookiebanner_options.imprintLinkUrl;
    }
  }
  dr_openNewWindow(url);
}

function dr_changeCheckbox(cb, type) {
  //id="dr-cb-details-statistic" , headline

  var headlineCb = document.getElementById("dr-cb-headline-" + type);
  var detailsCb = document.getElementById("dr-cb-details-" + type);

  if (headlineCb) {
    if (headlineCb.checked !== cb.checked) {
      headlineCb.checked = cb.checked;
    }
  }

  if (detailsCb) {
    if (detailsCb.checked !== cb.checked) {
      detailsCb.checked = cb.checked;
    }
  }

}


function dr_onShowCategoryDetailsHide() {
  var cat = document.getElementById("dr-tab-category-details");
  if (cat) {
    if (cat.style.display === "block") {
      cat.style.display = "none";

    } else {
      cat.style.display = "block";

      // only hide details button in non editor mode
      if (window.dr_webcare_editor_active !== "true") {
        var details = document.querySelectorAll(".cc-banner-hidden .cc-details");
        if (details && details.length > 0) {
          for (var i = 0; i < details.length; i++) {
            details[i].style.display = "none";
          }
        }

        var compliance = document.querySelector(".cc-banner-hidden .dr-flex-centered");
        if (compliance) {
          compliance.style.justifyContent = "flex-start";
          compliance.style.alignContent = "flex-start";
        }
      }
    }
  }
}

function dr_onShowCategoryDetails() {
  var cat = document.getElementById("dr-tab-category-details");

  if (cat) {
    if (cat.style.display === "block") {
      cat.style.display = "none";
      dr_removeCssClass(".dr-btn-show-more > span.dr-open-arrow", "dr-open-arrow-status-open");
      dr_removeCssClass(".dr-btn-show-more-mobile > span.dr-open-arrow", "dr-open-arrow-status-open");
      dr_removeCssClass(".dr-btn-show-more-nocat > span.dr-open-arrow", "dr-open-arrow-status-open");
    } else {
      cat.style.display = "block";
      dr_addCssClass(".dr-btn-show-more > span.dr-open-arrow", "dr-open-arrow-status-open");
      dr_addCssClass(".dr-btn-show-more-mobile > span.dr-open-arrow", "dr-open-arrow-status-open");
      dr_addCssClass(".dr-btn-show-more-nocat > span.dr-open-arrow", "dr-open-arrow-status-open");
    }

  }
}

function dr_showCategoryTableDetails(type) {
  let tabs = ["tech", "statistic", "marketing", "unclassified",];
  for (var i=0; i< tabs.length; i++) {
    var tb = document.getElementById("dr-category-table-" + tabs[i]);
    if (tb) {
      var openState = false;
      if (type === tabs[i]) {
        if (tb.style.display === "block") {
          tb.style.display = "none";
        } else {
          tb.style.display = "block";
          openState = true;
        }
      } else {
        tb.style.display = "none";
      }

      if (openState) {
        dr_addCssClass("#dr-open-link-" + tabs[i] + " > span", "dr-open-arrow-status-open");
      } else {
        dr_removeCssClass("#dr-open-link-" + tabs[i] + " > span", "dr-open-arrow-status-open");
      }

    }
  }
}

function dr_revokeChoice() {
  var elements = document.getElementsByClassName("cc-revoke");
  if (elements) {
    for (var i=0; i<elements.length; i++) {
      if (elements[i]) {
        elements[i].click();
      }
    }
  }
}

function dr_denyChoice() {
  var elements = document.getElementsByClassName("cc-deny");
  if (elements) {
    for (var i=0; i<elements.length; i++) {
      if (elements[i]) {
        elements[i].click();
      }
    }
  }
}

function dr_allowChoice() {
  var elements = document.getElementsByClassName("cc-allow");
  if (elements) {
    for (var i=0; i<elements.length; i++) {
      if (elements[i]) {
        elements[i].click();
      }
    }
  }
}

var dr_swarmCrawler = {

  siteInfo : {
    version:1,
    protocol: null,
    domain: null,
    port: null,
    path: null,
    cookies: [],
    scripts: [],
    stylesheets: [],
  },

  activate : function() {
    dr_cookiebanner_options.log("SC.activate()");

    dr_swarmCrawler.gatherSiteInfo();
    dr_cookiebanner_options.logJson("SC: SiteInfo", dr_swarmCrawler.siteInfo);


    var xhr = new XMLHttpRequest();
    xhr.open('PUT', 'https://swarmcrawler.datareporter.eu/v1/CrowdCrawler/register');
    xhr.setRequestHeader('Content-Type', 'application/json;  charset=utf-8');
    xhr.setRequestHeader('x-api-key', '6txg8Su4Zy1bD6jhFbAMfEeP2XrRk546e5XsqoVi');
    xhr.timeout = 5000;
    xhr.onload = function() {
      // do nothing
    };
    xhr.send(JSON.stringify(dr_swarmCrawler.siteInfo));
  },

  gatherSiteInfo: function() {
    dr_cookiebanner_options.log("SC.gatherSiteInfo()");

    var server = [location.protocol, '//', location.host].join('');

    dr_swarmCrawler.siteInfo.protocol = location.protocol;
    dr_swarmCrawler.siteInfo.domain = location.hostname;
    dr_swarmCrawler.siteInfo.port = location.port;
    dr_swarmCrawler.siteInfo.path = location.pathname;

    // gather cookies
    var theCookies = document.cookie.split(';');
    for (var i = 0; i < theCookies.length; i++) {
      var cname = theCookies[i].split('=');
      if (cname && cname.length > 0) {
        if (dr_swarmCrawler.cookieOK(cname)) {
          dr_swarmCrawler.siteInfo.cookies.push(dr_swarmCrawler.trim(cname[0]));
        }
      }
    }

    // gather loaded scripts
    var scripts = document.getElementsByTagName('script');
    if (scripts && scripts.length > 0) {
      for (var i = 0; i < scripts.length; i++) {
        if (scripts[i].src) {
          // only locals
          if (!dr_swarmCrawler.startsWith(scripts[i].src, server, 0)) {
            if (dr_swarmCrawler.scriptOK(scripts[i].src)) {
              dr_swarmCrawler.siteInfo.scripts.push(dr_swarmCrawler.getHostPathFromUrl(scripts[i].src));
            }
          }
        }
      }
    }

    // gather loaded iframes as scripts
    var iframes = document.getElementsByTagName('iframe');
    if (iframes && iframes.length > 0) {
      for (var i = 0; i < iframes.length; i++) {
        if (iframes[i].src) {
          // only locals
          if (!dr_swarmCrawler.startsWith(iframes[i].src, server, 0)) {
            if (dr_swarmCrawler.iframeOK(iframes[i].src)) {
              dr_swarmCrawler.siteInfo.scripts.push(dr_swarmCrawler.getHostPathFromUrl(iframes[i].src));
            }
          }
        }
      }
    }

    // gather loaded stylesheets
    var stylesheets = document.getElementsByTagName('link');
    if (stylesheets && stylesheets.length > 0) {
      for (var i = 0; i < stylesheets.length; i++) {
        if (stylesheets[i].href) {
          // only locals
          if (!dr_swarmCrawler.startsWith(stylesheets[i].href, server, 0)) {
            if (dr_swarmCrawler.styleOK(stylesheets[i].href)) {
              dr_swarmCrawler.siteInfo.stylesheets.push(dr_swarmCrawler.getHostPathFromUrl(stylesheets[i].href));
            }
          }
        }
      }
    }
  },

  cookieOK : function (name) {
    if (name) {
      if (dr_swarmCrawler.startsWith(name, "gd15")) {
        return false;
      }
      if (dr_swarmCrawler.startsWith(name, "gd16")) {
        return false;
      }
      if (name.length == 0) {
        return false;
      }
    }
    return true;
  },

  scriptOK : function (name) {
    if (name) {
      if (name.length == 0) {
        return false;
      }
    }
    return true;
  },

  iframeOK : function (name) {
    if (name) {
      if (name.length == 0) {
        return false;
      }
    }
    return true;
  },

  styleOK : function (name) {
    if (name) {
      if (name.length == 0) {
        return false;
      }
    }
    return true;
  },

  getHostPathFromUrl : function(url) {
    if (url) {
      var param = url.indexOf('?');
      if (param > 0) {
        url = url.substring(0, param);
      }

      param = url.indexOf('#');
      if (param > 0) {
        url = url.substring(0, param);
      }
    }

    return url;
  },

  // utility function
  startsWith : function(str, searchString, position) {
    position = position || 0;
    return str.indexOf(searchString, position) === position;
  },

  trim : function(x) {
    return x.replace(/^\s+|\s+$/gm,'');
  }


}


function dr_initIntegrationTags(tags) {
  if (tags) {
    for (var i=0; i<tags.length; i++) {
      var tag = tags[i];
      dr_initIntegrationTag(0, tag);
    }
  }
}

function dr_initIntegrationTag(iterationNr, tag) {
  if (iterationNr >= 4) {
    return;
  }

  if (tag) {
    if (tag.active !== true && tag.divId && tag.divId.length > 0) {
      var e = document.getElementById(tag.divId);
      if (e) {

        if (tag.placeholderDesign === "user") {

          // just link button
          var btn = document.querySelector("#"+ tag.divId + " .cc-tag-activate-btn");
          if (btn) {
            btn.setAttribute("dr_tagname", tag.divId);
            btn.addEventListener("click", dr_activateTagWithClick, true);
          }

        } else {

          if (tag.placeholderDesign === "map") {
            e.classList.add("cc-tag-placeholder-maps");
          } else if (tag.placeholderDesign === "video") {
            e.classList.add("cc-tag-placeholder-video");
          } else if (tag.placeholderDesign === "calendar") {
            e.classList.add("cc-tag-placeholder-calendar");
          }

          e.classList.add("cc-tag-placeholder");
          var privacyText = null;
          var buttonText = null;
          if ("de" === dr_getBannerLanguage()) {
            if (tag.privacyTextDe && tag.privacyTextDe.length > 0) {
              placeholderText = tag.privacyTextDe;
            }
            buttonText = tag.buttonTextDe;
          } else {
            if (tag.privacyTextEn && tag.privacyTextEn.length > 0) {
              placeholderText = tag.privacyTextEn;
            }
            buttonText = tag.buttonTextEn;
          }

          e.innerHTML = "";
          var btn = document.createElement('div');
          btn.className = "cc-tag-activate-btn";
          btn.setAttribute("dr_tagname", tag.divId);
          btn.innerHTML = buttonText;

          btn.addEventListener("click", dr_activateTagWithClick, true);

          var description = document.createElement("div");
          description.className = "cc-tag-info";
          description.innerHTML = placeholderText;

          e.appendChild(btn);
          e.appendChild(description);
        }

      } else {
        setTimeout(function () {
          dr_initIntegrationTag(iterationNr + 1, tag);
        }, 100 + (iterationNr * 600));
      }

    }
  }
}

function dr_activateTagWithClick(e) {
  var divId = e.target.getAttribute("dr_tagname");
  if (dr_generated_tags) {
    for (var i = 0; i < dr_generated_tags.length; i++) {
      var tag = dr_generated_tags[i];
      if (tag && tag.active !== true && tag.divId === divId) {

        tag.active = true;
        var e = document.getElementById(tag.divId);
        if (e) {
          dr_cleanElementFromPlaceholder(e);

          var code = tag.code;
          code = code.replace(new RegExp("&lt;", 'g'), "<");
          if (tag.mode === "insert") {
            dr_cookiebanner_options.logJson("insert tag code", tag);
            dr_insertTag(0, tag.divId, code);
          } else {
            dr_cookiebanner_options.logJson("dr_activateTag()", tag);
            dr_activateTag(code);
          }
        }

      }
    }
  }
}

function dr_cleanElementFromPlaceholder(e) {
  if (e) {
    e.classList.remove("cc-tag-placeholder");
    e.classList.remove("cc-tag-placeholder-maps");
    e.classList.remove("cc-tag-placeholder-video");
    e.classList.remove("cc-tag-placeholder-calendar");
    e.innerHTML = "";
    e.removeEventListener("click", dr_activateTagWithClick);
  }
}

function dr_insertTag(iterationNr, divId, htmlCode) {
  var e = document.getElementById(divId);
  if (e) {
    dr_cleanElementFromPlaceholder(e);
    e.innerHTML = htmlCode;
  } else {
    setTimeout(function () {
      dr_insertTag(iterationNr + 1, divId, htmlCode);
    }, 100 + (iterationNr * 600));
  }
}

function dr_activateInsertionTag(iterationNr, divId, htmlCode) {
  var e = document.getElementById(divId);
  if (e) {
    dr_cleanElementFromPlaceholder(e);
    dr_activateTag(htmlCode);
  } else {
    setTimeout(function () {
      dr_activateInsertionTag(iterationNr + 1, divId, htmlCode);
    }, 100 + (iterationNr * 600));
  }
}


function dr_activateTag(htmlCode, removeAfterExecution) {

  var domelement = document.createElement('span');
  domelement.innerHTML = htmlCode;
  var exelist = [];

  var ret = domelement.childNodes;

  for ( var i = 0; i<ret.length; i++ ) {
    if (ret[i]) {
      if (dr_nodeName(ret[i], "script")) {

        added = false;
        if (ret[i].src) {
          if (ret[i].src.length > 0) {
            exelist.push({type: "script_load", url: ret[i].src, async: ret[i].async, done: false, removeAfterExe: false});
            added = true;
          }
        }

        if (!added) {
          exelist.push({type: "exe", script: ret[i], done: false, removeAfterExe: removeAfterExecution});
        }
      }

      if (dr_nodeName(ret[i], "link")) {
        if (ret[i].href) {
          if (ret[i].href.length > 0) {
            exelist.push({type: "css_load", url: ret[i].href, async: false, done: false, removeAfterExe: false});
          }
        }
      }

      document.body.appendChild(ret[i]);
    }
  }


  // now execute scripts
  dr_executeScripts(exelist);
}

function dr_nodeName( elem, name ) {
  return elem.nodeName && elem.nodeName.toUpperCase() === name.toUpperCase();
}

function dr_executeScripts(exelist) {
  if (exelist) {
    for (var i=0; i<exelist.length; i++) {
      var exe = exelist[i];

      if (!exe.done) {

        exe.done = true;

        if (exe.type === "script_load") {
          if (exe.async) {
            dr_loadJs(exe.url);
          } else {
            dr_loadJs(exe.url, exelist);
            return;
          }
        } else if (exe.type === "css_load") {
          dr_loadCss(exe.url, exelist);
        } else {
          dr_evalScript(exe, exe.removeAfterExe);
        }

      }

    }
  }
}

function dr_loadResourceReady(exelist) {
  // continue executing
  dr_executeScripts(exelist);
}

function dr_evalScript( scriptElem, removeAfterExe ) {

  var elem = scriptElem.script;
  var data = ( elem.text || elem.textContent || elem.innerHTML || "" );

  var head = document.getElementsByTagName("head")[0] || document.documentElement,
    script = document.createElement("script");
  script.type = "text/javascript";
  script.appendChild( document.createTextNode( data ) );
  head.insertBefore( script, head.firstChild );

  if (removeAfterExe === true) {
    head.removeChild(script);
  }

  if ( elem.parentNode ) {
    elem.parentNode.removeChild( elem );
  }
}


var dr_loadJs = function(url, exelist){
  //url is URL of external file, implementationCode is the code
  //to be called from the file, location is the location to
  //insert the <script> element

  var scriptTag = document.createElement('script');
  scriptTag.src = url;

  if (exelist) {
    scriptTag.onload = function() {
      dr_loadResourceReady(exelist);
    };
    scriptTag.onreadystatechange = function() {
      dr_loadResourceReady(exelist);
    };
  }

  document.head.appendChild(scriptTag);
};

var dr_loadCss = function(url, exelist){
  //url is URL of external file, implementationCode is the code
  //to be called from the file, location is the location to
  //insert the <script> element

  var cssTag = document.createElement('link');
  cssTag.href = url;
  cssTag.rel = "stylesheet";
  cssTag.type="text/css";
  cssTag.media="all";

  cssTag.onload = function() {
    dr_loadResourceReady(exelist);
  };
  cssTag.onreadystatechange = function() {
    dr_loadResourceReady(exelist);
  };

  document.head.appendChild(cssTag);
};


var webcareCmp = {

  webcareConsentServer : "https://c.datareporter.eu",
  webcareConsentMandant : "6619e347-0c2f-43e3-a641-36cc548b7e9e",
  webcareConsentOrg : "7wFWnJr669D",
  webcareConsentVersion : "01",
  webcareConsentMode : "", // consent, stat, null

  _apiKey: "1g6rt_4c4b-93z",
  _event: null,

  _init: false,
  consentId: null,

  _consentKey: "_webcare_consentid",


  registerEvent: function(handler) {
    this._event = handler;

    // have to inform handlers when they register after consent id was changed
    if (handler && this.consentId) {
      handler({
        event: "cid-change",
        cid: this.consentId
      });
    }

  },

  unregisterEvent: function() {
    this._event = null;
  },

  initConsent : function() {
    if (this._init === false) {

      if (this.webcareConsentMode === "consent") {
        this.consentId = this._getSavedConsentId();
        if (this._isValidConsentId(this.consentId)) {
          this._sendEvent({
            event: "cid-change",
            cid: this.consentId
          });
        }
      } else if (this.webcareConsentMode === "stat") {
        this.consentId = "--";
        this._sendEvent({
          event: "cid-change",
          cid: this.consentId
        });
      } else {
        this.consentId = null;
        this._sendEvent({
          event: "cid-change",
          cid: this.consentId
        });
      }

      this._init = true;
    }
  },

  _sendEvent: function(e) {
    if (this._event) {
      this._event(e);
    }

  },

  _getConsentUrl : function(consent) {
    this.initConsent();

    var cid = this.consentId;
    if (cid === undefined || cid === null || cid.length <= 10 ) {
      cid = "-";
    }
    if (this.webcareConsentMode === "stat") {
      cid = "--";
    }

    return this.webcareConsentServer + "/e/1/" + this.webcareConsentMandant + "/" +
      this.webcareConsentOrg + "/" + this.webcareConsentVersion + "/" +
      this._chks(this.webcareConsentMandant, this.webcareConsentOrg, this.webcareConsentVersion, consent, cid) +
      "/" + consent + "/" + cid;
  },

  _performConsentRequest : function(consent) {
    if (this.webcareConsentMode === "stat" || this.webcareConsentMode === "consent") {
      var oReq = new XMLHttpRequest();
      var self = this;
      oReq.addEventListener("load", function () {
        if (self._isValidConsentId(this.responseText)) {
          if (this.responseText !== self.consentId) {
            self.consentId = this.responseText.trim().toLowerCase();

            self._saveConsentId();

            self._sendEvent({
              event: "cid-change",
              cid: self.consentId
            });

          }

          self._sendEvent({
            event: "consent-ok",
            operation: consent,
            cid: self.consentId
          });
        }
      });

      oReq.open("GET", this._getConsentUrl(consent));
      oReq.setRequestHeader("authentication", this._apiKey);
      oReq.setRequestHeader("hostname", location.hostname);
      oReq.send();

    }
  },

  /**
   * Clears all Consent IDs
   */
  clear : function() {
    var sendEvent = false;
    if (this.consentId != null) {
      sendEvent = true;
    }
    this.consentId = null;
    this._saveConsentId();

    if (sendEvent) {
      this._sendEvent({
        event: "cid-change",
        cid: this.consentId
      });
    }

  },

  /**
   * Register operation "Open GUI"
   * Called when the CMP GUI is shown
   */
  opengui : function() {
    this.initConsent();

    this._performConsentRequest("o");

  },

  /**
   * Register operation "Allow"
   * Called when the User selects "Allow all cookies"
   */
  allow : function() {
    this.initConsent();
    this._performConsentRequest("allow");
  },

  /**
   * Register operation "Apply"
   * Called when the User selects some classes and chooses "Apply"
   * consent string can be allow, tpsmu, deny
   */
  apply : function(consent) {
    this.initConsent();
    this._performConsentRequest(consent);
  },

  /**
   * Called when user chooses Deny
   * Only necessary cookies are allowed (same as tp)
   * @param consent
   */
  deny : function() {
    this.initConsent();
    this._performConsentRequest("deny");
  },

  /**
   * Called when the user revokes his choice and the GUI is shown again
   */
  revoke : function() {
    this.initConsent();
    this._performConsentRequest("revoke");
  },

  getConsentDetailLink : function() {
    if (this._isValidConsentId(this.consentId)) {
      return "https://conserve.datareporter.eu/consent-history/" + this.consentId;
    } else {
      return null;
    }
  },

  getConsentId : function() {
    if (this._isValidConsentId(this.consentId)) {
      return this.consentId;
    } else {
      return null;
    }
  },

  _chks : function(mandant, org, version, consent, consentId) {
    if (mandant && org && version && consent) {
      let s = "wcc:" + mandant + "_" + org + "_" + version + "_" + consent + "_" + consentId;
      var chk = 0xD0000000;
      var len = s.length;
      chk += 0x71210;
      for (var i = 0; i < len; i++) {
        chk += (s.charCodeAt(i) * (i + 1));
      }
      return (chk & 0xff).toString(26);
    } else {
      return null;
    }
  },

  _getSavedConsentId : function() {
    let cookieId = this._getCookie(this._consentKey);
    let localStorageId = localStorage.getItem(this._consentKey);

    if (this._isValidConsentId(cookieId)) {
      if (this._isValidConsentId(localStorageId)) {
        if (cookieId === localStorageId) {
          // do nothing, return one of the equals
          return localStorageId;
        } else {
          // not equal, take local storage and set cookie
          this._setCookie(this._consentKey, localStorageId);
          return localStorageId;
        }
      } else {
        // cookie must be it
        localStorage.setItem(this._consentKey, cookieId);
        return cookieId;
      }
    } else {
      if (this._isValidConsentId(localStorageId)) {
        // take local storage and set cookie
        this._setCookie(this._consentKey, localStorageId);
        return localStorageId;
      } else {
        // no valid id in here
        return null;
      }
    }

  },

  _isValidConsentId : function(c_id) {
    if (c_id && c_id.trim().length === 36) {
      return true;
    } else {
      return false;
    }
  },

  _saveConsentId : function() {
    // set cookie and local storage
    localStorage.setItem(this._consentKey, this.consentId);
    this._setCookie(this._consentKey, this.consentId);
  },

  _getCookie: function(name) {

    var value = '; ' + document.cookie;
    var parts = value.split('; ' + name + '=');
    var result = parts.length < 2
      ? undefined
      : parts
        .pop()
        .split(';')
        .shift();

    return result;
  },

  _setCookie: function(name, value) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + 365);

    var cookie = [
      name + '=' + value,
      'expires=' + exdate.toUTCString(),
      'path=' + '/'
    ];

    if (location.protocol === 'https:') {
      cookie.push('secure');
      cookie.push('SameSite=none');
    }

    document.cookie = cookie.join(';');

  },

};




var dr_generated_banner = {
  "de" : "<div role=\"dialog\" aria-live=\"polite\" aria-label=\"cookieconsent\" aria-describedby=\"cookieconsent:desc\" class=\"cc-window cc-banner cc-type-opt-out cc-theme-block cc-middle cc-color-override-datareporter cc-banner-small\" id=\"dr_cookie_banner_container\"> <div class=\"\" style=\"margin:0;padding:0;border:0; ;\" id=\"dr_oneline-banner\"> <div class=\"dr_ol-left-buttons \"> <a class=\"dr_ol-button dr_ol-details\" title=\"Details zu Cookies...\" onclick=\"dr_ol_showDetails()\"> <svg version=\"1.1\" id=\"dr-svg-info\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\" class=\"\"> <path class=\"dr_ol-details-svg\" d=\"M32,0C14.32,0,0,14.32,0,32s14.32,32,32,32s32-14.32,32-32S49.68,0,32,0z M32,5.33 c14.73,0,26.67,11.94,26.67,26.67S46.73,58.67,32,58.67S5.33,46.73,5.33,32S17.27,5.33,32,5.33z M32,15.5 c-0.49,0-0.9-0.01-1.33,0.08c-0.44,0.09-0.84,0.33-1.17,0.58c-0.32,0.25-0.56,0.59-0.75,1c-0.19,0.41-0.25,0.89-0.25,1.5 c0,0.6,0.06,1.08,0.25,1.5c0.19,0.42,0.43,0.75,0.75,1s0.73,0.4,1.17,0.5c0.44,0.1,0.84,0.17,1.33,0.17c0.48,0,0.99-0.06,1.42-0.17 c0.43-0.1,0.76-0.25,1.08-0.5s0.56-0.58,0.75-1c0.19-0.41,0.33-0.9,0.33-1.5c0-0.61-0.15-1.09-0.33-1.5c-0.19-0.41-0.43-0.75-0.75-1 c-0.32-0.25-0.66-0.49-1.08-0.58C32.99,15.49,32.48,15.5,32,15.5z M28.75,24.42v23.92h6.5V24.42H28.75z\"/> </svg> </a> <a class=\"dr_ol-button dr_ol-privacyLink \" title=\"hier.\" aria-label=\"hier.\" href=\"javascript:dr_openPrivacyLink('https://www.omv.com/en/about-us/corporate-governance/data-protection')\"> <svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-deny-svg\" d=\"M32,0C14.4,0,0,14.4,0,32s14.4,32,32,32s32-14.4,32-32S49.6,0,32,0z M32,5.8c14.5,0,26.2,11.7,26.2,26.2 S46.5,58.2,32,58.2S5.8,46.5,5.8,32S17.5,5.8,32,5.8z\"/> <g> <path class=\"dr_ol-deny-svg\" d=\"M23.9,20.3c0-1.1,0.3-2.1,0.9-3c0.6-0.9,1.5-1.7,2.7-2.2c1.2-0.6,2.6-0.8,4.2-0.8c1.2,0,2.3,0.2,3.4,0.5 c1,0.3,1.9,0.8,2.6,1.3c0.7,0.5,1.3,1.1,1.7,1.8c0.4,0.6,0.6,1.3,0.6,1.9c0,0.5-0.2,0.9-0.6,1.3s-0.9,0.6-1.5,0.6 c-0.5,0-0.9-0.1-1.2-0.4c-0.3-0.3-0.7-0.7-1.2-1.3c-0.5-0.6-1-1.1-1.5-1.4c-0.5-0.3-1.2-0.5-2-0.5c-1,0-1.7,0.2-2.3,0.7 c-0.6,0.5-0.8,1-0.8,1.6c0,0.6,0.2,1.2,0.7,1.6c0.5,0.5,1.3,1,2.4,1.6c1.1,0.6,1.9,1,2.3,1.3c1.1,0.6,2.1,1.2,2.9,1.7 c0.9,0.5,1.6,1,2.3,1.6c0.7,0.6,1.3,1.3,1.7,2c0.4,0.8,0.6,1.7,0.6,2.7c0,1.2-0.3,2.2-0.9,3.2c-0.6,0.9-1.5,1.8-2.7,2.4 c1.7,1.4,2.5,3,2.5,4.9c0,0.9-0.2,1.7-0.6,2.5s-0.9,1.5-1.7,2.1c-0.7,0.6-1.6,1.1-2.6,1.4c-1,0.3-2.1,0.5-3.3,0.5 c-1.4,0-2.7-0.2-3.8-0.6c-1.1-0.4-2-0.9-2.8-1.6s-1.4-1.4-1.8-2.1s-0.6-1.5-0.6-2.1c0-0.6,0.2-1.2,0.7-1.6c0.4-0.5,1-0.7,1.7-0.7 c0.3,0,0.5,0.1,0.8,0.2c0.3,0.1,0.5,0.2,0.6,0.4c0.6,0.8,1.1,1.5,1.3,2c0.7,1.6,2,2.5,3.8,2.5c1,0,1.8-0.3,2.4-0.8 c0.6-0.5,0.9-1.2,0.9-1.9c0-0.5-0.2-1-0.5-1.4c-0.3-0.4-0.8-0.9-1.5-1.3c-0.6-0.4-1.6-1.1-3-1.9s-2.7-1.7-4.1-2.5 c-0.5-0.3-1.1-0.7-1.6-1.1s-1-0.8-1.5-1.3c-0.4-0.5-0.8-1-1-1.6c-0.2-0.6-0.4-1.3-0.4-2.1c0-2.2,1.3-4.1,3.9-5.4 C24.6,23.5,23.9,22,23.9,20.3z M28.6,26.8c-1.4,0.9-2.2,1.9-2.2,2.9c0,0.5,0.2,1,0.5,1.4c0.4,0.4,0.9,0.9,1.5,1.3s1.6,1,2.9,1.8 c0.4,0.2,0.9,0.5,1.6,0.9c0.7,0.4,1.3,0.8,2,1.1c1.5-1.1,2.2-2,2.2-2.8c0-0.4-0.1-0.9-0.4-1.2s-0.6-0.7-1.1-1.1 c-0.4-0.3-1-0.7-1.7-1.1s-1.5-0.9-2.5-1.5c-0.8-0.5-1.5-0.8-1.9-1.1C29.1,27,28.8,26.9,28.6,26.8z\"/> </g> </svg> </a> </div> <div class=\"dr_ol-line \">Ihre pers&ouml;nlichen Cookie Einstellungen</div> <div class=\"dr_ol-left-buttons-alt\"> <a class=\"dr_ol-button dr_ol-details\" title=\"Details zu Cookies...\" onclick=\"dr_ol_showDetails()\"> <svg version=\"1.1\" id=\"dr-svg-details\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-details-svg\" d=\"M32,0C14.32,0,0,14.32,0,32s14.32,32,32,32s32-14.32,32-32S49.68,0,32,0z M32,5.33 c14.73,0,26.67,11.94,26.67,26.67S46.73,58.67,32,58.67S5.33,46.73,5.33,32S17.27,5.33,32,5.33z M32,15.5 c-0.49,0-0.9-0.01-1.33,0.08c-0.44,0.09-0.84,0.33-1.17,0.58c-0.32,0.25-0.56,0.59-0.75,1c-0.19,0.41-0.25,0.89-0.25,1.5 c0,0.6,0.06,1.08,0.25,1.5c0.19,0.42,0.43,0.75,0.75,1s0.73,0.4,1.17,0.5c0.44,0.1,0.84,0.17,1.33,0.17c0.48,0,0.99-0.06,1.42-0.17 c0.43-0.1,0.76-0.25,1.08-0.5s0.56-0.58,0.75-1c0.19-0.41,0.33-0.9,0.33-1.5c0-0.61-0.15-1.09-0.33-1.5c-0.19-0.41-0.43-0.75-0.75-1 c-0.32-0.25-0.66-0.49-1.08-0.58C32.99,15.49,32.48,15.5,32,15.5z M28.75,24.42v23.92h6.5V24.42H28.75z\"/> </svg> </a> <a class=\"dr_ol-button dr_ol-privacyLink \" title=\"hier.\" aria-label=\"hier.\" href=\"javascript:dr_openPrivacyLink('https://www.omv.com/en/about-us/corporate-governance/data-protection')\"> <svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-deny-svg\" d=\"M32,0C14.4,0,0,14.4,0,32s14.4,32,32,32s32-14.4,32-32S49.6,0,32,0z M32,5.8c14.5,0,26.2,11.7,26.2,26.2 S46.5,58.2,32,58.2S5.8,46.5,5.8,32S17.5,5.8,32,5.8z\"/> <g> <path class=\"dr_ol-deny-svg\" d=\"M23.9,20.3c0-1.1,0.3-2.1,0.9-3c0.6-0.9,1.5-1.7,2.7-2.2c1.2-0.6,2.6-0.8,4.2-0.8c1.2,0,2.3,0.2,3.4,0.5 c1,0.3,1.9,0.8,2.6,1.3c0.7,0.5,1.3,1.1,1.7,1.8c0.4,0.6,0.6,1.3,0.6,1.9c0,0.5-0.2,0.9-0.6,1.3s-0.9,0.6-1.5,0.6 c-0.5,0-0.9-0.1-1.2-0.4c-0.3-0.3-0.7-0.7-1.2-1.3c-0.5-0.6-1-1.1-1.5-1.4c-0.5-0.3-1.2-0.5-2-0.5c-1,0-1.7,0.2-2.3,0.7 c-0.6,0.5-0.8,1-0.8,1.6c0,0.6,0.2,1.2,0.7,1.6c0.5,0.5,1.3,1,2.4,1.6c1.1,0.6,1.9,1,2.3,1.3c1.1,0.6,2.1,1.2,2.9,1.7 c0.9,0.5,1.6,1,2.3,1.6c0.7,0.6,1.3,1.3,1.7,2c0.4,0.8,0.6,1.7,0.6,2.7c0,1.2-0.3,2.2-0.9,3.2c-0.6,0.9-1.5,1.8-2.7,2.4 c1.7,1.4,2.5,3,2.5,4.9c0,0.9-0.2,1.7-0.6,2.5s-0.9,1.5-1.7,2.1c-0.7,0.6-1.6,1.1-2.6,1.4c-1,0.3-2.1,0.5-3.3,0.5 c-1.4,0-2.7-0.2-3.8-0.6c-1.1-0.4-2-0.9-2.8-1.6s-1.4-1.4-1.8-2.1s-0.6-1.5-0.6-2.1c0-0.6,0.2-1.2,0.7-1.6c0.4-0.5,1-0.7,1.7-0.7 c0.3,0,0.5,0.1,0.8,0.2c0.3,0.1,0.5,0.2,0.6,0.4c0.6,0.8,1.1,1.5,1.3,2c0.7,1.6,2,2.5,3.8,2.5c1,0,1.8-0.3,2.4-0.8 c0.6-0.5,0.9-1.2,0.9-1.9c0-0.5-0.2-1-0.5-1.4c-0.3-0.4-0.8-0.9-1.5-1.3c-0.6-0.4-1.6-1.1-3-1.9s-2.7-1.7-4.1-2.5 c-0.5-0.3-1.1-0.7-1.6-1.1s-1-0.8-1.5-1.3c-0.4-0.5-0.8-1-1-1.6c-0.2-0.6-0.4-1.3-0.4-2.1c0-2.2,1.3-4.1,3.9-5.4 C24.6,23.5,23.9,22,23.9,20.3z M28.6,26.8c-1.4,0.9-2.2,1.9-2.2,2.9c0,0.5,0.2,1,0.5,1.4c0.4,0.4,0.9,0.9,1.5,1.3s1.6,1,2.9,1.8 c0.4,0.2,0.9,0.5,1.6,0.9c0.7,0.4,1.3,0.8,2,1.1c1.5-1.1,2.2-2,2.2-2.8c0-0.4-0.1-0.9-0.4-1.2s-0.6-0.7-1.1-1.1 c-0.4-0.3-1-0.7-1.7-1.1s-1.5-0.9-2.5-1.5c-0.8-0.5-1.5-0.8-1.9-1.1C29.1,27,28.8,26.9,28.6,26.8z\"/> </g> </svg> </a> </div> <div class=\"dr_ol-right-buttons \"> <a class=\"dr_ol-button dr_ol-allow cc-btn cc-allow dr_ol-allow dr-btn-shadow\" title=\"ALLE COOKIES ERLAUBEN\"> <svg version=\"1.1\" id=\"dr-svg-allow\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <polygon class=\"dr_ol-allow-svg-bg\" points=\"47.6,5 16.4,5 0.8,32 16.4,59 47.6,59 63.2,32 \"/> <path class=\"dr_ol-allow-svg\" d=\"M32,0C14.4,0,0,14.4,0,32s14.4,32,32,32s32-14.4,32-32S49.6,0,32,0z M32,5.8c14.5,0,26.2,11.7,26.2,26.2 S46.5,58.2,32,58.2S5.8,46.5,5.8,32S17.5,5.8,32,5.8z M47.7,20.9L29.1,39.5l-9.5-9.5l-4.2,4.2L27,45.7l2.1,2l2.1-2L51.8,25 L47.7,20.9z\"/> </svg> </a> <a class=\"dr_ol-button dr_ol-deny cc-btn cc-deny\" title=\"Nur erforderliche Cookies erlauben\"> <svg version=\"1.1\" id=\"dr-svg-deny\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-deny-svg\" d=\"M22.69,19.15l-3.54,3.54L28.46,32l-9.31,9.31l3.54,3.54L32,35.54l9.31,9.31l3.54-3.54L35.54,32l9.31-9.31 l-3.54-3.54L32,28.46L22.69,19.15z\"/> </svg> </a> </div> </div> <div id=\"dr_detailed-banner\" class=\"cc-banner-hidden\" style=\"width:100%;margin:0;padding:0;border:0;;\"> <div id=\"cookieconsent:desc\" class=\"cc-message\"> <div class=\"dr-insert-content dr-invisible-element\" id=\"dr-insert-content\"></div> <div class=\"dr-cookietext\"> <p class=\"dr-headline\">Ihre pers&ouml;nlichen Cookie Einstellungen</p> <p class=\"dr-descriptiontext\"><span>Um Ihnen das bestm&ouml;gliche Online-Erlebnis zu bieten, verwenden wir auf dieser Website Cookies. Teilweise werden auch Cookies von ausgew&auml;hlten Partnern verwendet. Wir nehmen Datenschutz ernst und respektieren Ihre Privatsph&auml;re: Sie haben jederzeit die M&ouml;glichkeit Ihre Cookie-Einstellungen zu &auml;ndern. Einige der von uns verwendeten Partnerdienste sind in den USA niedergelassen. Entsprechend der Judikatur des Europ&auml;ischen Gerichtshofes besteht derzeit in den USA kein angemessenes Datenschutzniveau. Es besteht daher das Risiko, dass Ihre Daten dem Zugriff durch US-Beh&ouml;rden zu Kontroll- und &Uuml;berwachungszwecken unterliegen und Ihnen dagegen keine wirksamen Rechtsbehelfe zur Verf&uuml;gung stehen. Mit Ihrem Klick auf „All Cookies zulassen“ stimmen Sie zu, dass Cookies auf unserer Website von uns und von Drittanbietern (auch in den USA) verwendet werden d&uuml;rfen. Eine &Uuml;bersicht &uuml;ber die von uns verwendeten Partnerdienste finden Sie </span> <a class=\"dr-privacylink\" title=\"hier.\" href=\"javascript:dr_openPrivacyLink('https://www.omv.com/en/about-us/corporate-governance/data-protection')\"> hier.</a> </p> </div> <div style=\"display:none;\"> <input type=\"checkbox\" onchange=\"dr_changeCheckbox(this, 'statistic')\" id=\"dr-cb-headline-statistic\"> <input type=\"checkbox\" onchange=\"dr_changeCheckbox(this, 'marketing')\" id=\"dr-cb-headline-marketing\"> <input type=\"checkbox\" onchange=\"dr_changeCheckbox(this, 'unclassified')\" id=\"dr-cb-headline-unclassified\"> </div> </div> <div class=\"cc-compliance dr-flex-centered\"> <a aria-label=\"deny cookies\" role=\"button\" class=\"cc-btn cc-details dr-roundcorners dr-noborder-deny\" href=\"javascript:dr_onShowCategoryDetailsHide()\">Details anzeigen</a> <a aria-label=\"deny cookies\" role=\"button\" class=\"cc-btn cc-deny dr-roundcorners dr-noborder-deny\">Nur erforderliche Cookies erlauben</a> <a aria-label=\"allow cookies\" role=\"button\" class=\"cc-btn cc-allow dr-roundcorners dr-btn-shadow dr-noborder-allow\">ALLE COOKIES ERLAUBEN</a> </div> <div class=\"dr-tab-category-details dr-roundcorners dr-shadow \" id=\"dr-tab-category-details\"> <ul class=\"dr-tab-category-content\"> <li class=\"dr-category-headline\">Erforderlich (43)</li> <li class=\"dr-category-switch\"> <label class=\"dr-category-switch-control\"> <span class=\"dr-category-switch-control-slider-before dr-category-switch-control-slider-before-always-on dr-roundcorners\"></span> <span class=\"dr-category-switch-control-slider dr-category-switch-control-slider-readonly dr-roundcorners-big\"> <span class=\"dr-category-switch-on\">ON</span> <span class=\"dr-category-switch-off\">OFF</span> </span> </label> </li> <li class=\"dr-tab-category-text\"> <span>Technisch notwendige Cookies dienen dazu, um den technischen Betrieb einer Webseite zu erm&ouml;glichen und diese f&uuml;r Sie funktional nutzbar zu machen. Die Nutzung erfolgt aufgrund unseres berechtigten Interesses eine technisch einwandfreie Webseite anzubieten. Sie k&ouml;nnen jedoch generell die Cookie Nutzung in Ihrem Browser deaktivieren.<br/></span> <a class=\"dr-tab-category-morelink\" id=\"dr-open-link-tech\" href=\"javascript:dr_showCategoryTableDetails('tech')\"><span class=\"dr-open-arrow-small\"></span><span>Details anzeigen</span></a> </li> <li class=\"dr-category-table\" id=\"dr-category-table-tech\" style=\"display:none;\"> <table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"> <thead> <tr class=\"dr-tableheader-row\"> <th class=\"dr-tableheader-cell dr-tableheader-name dr-roundcorners-left\">Name</th> <th class=\"dr-tableheader-cell dr-tableheader-provider\">Ersteller</th> <th class=\"dr-tableheader-cell dr-tableheader-valid\">Speicherdauer</th> <th class=\"dr-tableheader-cell dr-tableheader-domain dr-roundcorners-right\">Domain</th> </tr> </thead> <tbody> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-37487c1bd...\">BCSI-AC-37487c1bd...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-379782ced...\">BCSI-AC-379782ced...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-4f51c1692...\">BCSI-AC-4f51c1692...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-549775c69...\">BCSI-AC-549775c69...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-72d2d05dc...\">BCSI-AC-72d2d05dc...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-bc405f6a8...\">BCSI-AC-bc405f6a8...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-fcdcc5f95...\">BCSI-AC-fcdcc5f95...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-CS-\">BCSI-CS-</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"BlueCoat\">BlueCoat</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"CAM_UAID\">CAM_UAID</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"OneIdentity\">OneIdentity</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Permanent\">Permanent</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>z&auml;hlt die Anzahl der Sitzung und weist jedem Besucher eine anonyme Kennung zu. </span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"cookieconsent_mode\">cookieconsent_mode</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"DataReporter GmbH\">DataReporter GmbH</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 Monate\">12 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt die Informationen, inwieweit der Nutzer die Verwendung von Cookies best&auml;tigt hat.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"cookieconsent_status\">cookieconsent_status</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"DataReporter GmbH\">DataReporter GmbH</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 Monate\">12 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt die Informationen, inwieweit der Nutzer die Verwendung von Cookies best&auml;tigt hat.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ext_name\">ext_name</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ipuac-40CE2481FA1...\">ipuac-40CE2481FA1...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"JSESSIONID\">JSESSIONID</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>z&auml;hlt die Anzahl der Sitzung und weist jedem Besucher eine anonyme Kennung zu. </span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"JSESSIONIDFW\">JSESSIONIDFW</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>z&auml;hlt die Anzahl der Sitzung und weist jedem Besucher eine anonyme Kennung zu. </span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"lang\">lang</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"logglytrackingses...\">logglytrackingses...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Loggly\">Loggly</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>z&auml;hlt die Anzahl der Sitzung und weist jedem Besucher eine anonyme Kennung zu. </span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"MYSAPSSO2\">MYSAPSSO2</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"SAP\">SAP</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"notified-hinweis_...\">notified-hinweis_...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"NSC_AAAC\">NSC_AAAC</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Citrix\">Citrix</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"NSC_TMAS\">NSC_TMAS</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"NetScaler\">NetScaler</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"opera-interstitial\">opera-interstitial</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"org.springframewo...\">org.springframewo...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Monat\">1 Monat</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLG_GWPT_Show_Hid...\">SLG_GWPT_Show_Hid...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLG_wptGlobTipTmp\">SLG_wptGlobTipTmp</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLO_GWPT_Show_Hid...\">SLO_GWPT_Show_Hid...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"CloudFlare\">CloudFlare</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLO_wptGlobTipTmp\">SLO_wptGlobTipTmp</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"CloudFlare\">CloudFlare</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SL_GWPT_Show_Hide...\">SL_GWPT_Show_Hide...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SL_wptGlobTipTmp\">SL_wptGlobTipTmp</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ssm_au_c\">ssm_au_c</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>speichern Einstellungen und Vorlieben des Benutzers wie etwa die aktuelle Spracheinstellung.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SWG_CS_HTTPS_1\">SWG_CS_HTTPS_1</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"X-Oracle-BMC-LBS-...\">X-Oracle-BMC-LBS-...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Oracle\">Oracle</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit, Bedienbarkeit und Anmeldung zu internen Tools wie CMS, interne Gateways und Portalen sicher.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"X-SIG-HTTPS-Umbre...\">X-SIG-HTTPS-Umbre...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>z&auml;hlt die Anzahl der Sitzung und weist jedem Besucher eine anonyme Kennung zu. </span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjAbsoluteSessio...\">_hjAbsoluteSessio...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"30 Minuten\">30 Minuten</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>z&auml;hlt die Anzahl der Sitzung und weist jedem Besucher eine anonyme Kennung zu. </span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjid\">_hjid</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 Monate\">12 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjMinimizedPolls\">_hjMinimizedPolls</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"HotJar\">HotJar</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjSessionRejected\">_hjSessionRejected</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"30 Minuten\">30 Minuten</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>z&auml;hlt die Anzahl der Sitzung und weist jedem Besucher eine anonyme Kennung zu. </span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjSessionResumed\">_hjSessionResumed</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjTLDTest\">_hjTLDTest</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_SI_VID\">_SI_VID</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_sm_au_c\">_sm_au_c</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"__htmlcs.utma\">__htmlcs.utma</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"__htmlcs.utmc\">__htmlcs.utmc</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>stellt die Funktionsf&auml;higkeit und Bedienbarkeit der Seite sicher und dient zur Nachverfolgung von Fehlern.</span></td> </tr> </tbody> </table> </li> <li class=\"dr-category-separator\"><hr/></li> <li class=\"dr-category-headline\">Statistik (20)</li> <li class=\"dr-category-switch\"> <label class=\"dr-category-switch-control\"> <input type=\"checkbox\" class=\"jcf-ignore\" onchange=\"dr_changeCheckbox(this, 'statistic')\" id=\"dr-cb-details-statistic\"> <span class=\"dr-category-switch-control-slider-before dr-roundcorners\"></span> <span class=\"dr-category-switch-control-slider dr-roundcorners-big\"> <span class=\"dr-category-switch-on\">ON</span> <span class=\"dr-category-switch-off\">OFF</span> </span> </label> </li> <li class=\"dr-tab-category-text \"> <span>Statistik-Cookies sammeln Informationen dar&uuml;ber, wie Webseiten genutzt werden, um folglich deren Attraktivit&auml;t, Inhalt und Funktionalit&auml;t zu verbessern. Eine Nutzung erfolgt nur mit Ihrer Einwilligung und zwar nur solange Sie das jeweilige Cookie nicht deaktiviert haben.</span> <a class=\"dr-tab-category-morelink\" id=\"dr-open-link-statistic\" href=\"javascript:dr_showCategoryTableDetails('statistic')\"><span class=\"dr-open-arrow-small\"></span><span>Details anzeigen</span></a> </li> <li class=\"dr-category-table\" id=\"dr-category-table-statistic\" style=\"display:none;\"> <table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"> <thead> <tr class=\"dr-tableheader-row\"> <th class=\"dr-tableheader-cell dr-tableheader-name dr-roundcorners-left\">Name</th> <th class=\"dr-tableheader-cell dr-tableheader-provider\">Ersteller</th> <th class=\"dr-tableheader-cell dr-tableheader-valid\">Speicherdauer</th> <th class=\"dr-tableheader-cell dr-tableheader-domain dr-roundcorners-right\">Domain</th> </tr> </thead> <tbody> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ai_user\">ai_user</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 Monate\">12 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"amplitude_idomv.com\">amplitude_idomv.com</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Amplitude\">Amplitude</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"perf_dv5Tr4n\">perf_dv5Tr4n</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"swatag\">swatag</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"SAS Webanalytics\">SAS Webanalytics</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"s_fid\">s_fid</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Adobe\">Adobe</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_clsk\">_clsk</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Tag\">1 Tag</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_ga\">_ga</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gac_gb_UA-606137...\">_gac_gb_UA-606137...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gac_UA-60613743-1\">_gac_UA-60613743-1</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat\">_gat</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Minute\">1 Minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-60613743-1\">_gat_UA-60613743-1</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Minute\">1 Minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-60613743-10\">_gat_UA-60613743-10</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Minute\">1 Minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-60613743-2\">_gat_UA-60613743-2</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Minute\">1 Minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-90594352-23\">_gat_UA-90594352-23</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Minute\">1 Minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_ga_EMK651XX4D\">_ga_EMK651XX4D</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_ga_HDRKGW0XBT\">_ga_HDRKGW0XBT</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gid\">_gid</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Tag\">1 Tag</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjFirstSeen\">_hjFirstSeen</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Hotjar\">Hotjar</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"30 Minuten\">30 Minuten</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjIncludedInPage...\">_hjIncludedInPage...</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Minuten\">2 Minuten</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"__TAG_ASSISTANT\">__TAG_ASSISTANT</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>enth&auml;lt Informationen um die Unterscheidung von Nutzern der Seite zu erm&ouml;glichen. Sammelt Daten &uuml;ber Besuche des Nutzers, wie zum Beispiel welche Seiten von Relevanz sind.</span></td> </tr> </tbody> </table> </li> <li class=\"dr-category-separator\"><hr/></li> <li class=\"dr-category-headline\">Marketing (19)</li> <li class=\"dr-category-switch\"> <label class=\"dr-category-switch-control\"> <input type=\"checkbox\" class=\"jcf-ignore\" onchange=\"dr_changeCheckbox(this, 'marketing')\" id=\"dr-cb-details-marketing\"> <span class=\"dr-category-switch-control-slider-before dr-roundcorners\"></span> <span class=\"dr-category-switch-control-slider dr-roundcorners-big\"> <span class=\"dr-category-switch-on\">ON</span> <span class=\"dr-category-switch-off\">OFF</span> </span> </label> </li> <li class=\"dr-tab-category-text \"> <span>Marketing-Cookies stammen von externen Werbeunternehmen und werden verwendet, um Informationen &uuml;ber die vom Benutzer besuchten Webseiten zu sammeln. Eine Nutzung erfolgt nur mit Ihrer Einwilligung und zwar nur solange Sie das jeweilige Cookie nicht deaktiviert haben.</span> <a class=\"dr-tab-category-morelink\" id=\"dr-open-link-marketing\" href=\"javascript:dr_showCategoryTableDetails('marketing')\"><span class=\"dr-open-arrow-small\"></span><span>Details anzeigen</span></a> </li> <li class=\"dr-category-table\" id=\"dr-category-table-marketing\" style=\"display:none;\"> <table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"> <thead> <tr class=\"dr-tableheader-row\"> <th class=\"dr-tableheader-cell dr-tableheader-name dr-roundcorners-left\">Name</th> <th class=\"dr-tableheader-cell dr-tableheader-provider\">Ersteller</th> <th class=\"dr-tableheader-cell dr-tableheader-valid\">Speicherdauer</th> <th class=\"dr-tableheader-cell dr-tableheader-domain dr-roundcorners-right\">Domain</th> </tr> </thead> <tbody> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"AnalyticsSyncHistory\">AnalyticsSyncHistory</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Monat\">1 Monat</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ANONCHK\">ANONCHK</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"10 Minuten\">10 Minuten</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".c.clarity.ms\">.c.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"bcookie\">bcookie</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"bscookie\">bscookie</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".www.linkedin.com\">.www.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"CLID\">CLID</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 Monate\">12 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.clarity.ms\">www.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"fr\">fr</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Facebook\">Facebook</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"3 Monate\">3 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".facebook.com\">.facebook.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"lidc\">lidc</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Tag\">1 Tag</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"li_gc\">li_gc</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 Jahre\">2 Jahre</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"MUID\">MUID</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Bing\">Bing</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Jahr\">1 Jahr</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".clarity.ms\">.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"NID\">NID</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"6 Monate\">6 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.google.com\">www.google.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SM\">SM</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Sitzung\">Sitzung</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".c.clarity.ms\">.c.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SRM_B\">SRM_B</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Jahr\">1 Jahr</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".c.bing.com\">.c.bing.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"test_cookie\">test_cookie</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"15 Minuten\">15 Minuten</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".doubleclick.net\">.doubleclick.net</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"UserMatchHistory\">UserMatchHistory</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 Monat\">1 Monat</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_clck\">_clck</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 Monate\">12 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_fbc\">_fbc</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Facebook\">Facebook</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_fbp\">_fbp</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Facebook\">Facebook</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"3 Monate\">3 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gcl_au\">_gcl_au</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"3 Monate\">3 Monate</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjDonePolls\">_hjDonePolls</span></td> <td data-label=\"Ersteller\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"HotJar\">HotJar</span></td> <td data-label=\"Speicherdauer\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registriert eine eindeutige ID, die den Nutzer identifiziert und wieder erkennt. Wird f&uuml;r gezielte Werbung eingesetzt.</span></td> </tr> </tbody> </table> </li> <li class=\"dr-category-separator\"><hr/></li> <li class=\"dr-tab-category-button \"> <a aria-label=\"deny cookies\" role=\"button\" class=\"cc-btn cc-deny dr-roundcorners dr-btn-shadow dr-noborder-allow\">Einstellungen &uuml;bernehmen</a> </li> <li class=\"dr-category-headline\">&Uuml;ber Cookies</li> <li class=\"dr-tab-category-text \"> <span>Cookies sind kleine Datenpakete, die zwischen Ihrem Browser und unserem Webserver ausgetauscht werden. Cookies k&ouml;nnen nur Informationen speichern, die von Ihrem Browser geliefert werden.<br/><br/>Je nach Verwendungszweck sind Cookies technisch erforderlich oder werden f&uuml;r Statistik- oder Marketingzwecke genutzt. Die Verwendung von technisch erforderlichen Cookies beruht auf unserem berechtigten Interesse am technisch einwandfreien Betrieb und an der reibungslosen Funktionalit&auml;t unserer Website. Die Verwendung von Statistik- und Marketing-Cookies ben&ouml;tigt eine Einwilligung. Diese ist freiwillig und kann jederzeit f&uuml;r die Zukunft durch den Aufruf der Cookie Einstellungen widerrufen werden.<br/><br/>Sie k&ouml;nnen Ihren Browser auch so einstellen, dass das Speichern von Cookies generell verhindert wird. Einmal gesetzte Cookies k&ouml;nnen Sie jederzeit wieder l&ouml;schen. Wie all dies im Einzelnen funktioniert, finden Sie in der Hilfe-Funktion Ihres Browsers. Bitte beachten Sie, dass eine generelle Deaktivierung von Cookies gegebenenfalls zu Funktionseinschr&auml;nkungen auf unserer Website f&uuml;hren kann.<br/><br/>N&auml;here Informationen, welche Daten in Cookies gespeichert, zu welchen Zwecken diese verwendet und f&uuml;r wie lange Daten gespeichert werden, erhalten Sie in unserer Datenschutzerkl&auml;rung und in unserem Cookie Banner.</span> <span id=\"dr_webcareCmpLink\"></span> </li> <li class=\"dr-category-separator\">&nbsp;</li> </ul> </div> </div> </div>",
"en" : "<div role=\"dialog\" aria-live=\"polite\" aria-label=\"cookieconsent\" aria-describedby=\"cookieconsent:desc\" class=\"cc-window cc-banner cc-type-opt-out cc-theme-block cc-middle cc-color-override-datareporter cc-banner-small\" id=\"dr_cookie_banner_container\"> <div class=\"\" style=\"margin:0;padding:0;border:0; ;\" id=\"dr_oneline-banner\"> <div class=\"dr_ol-left-buttons \"> <a class=\"dr_ol-button dr_ol-details\" title=\"Details about cookies ...\" onclick=\"dr_ol_showDetails()\"> <svg version=\"1.1\" id=\"dr-svg-info\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\" class=\"\"> <path class=\"dr_ol-details-svg\" d=\"M32,0C14.32,0,0,14.32,0,32s14.32,32,32,32s32-14.32,32-32S49.68,0,32,0z M32,5.33 c14.73,0,26.67,11.94,26.67,26.67S46.73,58.67,32,58.67S5.33,46.73,5.33,32S17.27,5.33,32,5.33z M32,15.5 c-0.49,0-0.9-0.01-1.33,0.08c-0.44,0.09-0.84,0.33-1.17,0.58c-0.32,0.25-0.56,0.59-0.75,1c-0.19,0.41-0.25,0.89-0.25,1.5 c0,0.6,0.06,1.08,0.25,1.5c0.19,0.42,0.43,0.75,0.75,1s0.73,0.4,1.17,0.5c0.44,0.1,0.84,0.17,1.33,0.17c0.48,0,0.99-0.06,1.42-0.17 c0.43-0.1,0.76-0.25,1.08-0.5s0.56-0.58,0.75-1c0.19-0.41,0.33-0.9,0.33-1.5c0-0.61-0.15-1.09-0.33-1.5c-0.19-0.41-0.43-0.75-0.75-1 c-0.32-0.25-0.66-0.49-1.08-0.58C32.99,15.49,32.48,15.5,32,15.5z M28.75,24.42v23.92h6.5V24.42H28.75z\"/> </svg> </a> <a class=\"dr_ol-button dr_ol-privacyLink \" title=\"here.\" aria-label=\"here.\" href=\"javascript:dr_openPrivacyLink('https://www.omv.com/de/ueber-uns/corporate-governance/datenschutz')\"> <svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-deny-svg\" d=\"M32,0C14.4,0,0,14.4,0,32s14.4,32,32,32s32-14.4,32-32S49.6,0,32,0z M32,5.8c14.5,0,26.2,11.7,26.2,26.2 S46.5,58.2,32,58.2S5.8,46.5,5.8,32S17.5,5.8,32,5.8z\"/> <g> <path class=\"dr_ol-deny-svg\" d=\"M23.9,20.3c0-1.1,0.3-2.1,0.9-3c0.6-0.9,1.5-1.7,2.7-2.2c1.2-0.6,2.6-0.8,4.2-0.8c1.2,0,2.3,0.2,3.4,0.5 c1,0.3,1.9,0.8,2.6,1.3c0.7,0.5,1.3,1.1,1.7,1.8c0.4,0.6,0.6,1.3,0.6,1.9c0,0.5-0.2,0.9-0.6,1.3s-0.9,0.6-1.5,0.6 c-0.5,0-0.9-0.1-1.2-0.4c-0.3-0.3-0.7-0.7-1.2-1.3c-0.5-0.6-1-1.1-1.5-1.4c-0.5-0.3-1.2-0.5-2-0.5c-1,0-1.7,0.2-2.3,0.7 c-0.6,0.5-0.8,1-0.8,1.6c0,0.6,0.2,1.2,0.7,1.6c0.5,0.5,1.3,1,2.4,1.6c1.1,0.6,1.9,1,2.3,1.3c1.1,0.6,2.1,1.2,2.9,1.7 c0.9,0.5,1.6,1,2.3,1.6c0.7,0.6,1.3,1.3,1.7,2c0.4,0.8,0.6,1.7,0.6,2.7c0,1.2-0.3,2.2-0.9,3.2c-0.6,0.9-1.5,1.8-2.7,2.4 c1.7,1.4,2.5,3,2.5,4.9c0,0.9-0.2,1.7-0.6,2.5s-0.9,1.5-1.7,2.1c-0.7,0.6-1.6,1.1-2.6,1.4c-1,0.3-2.1,0.5-3.3,0.5 c-1.4,0-2.7-0.2-3.8-0.6c-1.1-0.4-2-0.9-2.8-1.6s-1.4-1.4-1.8-2.1s-0.6-1.5-0.6-2.1c0-0.6,0.2-1.2,0.7-1.6c0.4-0.5,1-0.7,1.7-0.7 c0.3,0,0.5,0.1,0.8,0.2c0.3,0.1,0.5,0.2,0.6,0.4c0.6,0.8,1.1,1.5,1.3,2c0.7,1.6,2,2.5,3.8,2.5c1,0,1.8-0.3,2.4-0.8 c0.6-0.5,0.9-1.2,0.9-1.9c0-0.5-0.2-1-0.5-1.4c-0.3-0.4-0.8-0.9-1.5-1.3c-0.6-0.4-1.6-1.1-3-1.9s-2.7-1.7-4.1-2.5 c-0.5-0.3-1.1-0.7-1.6-1.1s-1-0.8-1.5-1.3c-0.4-0.5-0.8-1-1-1.6c-0.2-0.6-0.4-1.3-0.4-2.1c0-2.2,1.3-4.1,3.9-5.4 C24.6,23.5,23.9,22,23.9,20.3z M28.6,26.8c-1.4,0.9-2.2,1.9-2.2,2.9c0,0.5,0.2,1,0.5,1.4c0.4,0.4,0.9,0.9,1.5,1.3s1.6,1,2.9,1.8 c0.4,0.2,0.9,0.5,1.6,0.9c0.7,0.4,1.3,0.8,2,1.1c1.5-1.1,2.2-2,2.2-2.8c0-0.4-0.1-0.9-0.4-1.2s-0.6-0.7-1.1-1.1 c-0.4-0.3-1-0.7-1.7-1.1s-1.5-0.9-2.5-1.5c-0.8-0.5-1.5-0.8-1.9-1.1C29.1,27,28.8,26.9,28.6,26.8z\"/> </g> </svg> </a> </div> <div class=\"dr_ol-line \">Your personal cookie settings</div> <div class=\"dr_ol-left-buttons-alt\"> <a class=\"dr_ol-button dr_ol-details\" title=\"Details about cookies ...\" onclick=\"dr_ol_showDetails()\"> <svg version=\"1.1\" id=\"dr-svg-details\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-details-svg\" d=\"M32,0C14.32,0,0,14.32,0,32s14.32,32,32,32s32-14.32,32-32S49.68,0,32,0z M32,5.33 c14.73,0,26.67,11.94,26.67,26.67S46.73,58.67,32,58.67S5.33,46.73,5.33,32S17.27,5.33,32,5.33z M32,15.5 c-0.49,0-0.9-0.01-1.33,0.08c-0.44,0.09-0.84,0.33-1.17,0.58c-0.32,0.25-0.56,0.59-0.75,1c-0.19,0.41-0.25,0.89-0.25,1.5 c0,0.6,0.06,1.08,0.25,1.5c0.19,0.42,0.43,0.75,0.75,1s0.73,0.4,1.17,0.5c0.44,0.1,0.84,0.17,1.33,0.17c0.48,0,0.99-0.06,1.42-0.17 c0.43-0.1,0.76-0.25,1.08-0.5s0.56-0.58,0.75-1c0.19-0.41,0.33-0.9,0.33-1.5c0-0.61-0.15-1.09-0.33-1.5c-0.19-0.41-0.43-0.75-0.75-1 c-0.32-0.25-0.66-0.49-1.08-0.58C32.99,15.49,32.48,15.5,32,15.5z M28.75,24.42v23.92h6.5V24.42H28.75z\"/> </svg> </a> <a class=\"dr_ol-button dr_ol-privacyLink \" title=\"here.\" aria-label=\"here.\" href=\"javascript:dr_openPrivacyLink('https://www.omv.com/de/ueber-uns/corporate-governance/datenschutz')\"> <svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-deny-svg\" d=\"M32,0C14.4,0,0,14.4,0,32s14.4,32,32,32s32-14.4,32-32S49.6,0,32,0z M32,5.8c14.5,0,26.2,11.7,26.2,26.2 S46.5,58.2,32,58.2S5.8,46.5,5.8,32S17.5,5.8,32,5.8z\"/> <g> <path class=\"dr_ol-deny-svg\" d=\"M23.9,20.3c0-1.1,0.3-2.1,0.9-3c0.6-0.9,1.5-1.7,2.7-2.2c1.2-0.6,2.6-0.8,4.2-0.8c1.2,0,2.3,0.2,3.4,0.5 c1,0.3,1.9,0.8,2.6,1.3c0.7,0.5,1.3,1.1,1.7,1.8c0.4,0.6,0.6,1.3,0.6,1.9c0,0.5-0.2,0.9-0.6,1.3s-0.9,0.6-1.5,0.6 c-0.5,0-0.9-0.1-1.2-0.4c-0.3-0.3-0.7-0.7-1.2-1.3c-0.5-0.6-1-1.1-1.5-1.4c-0.5-0.3-1.2-0.5-2-0.5c-1,0-1.7,0.2-2.3,0.7 c-0.6,0.5-0.8,1-0.8,1.6c0,0.6,0.2,1.2,0.7,1.6c0.5,0.5,1.3,1,2.4,1.6c1.1,0.6,1.9,1,2.3,1.3c1.1,0.6,2.1,1.2,2.9,1.7 c0.9,0.5,1.6,1,2.3,1.6c0.7,0.6,1.3,1.3,1.7,2c0.4,0.8,0.6,1.7,0.6,2.7c0,1.2-0.3,2.2-0.9,3.2c-0.6,0.9-1.5,1.8-2.7,2.4 c1.7,1.4,2.5,3,2.5,4.9c0,0.9-0.2,1.7-0.6,2.5s-0.9,1.5-1.7,2.1c-0.7,0.6-1.6,1.1-2.6,1.4c-1,0.3-2.1,0.5-3.3,0.5 c-1.4,0-2.7-0.2-3.8-0.6c-1.1-0.4-2-0.9-2.8-1.6s-1.4-1.4-1.8-2.1s-0.6-1.5-0.6-2.1c0-0.6,0.2-1.2,0.7-1.6c0.4-0.5,1-0.7,1.7-0.7 c0.3,0,0.5,0.1,0.8,0.2c0.3,0.1,0.5,0.2,0.6,0.4c0.6,0.8,1.1,1.5,1.3,2c0.7,1.6,2,2.5,3.8,2.5c1,0,1.8-0.3,2.4-0.8 c0.6-0.5,0.9-1.2,0.9-1.9c0-0.5-0.2-1-0.5-1.4c-0.3-0.4-0.8-0.9-1.5-1.3c-0.6-0.4-1.6-1.1-3-1.9s-2.7-1.7-4.1-2.5 c-0.5-0.3-1.1-0.7-1.6-1.1s-1-0.8-1.5-1.3c-0.4-0.5-0.8-1-1-1.6c-0.2-0.6-0.4-1.3-0.4-2.1c0-2.2,1.3-4.1,3.9-5.4 C24.6,23.5,23.9,22,23.9,20.3z M28.6,26.8c-1.4,0.9-2.2,1.9-2.2,2.9c0,0.5,0.2,1,0.5,1.4c0.4,0.4,0.9,0.9,1.5,1.3s1.6,1,2.9,1.8 c0.4,0.2,0.9,0.5,1.6,0.9c0.7,0.4,1.3,0.8,2,1.1c1.5-1.1,2.2-2,2.2-2.8c0-0.4-0.1-0.9-0.4-1.2s-0.6-0.7-1.1-1.1 c-0.4-0.3-1-0.7-1.7-1.1s-1.5-0.9-2.5-1.5c-0.8-0.5-1.5-0.8-1.9-1.1C29.1,27,28.8,26.9,28.6,26.8z\"/> </g> </svg> </a> </div> <div class=\"dr_ol-right-buttons \"> <a class=\"dr_ol-button dr_ol-allow cc-btn cc-allow dr_ol-allow dr-btn-shadow\" title=\"ALLOW ALL COOKIES\"> <svg version=\"1.1\" id=\"dr-svg-allow\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <polygon class=\"dr_ol-allow-svg-bg\" points=\"47.6,5 16.4,5 0.8,32 16.4,59 47.6,59 63.2,32 \"/> <path class=\"dr_ol-allow-svg\" d=\"M32,0C14.4,0,0,14.4,0,32s14.4,32,32,32s32-14.4,32-32S49.6,0,32,0z M32,5.8c14.5,0,26.2,11.7,26.2,26.2 S46.5,58.2,32,58.2S5.8,46.5,5.8,32S17.5,5.8,32,5.8z M47.7,20.9L29.1,39.5l-9.5-9.5l-4.2,4.2L27,45.7l2.1,2l2.1-2L51.8,25 L47.7,20.9z\"/> </svg> </a> <a class=\"dr_ol-button dr_ol-deny cc-btn cc-deny\" title=\"Only allow required cookies\"> <svg version=\"1.1\" id=\"dr-svg-deny\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 64 64\" style=\"enable-background:new 0 0 64 64; max-width: 40px;\" xml:space=\"preserve\"> <path class=\"dr_ol-deny-svg\" d=\"M22.69,19.15l-3.54,3.54L28.46,32l-9.31,9.31l3.54,3.54L32,35.54l9.31,9.31l3.54-3.54L35.54,32l9.31-9.31 l-3.54-3.54L32,28.46L22.69,19.15z\"/> </svg> </a> </div> </div> <div id=\"dr_detailed-banner\" class=\"cc-banner-hidden\" style=\"width:100%;margin:0;padding:0;border:0;;\"> <div id=\"cookieconsent:desc\" class=\"cc-message\"> <div class=\"dr-insert-content dr-invisible-element\" id=\"dr-insert-content\"></div> <div class=\"dr-cookietext\"> <p class=\"dr-headline\">Your personal cookie settings</p> <p class=\"dr-descriptiontext\"><span>In order to provide you with the best possible online experience, we use cookies on this website. In some cases, cookies from selected partners are also used. We take data protection seriously and respect your privacy: you have the option to change your cookie settings at any time. Some of the partner services we use are located in the USA. In accordance with the case law of the European Court of Justice, there is currently no adequate level of data protection in the USA. There is therefore a risk that your data may be subject to access by US authorities for control and monitoring purposes and that you may not have any effective legal remedies against this. By clicking on \"Allow all cookies\", you agree that cookies may be used on our website by us and by third-party providers (also in the USA). You can find an overview of the partner services we use</span> <a class=\"dr-privacylink\" title=\"here.\" href=\"javascript:dr_openPrivacyLink('https://www.omv.com/de/ueber-uns/corporate-governance/datenschutz')\"> here.</a> </p> </div> <div style=\"display:none;\"> <input type=\"checkbox\" onchange=\"dr_changeCheckbox(this, 'statistic')\" id=\"dr-cb-headline-statistic\"> <input type=\"checkbox\" onchange=\"dr_changeCheckbox(this, 'marketing')\" id=\"dr-cb-headline-marketing\"> <input type=\"checkbox\" onchange=\"dr_changeCheckbox(this, 'unclassified')\" id=\"dr-cb-headline-unclassified\"> </div> </div> <div class=\"cc-compliance dr-flex-centered\"> <a aria-label=\"deny cookies\" role=\"button\" class=\"cc-btn cc-details dr-roundcorners dr-noborder-deny\" href=\"javascript:dr_onShowCategoryDetailsHide()\">Show details</a> <a aria-label=\"deny cookies\" role=\"button\" class=\"cc-btn cc-deny dr-roundcorners dr-noborder-deny\">Only allow required cookies</a> <a aria-label=\"allow cookies\" role=\"button\" class=\"cc-btn cc-allow dr-roundcorners dr-btn-shadow dr-noborder-allow\">ALLOW ALL COOKIES</a> </div> <div class=\"dr-tab-category-details dr-roundcorners dr-shadow \" id=\"dr-tab-category-details\"> <ul class=\"dr-tab-category-content\"> <li class=\"dr-category-headline\">Required (43)</li> <li class=\"dr-category-switch\"> <label class=\"dr-category-switch-control\"> <span class=\"dr-category-switch-control-slider-before dr-category-switch-control-slider-before-always-on dr-roundcorners\"></span> <span class=\"dr-category-switch-control-slider dr-category-switch-control-slider-readonly dr-roundcorners-big\"> <span class=\"dr-category-switch-on\">ON</span> <span class=\"dr-category-switch-off\">OFF</span> </span> </label> </li> <li class=\"dr-tab-category-text\"> <span>Technically necessary cookies are used to enable the technical operation of a website and make it functional for you. The use is based on our legitimate interest to provide a technically flawless website. However, you can generally disable the use of cookies in your browser.</span> <a class=\"dr-tab-category-morelink\" id=\"dr-open-link-tech\" href=\"javascript:dr_showCategoryTableDetails('tech')\"><span class=\"dr-open-arrow-small\"></span><span>Show details</span></a> </li> <li class=\"dr-category-table\" id=\"dr-category-table-tech\" style=\"display:none;\"> <table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"> <thead> <tr class=\"dr-tableheader-row\"> <th class=\"dr-tableheader-cell dr-tableheader-name dr-roundcorners-left\">Name</th> <th class=\"dr-tableheader-cell dr-tableheader-provider\">Creator</th> <th class=\"dr-tableheader-cell dr-tableheader-valid\">Storage time</th> <th class=\"dr-tableheader-cell dr-tableheader-domain dr-roundcorners-right\">Domain</th> </tr> </thead> <tbody> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-37487c1bd...\">BCSI-AC-37487c1bd...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-379782ced...\">BCSI-AC-379782ced...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-4f51c1692...\">BCSI-AC-4f51c1692...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-549775c69...\">BCSI-AC-549775c69...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-72d2d05dc...\">BCSI-AC-72d2d05dc...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-bc405f6a8...\">BCSI-AC-bc405f6a8...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-AC-fcdcc5f95...\">BCSI-AC-fcdcc5f95...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"BCSI-CS-\">BCSI-CS-</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"BlueCoat\">BlueCoat</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"CAM_UAID\">CAM_UAID</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"OneIdentity\">OneIdentity</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Permanent\">Permanent</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>counts the number of sessions and assigns an anonymous identifier to each visitor.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"cookieconsent_mode\">cookieconsent_mode</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"DataReporter GmbH\">DataReporter GmbH</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 months\">12 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>contains the information to what extent the user has confirmed the use of cookies.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"cookieconsent_status\">cookieconsent_status</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"DataReporter GmbH\">DataReporter GmbH</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 months\">12 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>contains the information to what extent the user has confirmed the use of cookies.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ext_name\">ext_name</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ipuac-40CE2481FA1...\">ipuac-40CE2481FA1...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"JSESSIONID\">JSESSIONID</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>counts the number of sessions and assigns an anonymous identifier to each visitor.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"JSESSIONIDFW\">JSESSIONIDFW</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>counts the number of sessions and assigns an anonymous identifier to each visitor.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"lang\">lang</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"logglytrackingses...\">logglytrackingses...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Loggly\">Loggly</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>counts the number of sessions and assigns an anonymous identifier to each visitor.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"MYSAPSSO2\">MYSAPSSO2</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"SAP\">SAP</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"notified-hinweis_...\">notified-hinweis_...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"NSC_AAAC\">NSC_AAAC</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Citrix\">Citrix</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"NSC_TMAS\">NSC_TMAS</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"NetScaler\">NetScaler</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"opera-interstitial\">opera-interstitial</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"org.springframewo...\">org.springframewo...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 month\">1 month</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLG_GWPT_Show_Hid...\">SLG_GWPT_Show_Hid...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLG_wptGlobTipTmp\">SLG_wptGlobTipTmp</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLO_GWPT_Show_Hid...\">SLO_GWPT_Show_Hid...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"CloudFlare\">CloudFlare</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SLO_wptGlobTipTmp\">SLO_wptGlobTipTmp</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"CloudFlare\">CloudFlare</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SL_GWPT_Show_Hide...\">SL_GWPT_Show_Hide...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SL_wptGlobTipTmp\">SL_wptGlobTipTmp</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ssm_au_c\">ssm_au_c</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>save settings and preferences of the user such as the current language setting.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SWG_CS_HTTPS_1\">SWG_CS_HTTPS_1</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"X-Oracle-BMC-LBS-...\">X-Oracle-BMC-LBS-...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Oracle\">Oracle</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality, operation and login to internal tools such as CMS, internal gateways and portals.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"X-SIG-HTTPS-Umbre...\">X-SIG-HTTPS-Umbre...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>counts the number of sessions and assigns an anonymous identifier to each visitor.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjAbsoluteSessio...\">_hjAbsoluteSessio...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"30 minutes\">30 minutes</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>counts the number of sessions and assigns an anonymous identifier to each visitor.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjid\">_hjid</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 months\">12 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjMinimizedPolls\">_hjMinimizedPolls</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"HotJar\">HotJar</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjSessionRejected\">_hjSessionRejected</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"30 minutes\">30 minutes</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>counts the number of sessions and assigns an anonymous identifier to each visitor.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjSessionResumed\">_hjSessionResumed</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjTLDTest\">_hjTLDTest</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_SI_VID\">_SI_VID</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_sm_au_c\">_sm_au_c</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"__htmlcs.utma\">__htmlcs.utma</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"__htmlcs.utmc\">__htmlcs.utmc</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>ensures the functionality and usability of the page and is used to track errors.</span></td> </tr> </tbody> </table> </li> <li class=\"dr-category-separator\"><hr/></li> <li class=\"dr-category-headline\">Statistics (20)</li> <li class=\"dr-category-switch\"> <label class=\"dr-category-switch-control\"> <input type=\"checkbox\" class=\"jcf-ignore\" onchange=\"dr_changeCheckbox(this, 'statistic')\" id=\"dr-cb-details-statistic\"> <span class=\"dr-category-switch-control-slider-before dr-roundcorners\"></span> <span class=\"dr-category-switch-control-slider dr-roundcorners-big\"> <span class=\"dr-category-switch-on\">ON</span> <span class=\"dr-category-switch-off\">OFF</span> </span> </label> </li> <li class=\"dr-tab-category-text \"> <span>Statistics cookies collect information about how websites are used to improve their attractiveness, content and functionality. A use takes place only with your consent and only as long as you have not deactivated the respective cookie.</span> <a class=\"dr-tab-category-morelink\" id=\"dr-open-link-statistic\" href=\"javascript:dr_showCategoryTableDetails('statistic')\"><span class=\"dr-open-arrow-small\"></span><span>Show details</span></a> </li> <li class=\"dr-category-table\" id=\"dr-category-table-statistic\" style=\"display:none;\"> <table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"> <thead> <tr class=\"dr-tableheader-row\"> <th class=\"dr-tableheader-cell dr-tableheader-name dr-roundcorners-left\">Name</th> <th class=\"dr-tableheader-cell dr-tableheader-provider\">Creator</th> <th class=\"dr-tableheader-cell dr-tableheader-valid\">Storage time</th> <th class=\"dr-tableheader-cell dr-tableheader-domain dr-roundcorners-right\">Domain</th> </tr> </thead> <tbody> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ai_user\">ai_user</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 months\">12 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"amplitude_idomv.com\">amplitude_idomv.com</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Amplitude\">Amplitude</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"perf_dv5Tr4n\">perf_dv5Tr4n</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"swatag\">swatag</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"SAS Webanalytics\">SAS Webanalytics</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"s_fid\">s_fid</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Adobe\">Adobe</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_clsk\">_clsk</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 day\">1 day</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_ga\">_ga</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gac_gb_UA-606137...\">_gac_gb_UA-606137...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gac_UA-60613743-1\">_gac_UA-60613743-1</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat\">_gat</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 minute\">1 minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-60613743-1\">_gat_UA-60613743-1</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 minute\">1 minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-60613743-10\">_gat_UA-60613743-10</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 minute\">1 minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-60613743-2\">_gat_UA-60613743-2</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 minute\">1 minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gat_UA-90594352-23\">_gat_UA-90594352-23</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 minute\">1 minute</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_ga_EMK651XX4D\">_ga_EMK651XX4D</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_ga_HDRKGW0XBT\">_ga_HDRKGW0XBT</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gid\">_gid</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 day\">1 day</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjFirstSeen\">_hjFirstSeen</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Hotjar\">Hotjar</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"30 minutes\">30 minutes</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjIncludedInPage...\">_hjIncludedInPage...</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 minutes\">2 minutes</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"__TAG_ASSISTANT\">__TAG_ASSISTANT</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>Contains information to help distinguish users from the page. Gathers data about user visits, such as which pages are relevant.</span></td> </tr> </tbody> </table> </li> <li class=\"dr-category-separator\"><hr/></li> <li class=\"dr-category-headline\">Marketing (19)</li> <li class=\"dr-category-switch\"> <label class=\"dr-category-switch-control\"> <input type=\"checkbox\" class=\"jcf-ignore\" onchange=\"dr_changeCheckbox(this, 'marketing')\" id=\"dr-cb-details-marketing\"> <span class=\"dr-category-switch-control-slider-before dr-roundcorners\"></span> <span class=\"dr-category-switch-control-slider dr-roundcorners-big\"> <span class=\"dr-category-switch-on\">ON</span> <span class=\"dr-category-switch-off\">OFF</span> </span> </label> </li> <li class=\"dr-tab-category-text \"> <span>Marketing cookies come from external advertising companies and are used to collect information about the websites visited by the user. A use takes place only with your consent and only as long as you have not deactivated the respective cookie.</span> <a class=\"dr-tab-category-morelink\" id=\"dr-open-link-marketing\" href=\"javascript:dr_showCategoryTableDetails('marketing')\"><span class=\"dr-open-arrow-small\"></span><span>Show details</span></a> </li> <li class=\"dr-category-table\" id=\"dr-category-table-marketing\" style=\"display:none;\"> <table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"> <thead> <tr class=\"dr-tableheader-row\"> <th class=\"dr-tableheader-cell dr-tableheader-name dr-roundcorners-left\">Name</th> <th class=\"dr-tableheader-cell dr-tableheader-provider\">Creator</th> <th class=\"dr-tableheader-cell dr-tableheader-valid\">Storage time</th> <th class=\"dr-tableheader-cell dr-tableheader-domain dr-roundcorners-right\">Domain</th> </tr> </thead> <tbody> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"AnalyticsSyncHistory\">AnalyticsSyncHistory</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 month\">1 month</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"ANONCHK\">ANONCHK</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"10 minutes\">10 minutes</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".c.clarity.ms\">.c.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"bcookie\">bcookie</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"bscookie\">bscookie</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".www.linkedin.com\">.www.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"CLID\">CLID</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 months\">12 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.clarity.ms\">www.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"fr\">fr</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Facebook\">Facebook</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"3 months\">3 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".facebook.com\">.facebook.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"lidc\">lidc</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 day\">1 day</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"li_gc\">li_gc</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"2 years\">2 years</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"MUID\">MUID</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Bing\">Bing</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 year\">1 year</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".clarity.ms\">.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"NID\">NID</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"6 months\">6 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.google.com\">www.google.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SM\">SM</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Session\">Session</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".c.clarity.ms\">.c.clarity.ms</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"SRM_B\">SRM_B</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 year\">1 year</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".c.bing.com\">.c.bing.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"test_cookie\">test_cookie</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"15 minutes\">15 minutes</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".doubleclick.net\">.doubleclick.net</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"UserMatchHistory\">UserMatchHistory</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"LinkedIn\">LinkedIn</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"1 month\">1 month</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\".linkedin.com\">.linkedin.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_clck\">_clck</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Microsoft\">Microsoft</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"12 months\">12 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_fbc\">_fbc</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Facebook\">Facebook</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_fbp\">_fbp</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Facebook\">Facebook</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"3 months\">3 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_gcl_au\">_gcl_au</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"Google\">Google</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"3 months\">3 months</span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> <tr class=\"dr-detail-tabledata\"> <td data-label=\"Name\" class=\"dr-cut-line dr-linebreak-anywhere\"><span class=\" dr-cookie-name\" title=\"_hjDonePolls\">_hjDonePolls</span></td> <td data-label=\"Creator\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"HotJar\">HotJar</span></td> <td data-label=\"Storage time\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"\"></span></td> <td data-label=\"Domain\" class=\"dr-cut-line dr-linebreak-anywhere\"><span title=\"www.omv.com\">www.omv.com</span></td> </tr> <tr class=\"dr-detail-tabledata dr-detail-tabledata-addon\"> <td class=\"dr-hide-on-mobile\">&nbsp;</td> <td data-label=\"\" colspan=\"3\" class=\"dr-cookie-purpose\"><span>registers a unique ID that identifies and recognizes the user. Used for targeted advertising.</span></td> </tr> </tbody> </table> </li> <li class=\"dr-category-separator\"><hr/></li> <li class=\"dr-tab-category-button \"> <a aria-label=\"deny cookies\" role=\"button\" class=\"cc-btn cc-deny dr-roundcorners dr-btn-shadow dr-noborder-allow\">Apply settings</a> </li> <li class=\"dr-category-headline\">About cookies</li> <li class=\"dr-tab-category-text \"> <span>Cookies are small data packages that are exchanged between your browser and our web server. Cookies can only store information provided by your browser.<br/><br/>Depending on the intended use, cookies are either technically necessary or are used for statistical or marketing purposes. The use of technically required cookies is based on our legitimate interest in the technically correct operation and smooth functionality of our website. The use of statistics and marketing cookies requires your consent. This is voluntary and can be revoked at any time for the future by calling up our cookie settings.<br/><br/>You can also set your browser to generally prevent the storage of cookies. Once cookies have been set, you can delete them at any time. How all this works in details can be found in the help function of your browser. Please note that a general deactivation of cookies may lead to functional restrictions on our website.<br/><br/>You can find more detailed information on what data is stored in cookies, for what purposes they are used and for how long data is stored in our data protection declaration and in our cookie banner.</span> <span id=\"dr_webcareCmpLink\"></span> </li> <li class=\"dr-category-separator\">&nbsp;</li> </ul> </div> </div> </div>",

};

var dr_generated_policies = {
  "de" : "Einstellungen zu Cookies...",
"en" : "Settings for cookies ...",

};

var dr_generated_tags = [ {
  "divId" : null,
  "mode" : null,
  "category" : "",
  "activationMode" : "close",
  "active" : false,
  "code" : "&lt;script>\n    dr_reloadAllIframesOnPage();\n&lt;/script>\n",
  "buttonTextDe" : null,
  "buttonTextEn" : null,
  "privacyTextDe" : null,
  "privacyTextEn" : null,
  "placeholderDesign" : null,
  "ignoreCookies" : [ ]
} ];

var dr_ignore_cookies = ['cookieconsent_status', 'cookieconsent_mode', '_webcare_consentid','BCSI-AC-37487c1bdb871076','BCSI-AC-379782ced4caea17','BCSI-AC-4f51c1692465db55','BCSI-AC-549775c698e0b436','BCSI-AC-72d2d05dc20e86f4','BCSI-AC-bc405f6a86e1641a','BCSI-AC-fcdcc5f95128b720','BCSI-CS-','CAM_UAID','cookieconsent_mode','cookieconsent_status','ext_name','ipuac-40CE2481FA10-FCH2121V2X3','JSESSIONID','JSESSIONIDFW','lang','logglytrackingsession','MYSAPSSO2','notified-hinweis_surfen_zvnt08v','NSC_AAAC','NSC_TMAS','opera-interstitial','org.springframework.web.servlet.i18n.CookieLocaleResolver.LOCALE','SLG_GWPT_Show_Hide_tmp','SLG_wptGlobTipTmp','SLO_GWPT_Show_Hide_tmp','SLO_wptGlobTipTmp','SL_GWPT_Show_Hide_tmp','SL_wptGlobTipTmp','ssm_au_c','SWG_CS_HTTPS_1','X-Oracle-BMC-LBS-Route','X-SIG-HTTPS-Umbrella-SAML','_hjAbsoluteSessionInProgress','_hjid','_hjMinimizedPolls','_hjSessionRejected','_hjSessionResumed','_hjTLDTest','_SI_VID','_sm_au_c','__htmlcs.utma','__htmlcs.utmc'];
var dr_delete_cookies = [{name:'ai_user', path:'/', category:'statistic' },{name:'amplitude_idomv.com', path:'/', category:'statistic' },{name:'perf_dv5Tr4n', path:'/', category:'statistic' },{name:'swatag', path:'/', category:'statistic' },{name:'s_fid', path:'/', category:'statistic' },{name:'_clsk', path:'/', category:'statistic' },{name:'_ga', path:'/', category:'statistic' },{name:'_gac_gb_UA-60613743-1', path:'/', category:'statistic' },{name:'_gac_UA-60613743-1', path:'/', category:'statistic' },{name:'_gat', path:'/', category:'statistic' },{name:'_gat_UA-60613743-1', path:'/', category:'statistic' },{name:'_gat_UA-60613743-10', path:'/', category:'statistic' },{name:'_gat_UA-60613743-2', path:'/', category:'statistic' },{name:'_gat_UA-90594352-23', path:'/', category:'statistic' },{name:'_ga_EMK651XX4D', path:'/', category:'statistic' },{name:'_ga_HDRKGW0XBT', path:'/', category:'statistic' },{name:'_gid', path:'/', category:'statistic' },{name:'_hjFirstSeen', path:'/', category:'statistic' },{name:'_hjIncludedInPageviewSample', path:'/', category:'statistic' },{name:'__TAG_ASSISTANT', path:'/', category:'statistic' },{name:'AnalyticsSyncHistory', path:'/', category:'marketing' },{name:'ANONCHK', path:'/', category:'marketing' },{name:'bcookie', path:'/', category:'marketing' },{name:'bscookie', path:'/', category:'marketing' },{name:'CLID', path:'/', category:'marketing' },{name:'fr', path:'/', category:'marketing' },{name:'lidc', path:'/', category:'marketing' },{name:'li_gc', path:'/', category:'marketing' },{name:'MUID', path:'/', category:'marketing' },{name:'NID', path:'/', category:'marketing' },{name:'SM', path:'/', category:'marketing' },{name:'SRM_B', path:'/', category:'marketing' },{name:'test_cookie', path:'/', category:'marketing' },{name:'UserMatchHistory', path:'/', category:'marketing' },{name:'_clck', path:'/', category:'marketing' },{name:'_fbc', path:'/', category:'marketing' },{name:'_fbp', path:'/', category:'marketing' },{name:'_gcl_au', path:'/', category:'marketing' },{name:'_hjDonePolls', path:'/', category:'marketing' }];
var dr_deleteCookieMode = "auto"; // all (all cookies except ignore), manual (none), auto (only marketing/statistic) or categories (manual category choose)

var dr_bannerLanguage = dr_getBannerLanguage();

var cookieMobileImage = "<svg version='1.1' id='dr_mobilePreviewCookie' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px'  viewBox='0 0 50 50' style='enable-background:new 0 0 50 50; pointer-events:none; display:none;' xml:space='preserve'><g id='surface1' class='dr_mobilePreviewCookie_fill'> <path d='M25,4C13.4,4,4,13.4,4,25s9.4,21,21,21s21-9.4,21-21c0-0.7-0.1-1.3-0.1-1.8c0-0.4-0.2-0.7-0.6-0.8s-0.7-0.1-1,0.1  c-0.6,0.4-1.2,0.6-1.9,0.6c-1.4,0-2.7-0.9-3.2-2.2c-0.1-0.3-0.3-0.5-0.6-0.6c-0.3-0.1-0.6-0.1-0.8,0.1C37,20.7,36,21,35,21  c-3.3,0-6-2.7-6-6c0-1,0.2-2,0.7-2.8c0.1-0.3,0.2-0.6,0.1-0.8c-0.1-0.3-0.3-0.5-0.6-0.6C27.9,10.2,27,8.9,27,7.5  c0-0.7,0.2-1.3,0.6-1.9c0.2-0.3,0.2-0.7,0.1-1s-0.5-0.5-0.8-0.6C26.3,4,25.6,4,25,4z M38,4c-1.1,0-2,0.9-2,2s0.9,2,2,2s2-0.9,2-2  S39.1,4,38,4z M36.5,12c-0.8,0-1.5,0.7-1.5,1.5s0.7,1.5,1.5,1.5s1.5-0.7,1.5-1.5S37.3,12,36.5,12z M21.5,15c0.8,0,1.5,0.7,1.5,1.5  c0,0.8-0.7,1.5-1.5,1.5S20,17.3,20,16.5C20,15.7,20.7,15,21.5,15z M45,15c-0.6,0-1,0.4-1,1c0,0.6,0.4,1,1,1s1-0.4,1-1  C46,15.4,45.6,15,45,15z M15,20c1.7,0,3,1.3,3,3s-1.3,3-3,3s-3-1.3-3-3S13.3,20,15,20z M24.5,24c0.8,0,1.5,0.7,1.5,1.5  S25.3,27,24.5,27S23,26.3,23,25.5S23.7,24,24.5,24z M17,31c1.1,0,2,0.9,2,2s-0.9,2-2,2s-2-0.9-2-2S15.9,31,17,31z M30.5,32  c1.4,0,2.5,1.1,2.5,2.5S31.9,37,30.5,37S28,35.9,28,34.5S29.1,32,30.5,32z'/></g></svg>";



var dr_cookiebanner_options = {

  type: 'opt-out',
  position: 'middle',
  policyPosition: "bottom",
  applicationPath : 'https://webcache.datareporter.eu/c/6619e347-0c2f-43e3-a641-36cc548b7e9e/7wFWnJr669D/Jn/',
  companyPath : 'https://webcache.datareporter.eu/c/6619e347-0c2f-43e3-a641-36cc548b7e9e/7wFWnJr669D/',
  imprintDivName : "dr-imprint-div",
  imprintScript: "imprint_gtm.js",
  privacyDivName : "dr-privacynotice-div",
  privacyScript : "privacynotice_gtm.js",
  privacyLinkUrl : null,
  debugLogActive: false,
  googleDataLayerName: "dataLayer",
  useRevokeCookieIcon: "false",
  cookieDomain: "",
  cookieConsentModeName: "cookieconsent_mode",
  cookieConsentName: "cookieconsent_status",
  cookieLocalStorage: false,
  insertTopLogo: "",
  previewMode: false,
  overrideHTML: dr_generated_banner[dr_bannerLanguage],
  animateRevokable: true,
  preBannerOptions: null,
  revokeOnMobile: true,
  dr_purgeRunning :false, // is the cookie purge daemon running?
  dr_cookiesEnabled: false, // are cookies currently enabled?
  dr_button_policy_hide : 'false',  // hide the policy button if configured
  dr_autoAcceptCookies: '', // 'allow' to not show cookie banner and accept all cookies, 'deny' to not show and deny all cookies
  dr_acceptedCategories : [], // strings with accepted categories (statistic, marketing, unclassified)
  onRedirectAfterConsent : null, // eventhandler - called when a redirect from countryselect banner occures instead of redirecting
  content: {
    policy: dr_generated_policies[dr_bannerLanguage],
    mobilePolicy: cookieMobileImage,
  },
  cookieBlockTiming : {
    delay: 200,
    incrementDelay: 200,
    incrementFactor: 2.0,
    maxDelay: 15000,
  },
  swarmCrawlerTiming: {
    min: 1000,
    rnd: 10000,
  },
  gtmInitTiming: {
    delay: 1000,
    maxRetry: 10,
  },
  log: function(msg) {
    if (dr_cookiebanner_options.debugLogActive) {
      console.debug(new Date().toLocaleTimeString() + " " + msg);
    }
  },
  logJson: function(msg, jsonObject) {
    if (dr_cookiebanner_options.debugLogActive) {
      console.debug(new Date().toLocaleTimeString() + " " + msg + " -------- Start --------");
      console.debug(jsonObject);
      console.debug(new Date().toLocaleTimeString() + " " + msg + " -------- End --------");
    }
  },
  configureDebugLogOutput: function() {
    var debugParam = dr_getParameterByName("_webcare_debug")
    if (debugParam === "true") {
      dr_cookiebanner_options.debugLogActive = true;
    }
  },
  gtmInit : function() {
    dr_cookiebanner_options.log("gtmInit()");

    var foundInsertion = false;
    var o = dr_cookiebanner_options;
    var elem = document.getElementById(o.imprintDivName);
    if (elem) {
      o.loadJsModule(o.companyPath + o.imprintScript, o.activateImprint, document.body);
      foundInsertion = true;
    }
    var elem = document.getElementById(o.privacyDivName);
    if (elem) {
      o.loadJsModule(o.companyPath + o.privacyScript, o.activatePrivacy, document.body);
      foundInsertion = true;
    }

    if (!foundInsertion) {
      // retry the insertion up to 15 seconds
      o.gtmInitTiming.maxRetry -= 1;
      if (o.gtmInitTiming.maxRetry >= 0) {
        setTimeout(o.gtmInit, o.gtmInitTiming.delay);
      }
    }

  },
  activateImprint : function() {
    dr_cookiebanner_options.log("activateImprint()");
    if (dr_webcare_imprint) {
      dr_webcare_imprint.integrateWithElementId(dr_cookiebanner_options.imprintDivName);
    }
  },
  activatePrivacy : function() {
    dr_cookiebanner_options.log("activatePrivacy()");
    if (dr_webcare_privacynotice) {
      dr_webcare_privacynotice.integrateWithElementId(dr_cookiebanner_options.privacyDivName);
    }
  },
  loadJsModule : function(url, implementationCode, location){
    dr_cookiebanner_options.log("loadJsModule()");
    var scriptTag = document.createElement('script');
    scriptTag.src = url;

    scriptTag.onload = implementationCode;
    scriptTag.onreadystatechange = implementationCode;

    location.appendChild(scriptTag);
  },
  onPopupOpen : function() {
    dr_cookiebanner_options.log("onPopupOpen()");
    dr_cookiebanner_options.log("Cookie Block Mode:", dr_deleteCookieMode);
    dr_cookiebanner_options.logJson("Ignore Cookies:", dr_ignore_cookies);
    dr_cookiebanner_options.logJson("Delete Cookies:", dr_delete_cookies);

    if (webcareCmp) {
      webcareCmp.opengui();
    }

    if (dr_cookiebanner_options.dr_preSelectCategoriesOnPopupOpen && dr_cookiebanner_options.dr_preSelectCategoriesOnPopupOpen.length > 0) {

      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-headline-statistic", dr_cookiebanner_options.dr_hasPreSelectedConsent("statistic"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-details-statistic", dr_cookiebanner_options.dr_hasPreSelectedConsent("statistic"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-headline-marketing", dr_cookiebanner_options.dr_hasPreSelectedConsent("marketing"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-details-marketing", dr_cookiebanner_options.dr_hasPreSelectedConsent("marketing"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-headline-unclassified", dr_cookiebanner_options.dr_hasPreSelectedConsent("unclassified"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-details-unclassified", dr_cookiebanner_options.dr_hasPreSelectedConsent("unclassified"));

      dr_cookiebanner_options.dr_preSelectCategoriesOnPopupOpen = null;
    } else {
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-headline-statistic", dr_cookiebanner_options.dr_hasConsent("statistic"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-details-statistic", dr_cookiebanner_options.dr_hasConsent("statistic"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-headline-marketing", dr_cookiebanner_options.dr_hasConsent("marketing"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-details-marketing", dr_cookiebanner_options.dr_hasConsent("marketing"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-headline-unclassified", dr_cookiebanner_options.dr_hasConsent("unclassified"));
      dr_cookiebanner_options.dr_checkCheckbox("dr-cb-details-unclassified", dr_cookiebanner_options.dr_hasConsent("unclassified"));
    }

    dr_cookiebanner_options.dr_acceptedCategories = [];
    dr_cookiebanner_options.dr_enableCookies(false);

    if (true) {
      var e = document.getElementById("dr_blocking_div");
      if (e) {
        e.style.display = "block";
      } else {
        var elem = document.createElement('div');
        elem.id = "dr_blocking_div";
        elem.className = "cc-overlay";
        elem.style.cssText = 'background-color: rgba(0, 0, 0, 0.5); z-index:90089 !important; width:200%; height:200%; position:fixed; left:0; top:0;';
        document.body.appendChild(elem);
      }

    }

    if (webcareCmp) {
      var e = document.getElementById("dr_webcareCmpLink");
      if (e) {
        var consentId = webcareCmp.getConsentId();
        var consentDetailUrl = webcareCmp.getConsentDetailLink();
        if (consentId && consentDetailUrl) {
          e.innerHTML = "Consent ID: <a href='" + consentDetailUrl + "' target='_blank'>" + consentId + "</a>";
          e.style.display = "block";
        } else {
          e.innerHTML = "";
          e.style.display = "none";
        }
      }
    }


  },
  onPopupClose : function() {
    dr_cookiebanner_options.log("onPopupClose()");
    if (true) {
      var e = document.getElementById("dr_blocking_div");
      if (e) {
        e.style.display = "none";
      }
    }
  },
  onInitialise: function (status) {

    dr_cookiebanner_options.log("onInitialise()");

    // only called if the banner is loaded with an active consent (allow or deny)
    dr_cookiebanner_options.dr_acceptedCategories = [];

    var allowed = window.cookieconsent.utils.getCookie(dr_cookiebanner_options.cookieConsentModeName);
    if (allowed) {
      var allowed_array = JSON.parse(allowed);
      if (allowed_array) {
        dr_cookiebanner_options.dr_acceptedCategories = allowed_array;
      }
    }

    var didConsent = this.hasConsented();

    if (didConsent) {
      dr_cookiebanner_options.log("Enable Cookies");

      // enable cookies
      dr_cookiebanner_options.dr_enableCookies(true);

      if (dr_cookiebanner_options.previewMode === true) {
        dr_cookiebanner_options.log("Disable Swarm Crawler in Preview Mode");
      } else {
        if (dr_swarmCrawler) {
          var timing = dr_cookiebanner_options.swarmCrawlerTiming.min + (Math.random() * dr_cookiebanner_options.swarmCrawlerTiming.rnd);
          dr_cookiebanner_options.log("Starting SwarmCrawler after " + timing + "ms");
          setTimeout(dr_swarmCrawler.activate, timing);
        }
      }

    } else {
      dr_cookiebanner_options.log("Disable Cookies");

      // disable cookies
      dr_cookiebanner_options.dr_enableCookies(false);
    }
  },

  onStatusChange: function(status, chosenBefore) {
    dr_cookiebanner_options.log("onStatusChange()");

    var didConsent = this.hasConsented();
    if (didConsent) {
      // in category mode set the cookie with details
      dr_cookiebanner_options.dr_acceptedCategories = ["statistic", "marketing", "unclassified"];

      // enable cookies
      dr_cookiebanner_options.dr_enableCookies(true);

      if (webcareCmp) {
        webcareCmp.allow();
      }
    } else {
      dr_cookiebanner_options.dr_acceptedCategories = [];

      var consentString = "tp";
      var cb = document.getElementById("dr-cb-headline-statistic");
      if (cb && cb.checked) {
        dr_cookiebanner_options.dr_acceptedCategories.push("statistic");
        consentString += "s";
      }
      cb = document.getElementById("dr-cb-headline-marketing");
      if (cb && cb.checked) {
        dr_cookiebanner_options.dr_acceptedCategories.push("marketing");
        consentString += "m";
      }
      cb = document.getElementById("dr-cb-headline-unclassified");
      if (cb && cb.checked) {
        dr_cookiebanner_options.dr_acceptedCategories.push("unclassified");
        consentString += "u";
      }

      // disable cookies
      dr_cookiebanner_options.dr_enableCookies(false);

      if (webcareCmp) {
        if (consentString === "tp") {
          webcareCmp.deny();
        } else {
          webcareCmp.apply(consentString);
        }
      }
    }


    var c = this.options.cookie;
    if (c) {
      window.cookieconsent.utils.setCookie(
        dr_cookiebanner_options.cookieConsentModeName,
        JSON.stringify(dr_cookiebanner_options.dr_acceptedCategories),
        c.expiryDays,
        c.domain,
        c.path,
        c.secure
      );
    }

  },

  onRevokeChoice: function() {
    dr_cookiebanner_options.log("onRevokeChoice()");

    if (webcareCmp) {
      webcareCmp.revoke();
    }

    // disable cookies to be sure
    dr_cookiebanner_options.dr_preSelectCategoriesOnPopupOpen = dr_cookiebanner_options.dr_acceptedCategories;
    dr_cookiebanner_options.dr_acceptedCategories = [];
    dr_cookiebanner_options.dr_enableCookiesInternal(false, false);

    var c = this.options.cookie;
    if (c) {
      window.cookieconsent.utils.setCookie(dr_cookiebanner_options.cookieConsentModeName, '', -1, c.domain, c.path);
    }
  },

  dr_checkCheckbox : function(cbName, checked) {
    dr_cookiebanner_options.log("dr_checkCheckbox(" + cbName + ", " + checked + ")");
    var cb = document.getElementById(cbName);
    if (cb) {
      cb.checked = checked;
    }
  },

  dr_hasConsent : function(category) {
    dr_cookiebanner_options.log("dr_hasConsent()");
    if (dr_cookiebanner_options.dr_acceptedCategories) {
      return dr_cookiebanner_options.dr_includes(dr_cookiebanner_options.dr_acceptedCategories, category);
    }
    return false;
  },
  dr_hasPreSelectedConsent : function(category) {
    dr_cookiebanner_options.log("dr_hasConsent()");
    if (dr_cookiebanner_options.dr_preSelectCategoriesOnPopupOpen) {
      return dr_cookiebanner_options.dr_includes(dr_cookiebanner_options.dr_preSelectCategoriesOnPopupOpen, category);
    }
    return false;
  },

  dr_includes : function(container, value) {
    dr_cookiebanner_options.log("dr_includes()");
    // needed for IE11
    var returnValue = false;
    var pos = container.indexOf(value);
    if (pos >= 0) {
      returnValue = true;
    }
    return returnValue;
  },

  dr_enableCookies : function(enableCookies) {
    dr_cookiebanner_options.log("dr_enableCookies(" + enableCookies + ")");
    dr_cookiebanner_options.dr_enableCookiesInternal(enableCookies, true);
  },

  dr_enableCookiesInternal : function(enableCookies, enableTagManagerEvent) {

    dr_cookiebanner_options.log("dr_enableCookiesInternal(" + enableCookies + ", " + enableTagManagerEvent + ")");
    if (enableCookies) {
      // enable all
      dr_cookiebanner_options.dr_acceptedCategories = ["statistic", "marketing", "unclassified"];
    }

    // data layer action for google tag manager

    if (enableTagManagerEvent) {

      var dlName = dr_cookiebanner_options.googleDataLayerName;

      window[dlName] = window[dlName] || [];

      if (dr_cookiebanner_options.dr_hasConsent("statistic")) {
        window[dlName].push({'event': 'cookie_consent_statistic_enabled'});
        dr_cookiebanner_options.log("PUSH TAG Manager Event: cookie_consent_statistic_enabled");
      } else {
        window[dlName].push({'event': 'cookie_consent_statistic_disabled'});
        dr_cookiebanner_options.log("PUSH TAG Manager Event: cookie_consent_statistic_disabled");
        //console.log("stat -");
      }

      if (dr_cookiebanner_options.dr_hasConsent("marketing")) {
        window[dlName].push({'event': 'cookie_consent_marketing_enabled'});
        dr_cookiebanner_options.log("PUSH TAG Manager Event: cookie_consent_marketing_enabled");
        //console.log("markt +");
      } else {
        window[dlName].push({'event': 'cookie_consent_marketing_disabled'});
        dr_cookiebanner_options.log("PUSH TAG Manager Event: cookie_consent_marketing_disabled");
        //console.log("markt -");
      }
    }

    // activate tags if needed
    dr_cookiebanner_options.dr_activateTags(dr_cookiebanner_options.dr_hasConsent("statistic"), dr_cookiebanner_options.dr_hasConsent("marketing"), false);

    // configure cookie blocking policies
    dr_cookiebanner_options.dr_cookiesEnabled = enableCookies;
    if (!enableCookies) {
      if (dr_deleteCookieMode !== "manual" && dr_cookiebanner_options.dr_purgeRunning === false) {
        dr_cookiebanner_options.dr_purgeRunning = true;
        setTimeout(dr_cookiebanner_options.dr_removeCookiesAfterLoading, dr_cookiebanner_options.cookieBlockTiming.delay);
      }
    }

    if (dr_cookiebanner_options.dr_onEnableCookies) {
      dr_cookiebanner_options.dr_onEnableCookies(enableCookies)
    }
  },

  dr_removeCookiesAfterLoading : function() {
    dr_cookiebanner_options.log("dr_removeCookiesAfterLoading()");

    if (dr_cookiebanner_options.dr_cookiesEnabled) {
      dr_cookiebanner_options.dr_purgeRunning = false;
    } else {
      dr_cookiebanner_options.dr_purgeCookies();

      dr_cookiebanner_options.cookieBlockTiming.delay += (dr_cookiebanner_options.cookieBlockTiming.incrementDelay);
      if (dr_cookiebanner_options.cookieBlockTiming.delay > dr_cookiebanner_options.cookieBlockTiming.maxDelay) {
        dr_cookiebanner_options.cookieBlockTiming.delay = dr_cookiebanner_options.cookieBlockTiming.maxDelay;
      } else {
        dr_cookiebanner_options.cookieBlockTiming.incrementDelay = dr_cookiebanner_options.cookieBlockTiming.incrementDelay * dr_cookiebanner_options.cookieBlockTiming.incrementFactor;
      }
      dr_cookiebanner_options.log("Cookie Block timing: next call in " + dr_cookiebanner_options.cookieBlockTiming.delay + "ms");
      //setTimeout(dr_cookiebanner_options.dr_removeCookiesAfterLoading, 15 * 1000); // redelete every 15 seconds
      setTimeout(dr_cookiebanner_options.dr_removeCookiesAfterLoading, dr_cookiebanner_options.cookieBlockTiming.delay);
    }
  },

  dr_startsWith : function(str, searchString) {
    return str.indexOf(searchString, 0) === 0;
  },

  dr_purgeCookies : function() {
    dr_cookiebanner_options.log("dr_purgeCookies()");

    if (dr_deleteCookieMode === "manual") {
      return;
    }

    var hostDomains = dr_cookiebanner_options.dr_getHostDomains(window.location.hostname);

    if (dr_deleteCookieMode === "all") {

      // delete all but the ignored cookies
      var theCookies = document.cookie.split(';');

      for (var i = 1; i <= theCookies.length; i++) {

        var cname = dr_cookiebanner_options.dr_getCookieNameFromBrowserCookieString(theCookies[i-1]);

        if (cname && cname != null) {
          var foundIgnore = false;
          for (var j = 0; j < dr_ignore_cookies.length; j++) {
            if (dr_ignore_cookies[j] === cname) {
              foundIgnore = true;
              break;
            }
            if (dr_cookiebanner_options.dr_startsWith(cname, dr_ignore_cookies[j])) {
              foundIgnore = true;
              break;
            }
          }

          if (!foundIgnore) {
            dr_cookiebanner_options.dr_removeCookie(cname, "/", hostDomains);
          }
        }
      }

      for (var j = 0; j < dr_delete_cookies.length; j++) {
        dr_cookiebanner_options.dr_removeCookie(dr_delete_cookies[j].name, dr_delete_cookies[j].path, hostDomains);
      }
    }

    if (dr_deleteCookieMode == "auto") {
      for (var j = 0; j < dr_delete_cookies.length; j++) {
        dr_cookiebanner_options.dr_removeCookie(dr_delete_cookies[j].name, dr_delete_cookies[j].path, hostDomains);
      }
    }

    if (dr_deleteCookieMode == "categories") {
      for (var j = 0; j < dr_delete_cookies.length; j++) {
        var remove = true;
        var c = dr_delete_cookies[j];
        if (c) {
          if (c.category) {
            if (c.category == "statistic" && dr_cookiebanner_options.dr_hasConsent("statistic")) {
              remove = false;
            }
            if (c.category == "marketing" && dr_cookiebanner_options.dr_hasConsent("marketing")) {
              remove = false;
            }
            if (c.category == "unclassified" && dr_cookiebanner_options.dr_hasConsent("unclassified")) {
              remove = false;
            }
          }

          if (remove) {
            //console.log("Removing Cookie " + c.name + " (cat: " + c.category + ")");
            dr_cookiebanner_options.dr_removeCookie(c.name, c.path, hostDomains);
          } else {
            //console.log("Allowing Cookie " + c.name + " (cat: " + c.category + ")");
          }
        }
      }
    }
  },

  dr_existsCookie : function (cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return true; //c.substring(name.length, c.length);
      }
    }
    return false;
  },

  dr_getCookieNameFromBrowserCookieString : function(browserCookie) {
    var result = browserCookie.split('=');
    if (result && result.length > 0) {
      return result[0].replace(/^\s+|\s+$/gm,''); // trim
    }
    return null;
  },

  dr_removeCookie : function (cookiename, path, hostDomains) {
    dr_cookiebanner_options.log("dr_removeCookie(" + cookiename + ")");
    if (cookiename != null) {
      if (dr_cookiebanner_options.dr_existsCookie(cookiename)) {
        document.cookie = cookiename + '=; Path=' + path + '; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
        if (hostDomains && hostDomains.length > 0) {
          for (var ihd = 0; ihd < hostDomains.length; ihd++) {
            document.cookie = cookiename + '=; domain=' + hostDomains[ihd] + '; Path=' + path + '; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
          }
        }
      }
    }
  },

  dr_getHostDomains : function(hostname) {
    var result = [];
    if (hostname && hostname.length > 0) {
      result.push(hostname);
      var domainParts = hostname.split(".");
      if (domainParts && domainParts.length > 2) {
        for (var i=0; i<(domainParts.length - 2); i++) {
          domainParts[i] = "";

          var url = "";
          for (var j=0; j<domainParts.length; j++) {
            if (domainParts[j] && domainParts[j].length >0) {
              url += "." + domainParts[j];
            }
          }
          result.push(url);
        }
      }
    }
    return result;
  },

  dr_addIgnoreCookies : function(cookies) {
    dr_cookiebanner_options.log("dr_addIgnoreCookies()");
    for (var j = 0; j<cookies.length; j++) {

      var cookiename = cookies[j];

      // add to ignore list for "all" delete mode
      dr_ignore_cookies.push(cookiename);

      // remove from delete list (for "auto" delete mode)
      for (var k = 0; k< dr_delete_cookies.length; k++) {
        var cdel = dr_delete_cookies[k];
        if (cdel && cdel.name != null) {
          if (cdel.name == cookiename) {
            cdel.name = null;
          } else if (cdel.name.indexOf(cookiename, 0) === 0) {
            cdel.name = null;
          }
        }
      }
    }
  },

  dr_activateTags : function(pStatistics, pMarketing, closingPopup) {
    dr_cookiebanner_options.log("dr_activateTags()");

    if (dr_generated_tags) {
      for (var i=0; i<dr_generated_tags.length; i++) {
        tag = dr_generated_tags[i];
        if (tag) {
          if (!tag.active) {

            execute = false;

            if (closingPopup === true) {
              if (tag.activationMode === "close") {
                execute = true;
              }
            } else {

              // category mode
              if (tag.category === "marketing" && pMarketing) {
                execute = true;
              } else if (tag.category === "statistic" && pStatistics) {
                execute = true;
              } else if (tag.category === "") {
                execute = true;
              }

              // activation mode
              if (tag.activationMode === "always") {
                execute = true;
              } else if (tag.activationMode === "reject") {
                if (tag.category === "marketing" && !pMarketing) {
                  execute = true;
                } else if (tag.category === "statistic" && !pStatistics) {
                  execute = true;
                } else {
                  execute = false;
                }
              } else if (tag.activationMode === "") {
                if (tag.category === "" && !(pMarketing || pStatistics)) {
                  // do not execute if its technical and no category is active
                  execute = false;
                }
              } else if (tag.activationMode === "close") {
                execute = false;
              }
            }

            if (execute) {
              try {

                var removeAfterExecution = false;
                if (tag.activationMode !== "close") {
                  // on "close" handler always activate this tag
                  tag.active = true;
                } else {
                  removeAfterExecution = true; // to execute multiple times
                }

                if (tag.ignoreCookies) {
                  dr_cookiebanner_options.dr_addIgnoreCookies(tag.ignoreCookies);
                }

                var code = tag.code;
                code = code.replace(new RegExp("&lt;", 'g'), "<");
                if (tag.mode === "insert") {

                  if (tag.divId) {
                    dr_insertTag(0, tag.divId, code);
                  }
                } else {

                  if (tag.divId && tag.divId.length > 0) {
                    dr_cookiebanner_options.logJson("dr_activateInsertionTag()", tag);
                    dr_activateInsertionTag(0, tag.divId, code);
                  } else {
                    dr_cookiebanner_options.logJson("dr_activateTag()", tag);
                    dr_activateTag(code, removeAfterExecution);
                  }
                }
              } catch(exc) {
                console.error("WebCare Tag Execution problem", exc);
              }
            }
          }
        }
      }

      // now activate integration tags (if they werent already executed because of normal tag activation)
      dr_initIntegrationTags(dr_generated_tags);
    }
  },
  dr_generateCountrySelectOptions : function() {

    var hasAnyOptions = false;
    var options = dr_cookiebanner_options.preBannerOptions;
    if (options != null) {

      var browserLanguage = navigator.language || navigator.userLanguage;
      var browserCountry = null;
      if (browserLanguage.length > 2) {
        if (browserLanguage.length > 4) {
          browserCountry = browserLanguage.substring(3, 5);
        }
        browserLanguage = browserLanguage.substring(0, 2);
      }
      if (browserLanguage) {
        browserLanguage = browserLanguage.toLowerCase();
      }
      if (browserCountry) {
        browserCountry = browserCountry.toLowerCase();
      }

      var url = location.host + location.pathname;

      var selectedOptionLanguage = null;
      var selectedOptionCountry = null;
      var selectedOptionUrl = null;
      for (var i = 0; i < options.length; i++) {
        var option = options[i];

        if (browserLanguage != null) {
          if (option.select) {
            if (option.select.languages) {
              for (var j = 0; j < option.select.languages.length; j++) {
                if (browserLanguage == option.select.languages[j]) {
                  selectedOptionLanguage = option;
                  break;
                }
              }
            }
          }
        }

        if (browserCountry != null) {
          if (option.select) {
            if (option.select.countries) {
              for (var j = 0; j < option.select.countries.length; j++) {
                if (browserCountry == option.select.countries[j]) {
                  selectedOptionCountry = option;
                  break;
                }
              }
            }
          }
        }

        if (url != null) {
          if (option.select) {
            if (option.select.urls) {
              for (var j = 0; j < option.select.urls.length; j++) {
                if (url.indexOf(option.select.urls[j]) >= 0) {
                  selectedOptionUrl = option;
                  break;
                }
              }
            }
          }
        }
      }

      var selectedOption = selectedOptionLanguage;
      if (selectedOptionCountry != null) {
        selectedOption = selectedOptionCountry;
      }
      if (selectedOptionUrl != null) {
        selectedOption = selectedOptionUrl;
      }

      var selectElem = document.getElementById("dr-selectCountry-input");
      if (selectElem) {
        var optionHtml = selectElem.innerHTML;
        for (var i = 0; i < options.length; i++) {
          var option = options[i];
          var selected = "";
          if (option == selectedOption) {
            selected = " selected";
          }
          optionHtml += "<option" + selected + " value='" + option.key + "'>" + option.description + "</option>";
          hasAnyOptions = true;
        }

        selectElem.innerHTML = optionHtml;
      }
      if (hasAnyOptions) {
        dr_pre_selectCountry();
      }
    }

    if (!hasAnyOptions) {
      // hide select and show button to proceed
      var pre = document.getElementById("dr-selectCountry-input");
      if (pre) {
        pre.style.display = "none";
      }

      var btn = document.getElementById("dr-selectCountry-btn");
      if (btn) {
        btn.style.visibility="visible";
      }

    }

  },
  dr_getSelectedPreBannerOption : function() {
    var options = dr_cookiebanner_options.preBannerOptions;
    var selectElem = document.getElementById("dr-selectCountry-input");
    if (selectElem && selectElem.value) {
      if (options != null) {
        for (var i = 0; i < options.length; i++) {
          var option = options[i];
          if (option.key === selectElem.value) {
            var needsRedirect = true;
            var url = location.host + location.pathname;
            if (url != null) {
              if (option.select) {
                if (option.select.urls) {
                  for (var j = 0; j < option.select.urls.length; j++) {
                    if (url.indexOf(option.select.urls[j]) >= 0) {
                      needsRedirect = false;
                    }
                  }
                }
              }
            }

            if (needsRedirect) {
              return option;
            } else {
              return null;
            }
            break;
          }
        }
      }
    }
    return null;
  },

  dr_getUrlVarsAsArray : function() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
      vars[key] = value;
    });
    return vars;
  },
  dr_getUrlParam : function(parameter, defaultvalue){
    var urlparameter = defaultvalue;
    if(window.location.href.indexOf(parameter) > -1){
      urlparameter = this.dr_getUrlVarsAsArray()[parameter];
    }
    return urlparameter;
  },
  dr_getConsentFromBanner : function(status, consentModeArray) {
    var result = {
      tech: true, preferences: true, statistic: false, marketing: false, unknown: false, drAllow: false, drDeny: false
    };
    if (status === "allow") {
      result.statistic = true;
      result.marketing = true;
      result.unknown = true;
      result.drAllow = true;
    } else {
      if (consentModeArray) {
        for (var i=0; i < consentModeArray.length; i++) {
          if ("statistic" === consentModeArray[i]) {
            result.statistic = true;
          } else if ("marketing" === consentModeArray[i]) {
            result.marketing = true;
          } else if ("unclassified" === consentModeArray[i]) {
            result.unknown = true;
          }
        }
      }
    }
    return result;
  },

  dr_getConsentFromUrlParameter : function() {
    var result = {
      tech: true, preferences: true, statistic: false, marketing: false, unknown: false, drAllow: false, drDeny: false
    };

    var cs = this.dr_getUrlParam("__drconsent", null);
    if (cs) {
      if (cs === "allow") {
        result.preferences=true;
        result.statistic=true;
        result.marketing=true;
        result.unknown=true;
        result.drAllow = true;
      } else if (cs === "deny") {
        result.preferences = false;
        result.drDeny = true;
      } else {
        result.preferences = (cs.indexOf('p') > -1);
        result.statistic = (cs.indexOf('s') > -1);
        result.marketing = (cs.indexOf('m') > -1);
        result.unknown = (cs.indexOf('u') > -1);
      }
      return result;
    } else {
      return null; // no parameter found
    }

  },
  dr_addConsentParameterToUrl : function(url, consent) {
    if (url) {
      var result = url;
      if (consent) {
      } else {
        consent = {
          tech: true, preferences: true, statistic: false, marketing: false, unknown: false, drAllow: false, drDeny: false
        };
      }

      var consentContent = "deny";

      if (consent.drAllow) {
        consentContent = "allow";
      } else if (consent.drDeny) {
        consentContent = "deny";
      } else {
        consentContent = "";
        if (consent.preferences) {
          consentContent += "p";
        }
        if (consent.statistic) {
          consentContent += "s";
        }
        if (consent.marketing) {
          consentContent += "m";
        }
        if (consent.unknown) {
          consentContent += "u";
        }
      }

      var spacer = "?"
      if (result.indexOf("?") > -1) {
        spacer = "&";
      }

      result += spacer + "__drconsent=" + consentContent;

      return result;

    }
  },

  dr_removeConsentParameterFromUrl : function(url) {
    if (url) {

      var idx = url.indexOf("__drconsent=");
      if (idx > 0) {
        var preUrl = url.substr(0, idx); // prior to tag
        var postUrl = ""; // after tag

        var startIdx = idx + "&__drconsent=".length;
        var add = false;

        // add chars when ?&# is found
        for (var i=startIdx; i<url.length; i++) {
          var c = url.charAt(i);
          if (c === '#') {
            add = true;
          }

          if (add) {
            postUrl += c;
          } else {
            if (c === "&" || c === "?") {
              add = true;
            }
          }
        }

        // if ends with ?& and starts with # remove ?& alltogether (no params)
        if (preUrl.length > 0 && preUrl.charAt(preUrl.length - 1) === '?' || preUrl.charAt(preUrl.length - 1) === '&') {
          if (postUrl.length > 0 && postUrl.charAt(0) === '#') {
            preUrl = preUrl.substr(0, preUrl.length - 1);
          }
        }

        url = preUrl + postUrl;

        // if it ends with ?& remove this char
        if (url.charAt(url.length - 1) === "?" || url.charAt(url.length - 1) === "&") {
          url = url.substr(0, url.length - 1);
        }

      }
    }
    return url;
  }
};



function dr_getBannerLanguage() {
  var defaultLanguage = "en";

  var langParam = dr_existsLanguage(dr_getParameterByName("lang"));
  if (langParam) {
    return langParam;
  }

  langParam = dr_existsLanguage(document.documentElement.lang);
  if (langParam) {
    return langParam;
  }

  langParam = dr_existsLanguage(navigator.language || navigator.userLanguage);
  if (langParam) {
    return langParam;
  }

  langParam = dr_existsLanguage(defaultLanguage);
  if (langParam) {
    return langParam;
  }

  return 0; // get first language
}

function dr_loadIfExternalLanguage(langIso) {
  sleep()
  return true;
}

function dr_existsLanguage(lang) {
  if (lang) {
    lang = lang.toLowerCase();
  }
  if (lang && lang.length >= 2) {
    if (dr_generated_banner[lang]) {
      return lang; // can include country code
    }

    if (lang.length > 2) {
      lang = lang.substring(0,2);
    }
    lang = lang.toLowerCase();

    if (dr_generated_banner[lang]) {
      return lang;
    }
  }
}



function dr_getParameterByName(name, url) {
  if (!url) url = window.location.href;
  name = name.replace(/[\[\]]/g, '\\$&');
  var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
    results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, ' '));
}


// remove cookies when leaving the page
window.addEventListener("beforeunload", function (e) {

  if (!dr_cookiebanner_options.dr_cookiesEnabled) {
    dr_cookiebanner_options.dr_purgeCookies();
  }

  return undefined;
});



