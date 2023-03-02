import {LightningElement} from 'lwc';
import basePath from '@salesforce/community/basePath';

export default class Stripe extends LightningElement {
    connectedCallback() {
        let messageHandler = this.messageHandler.bind(this);
        window.addEventListener('message', messageHandler);
    }

    messageHandler(message) {
        if (message.origin == self.location.origin && message.data) {
            console.log('Received a message', message.data);
        }
    }

    submitPayment(event) {
        event.preventDefault();
        this.template.querySelector('iframe').contentWindow.postMessage('test', '*');
    }

    get stripeIframeUrl() {
        return this.basePath();
    }

    basePath() {
        // removes the /s at the end if present
        console.log('basePath', basePath);
        let baseCommunityPath = basePath.replace(/\/s$/, '');
        console.log('replaced', baseCommunityPath);
        return `${baseCommunityPath}/StripeContainer`; // TODO don't hardcode the name!
    }
}