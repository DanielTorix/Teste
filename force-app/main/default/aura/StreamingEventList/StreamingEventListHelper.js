({
    subscribe : function(component, channel, replayId) {
        const empApi = component.find('empApi');
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Log and notify about event
            this.notify(component, 'success', 'Received event '+ eventReceived.channel);
            // Save event
            this.saveEvent(component, eventReceived);
        }))
        .then(subscription => {
            // Log and notify about subscription
            this.notify(component, 'success', 'Subscribed to channel ' + subscription.channel);
            this.fireMonitorEvent('subscribeConfirm', subscription);
        });
    },

    unsubscribe : function(component, subscription) {
        const empApi = component.find('empApi');
        empApi.unsubscribe(subscription, $A.getCallback(unsubscribe => {
            this.notify(component, 'success', 'Unsuscribed from: ' + unsubscribe.subscription);
        }));
    },

    saveEvent : function(component, evt) {
        // Build id for datatable
        let id = '';
        if (typeof evt.data.schema !== 'undefined') { // Generic event does not support schema Id
            id = evt.data.schema;
        } else {
            id = evt.channel;
        }
        id += evt.data.event.replayId;
        // Extract time from event
        let time = null;
        if (typeof evt.data.event.createdDate !== 'undefined') { // Generic event and PushTopic
            time = new Date(evt.data.event.createdDate);
        } else if (typeof evt.data.payload.ChangeEventHeader !== 'undefined') { // CDC
            time = new Date(evt.data.payload.ChangeEventHeader.commitTimestamp);
        } else if (typeof evt.data.payload.CreatedDate !== 'undefined') { // Platform Event
            time = new Date(evt.data.payload.CreatedDate);
        }
        // Assemble payload
        let payload = null;
        if (typeof evt.data.payload !== 'undefined') {
            payload = evt.data.payload;
        } else if (typeof evt.data.sobject !== 'undefined') { // PushTopic
            payload = evt.data.sobject;
        }
        // Build event row
        const eventRow = {
            id,
            time: $A.localizationService.formatDate(time, 'yyyy-MM-dd HH:mm:ss'),
            channel: evt.channel,
            replayId: evt.data.event.replayId,
            payload: JSON.stringify(payload),
        };
        // Append row to table
        const receivedEvents = component.get('v.receivedEvents');
        receivedEvents.unshift(eventRow);
        component.set('v.receivedEvents', receivedEvents);
        component.set('v.oldReceivedEvents', receivedEvents);
    },

    showEventDetails : function(component, eventData) {
        $A.createComponent('c:StreamingEventModal', { eventData }, (content, status, errorMessage) => {
            if (status === 'SUCCESS') {
                const body = content;
                component.find('overlayLib').showCustomModal({
                    header: 'Event details',
                    body,
                    showCloseButton: true
                });
            } else if (status === 'ERROR') {
                console.error('Error: ' + errorMessage);
            }
        });
    },

    notify : function(component, type, message) {
        component.find('notifLib').showToast({
            variant: type,
            title: message
        });
    },
    
    fireMonitorEvent : function(action, params) {
        const monitorEvent = $A.get('e.c:StreamingMonitorEvent');
        monitorEvent.setParams({ action, params });
        monitorEvent.fire();
    },

    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.receivedEvents");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.receivedEvents", data);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})