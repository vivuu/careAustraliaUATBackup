const LOADING_EVENT_NAME = 'loading';
const CONTINUE_EVENT_NAME = 'continue';
const PAY_EVENT_NAME = 'pay';

export class LoadEvent extends CustomEvent {
    constructor(isLoading) {
        super(LoadEvent.type, {
            detail: isLoading
        });
    }
    
    static get type() {
        return LOADING_EVENT_NAME;
    }
}

export class ContinueEvent extends CustomEvent {
    constructor(token, rdToken) {
        super(ContinueEvent.type, {
            detail: {
                token: token,
                rdToken: rdToken
            }
        });
    }
    
    static get type() {
        return CONTINUE_EVENT_NAME;
    }
}

export class PayEvent extends CustomEvent {
    constructor(token) {
        super(PayEvent.type, {
            detail: token
        });
    }
    
    static get type() {
        return PAY_EVENT_NAME;
    }
}