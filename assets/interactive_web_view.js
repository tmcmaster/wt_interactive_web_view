class HtmlEventBus {
    constructor(config = {}) {
        this.cfg = {
            ...config
        };

        console.log('HtmlEventBus: Initialising EventBus', this.cfg);
        
        this.eventListenerMap = {};
        const self = this;
        window._EventBusInitialise = function (webViewName) {
            console.log('HtmlEventBus: Web View Name:', webViewName);
            window._EventBusInitialise = function () {
                console.log("HtmlEventBus: Call _stateSet only once!");
            };
            self.initialise();
        }
    }

    // Setup  connection with Flutter
    initialise() {
        console.log('HtmlEventBus.initialise: ');
        window.addEventListener('message', this._eventFromIframe.bind(this));
        window._EventBusState.addFlutterListener(this._eventFromFlutter.bind(this));
    }

    // Disconnect connection with Flutter
    dispose() {
        console.log('HtmlEventBus.dispose: ');
        window.addEventListener(this._eventFromIframe);
        window._EventBusState.removeFlutterListener(this._eventFromFlutter.bind(this));
    }

    publishEvent(event) {
        console.log('HtmlEventBus.publishEvent: ', event);
        this._publishEvent({
            source: 'html',
            type: event.type,
            data: event.data,
        });
    }

    addEventListener(eventType, listener) {
        (this.eventListenerMap[eventType] ??= []).push(listener);
    }

    removeEventListener(eventType, listener) {
        const listeners = this.eventListenerMap[eventType];
        if (listeners) {
            const index = listeners.indexOf(listener);
            if (index !== -1) {
                listeners.splice(index, 1);
            }
            if (listeners.length === 0) {
                delete this.eventListenerMap[eventType];
            }
        }
    }

    _publishEvent(event) {
        console.log('HtmlEventBus.publishEvent: ', event);
        setTimeout(() => {
            this._emitToHtml(event);
            this._emitToIframe(event);
            this._emitToFlutter(event);
        }, 1);
    }

    _eventFromIframe(event) {
        const eventData = event.data;
        console.log('HtmlEventBus.eventFromIframe: ', eventData);
        this._publishEvent({
            source: 'iframe',
            type: eventData.type,
            data: eventData.data,
        });
    }

    _eventFromFlutter(eventString) {
        const event = JSON.parse(eventString);
        console.log('HtmlEventBus.eventFromFlutter: ', event);
        this._publishEvent({
            source: 'flutter',
            type: event.type,
            data: event.data,
        });
    }

    _emitToHtml(event) {
        if (event.source !== 'html') {
            console.log('HtmlEventBus.emitToHtml: ', event);
            (this.eventListenerMap[event.type] ?? [])
                .forEach(listener => listener(event));
        }
    }

    _emitToIframe(event) {
        if (event.source !== 'iframe') {
            console.log('HtmlEventBus.emitToIframe: ', event);
            const iframe = document.querySelector(`iframe`);
            if (iframe && iframe.contentWindow) {
                iframe.contentWindow.postMessage(event, '*');
            }
        }
    }

    _emitToFlutter(event) {
        if (event.source !== 'flutter') {
            console.log('HtmlEventBus.emitToFlutter: ', event);
            window._EventBusState.emitToFlutter(JSON.stringify(event));
        }
    }
}

let htmlEventBus = null;
function useHtmlEventBus() {
    if (!htmlEventBus) {
        htmlEventBus = new HtmlEventBus();
    }
    return htmlEventBus;
}


class IframeEventBus {
  constructor() {
    console.log('IframeEventBus: constructor');
    this.events = {};
    window.addEventListener('message', this.receiveEvent.bind(this));
  }

  addEventListener(eventType, listener) {
    console.log('IframeEventBus.addEventListener: ', eventType);
    if (!this.events[eventType]) {
      this.events[eventType] = [];
    }
    this.events[eventType].push(listener);
  }

  removeEventListener(eventType, listenerToRemove) {
    console.log('IframeEventBus.removeEventListener: ', eventType);
    if (!this.events[eventType]) return;
    this.events[eventType] = this.events[eventType].filter(listener => listener !== listenerToRemove);
  }

  receiveEvent(event) {
    console.log('IframeEventBus.receiveEvent: ', event.data);
    const eventType = event.data.type;
    const listenerList = this.events[eventType];
    if (listenerList) {
        listenerList.forEach((listener) => {
            listener(event.data);
        });
    }
  }

  publishEvent(event) {
    console.log('IframeEventBus.publishEvent: ', event);
     window.parent.postMessage(event, '*');
  }
}

let iframeEventBus = null;
function useIframeEventBus() {
    if (!iframeEventBus) {
        iframeEventBus = new IframeEventBus();
    }
    return iframeEventBus;
}


function flutterInit(config = {}) {
    const cfg = {
        iframeId: 'wt_interactive_web_view',
        flutterId: 'flutter_target',
        initFunction: '_EventBusState',
        eventBus: false,
        ...config
    };

    return new Promise((accept,reject) => {
        window.addEventListener('load', function() {
            const { iframeId, flutterId, eventBus } = cfg;

            const htmlEventBus = new HtmlEventBus(cfg);

            _flutter.loader.loadEntrypoint({
                serviceWorker: {
                    serviceWorkerVersion: serviceWorkerVersion,
                },
                onEntrypointLoaded: function(engineInitializer) {
                    engineInitializer.initializeEngine({
                        hostElement: document.querySelector(`#${flutterId}`),
                    }).then(function(appRunner) {
                        appRunner.runApp();
                    });
                }
            });

            accept(eventBus ? htmlEventBus : null);
        });
    });
}

export { flutterInit, useIframeEventBus, useHtmlEventBus };