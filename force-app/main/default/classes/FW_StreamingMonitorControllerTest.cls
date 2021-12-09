@isTest
public class FW_StreamingMonitorControllerTest {
    
    @isTest
    static void publishPlatformEventShouldFailWhenEventNameIsUnknownSObject() {
        FW_StreamingMonitorController streamingController = new FW_StreamingMonitorController();
        try {
            FW_StreamingMonitorController.publishPlatformEvent('unknown', null);
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException);
        }
    }

    @isTest
    static void publishPlatformEventShouldFailWhenEventNameIsNotPlatformEvent() {
        try {
            FW_StreamingMonitorController.publishPlatformEvent('Account', '{}');
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException);
        }
    }

    @isTest
    static void publishPlatformEventShouldFailWhenPayloadIsInvalidJson() {
        try {
            FW_StreamingMonitorController.publishPlatformEvent('Account', 'invalid');
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException);
        }
    }

    @isTest
    static void publishGenericEventShouldFailWhenInvalidEventName() {
        try {
            FW_StreamingMonitorController.publishGenericEvent('unknown', null);
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException);
        }
    }

    @isTest
    static void publishGenericEventShouldWork() {
        Test.setMock(HttpCalloutMock.class, new FW_GenericEventPostMock(200));        
        insert new StreamingChannel(Name= '/u/TestSC');
        
        FW_StreamingMonitorController.publishGenericEvent('TestSC', 'TestPayload');

        List<AsyncApexJob> jobs = [SELECT Status,NumberOfErrors FROM AsyncApexJob LIMIT 1000];
        System.assertEquals(1, jobs.size(), 'Expected an AsyncApexJob');
    }

    @isTest
    static void queueableGenericEventPostShouldFailWhenRestCallFails() {
        Test.setMock(HttpCalloutMock.class, new FW_GenericEventPostMock(500));        
        FW_StreamingMonitorController.QueueableGenericEventPost post = new FW_StreamingMonitorController.QueueableGenericEventPost('/u/TestSC', 'TestPayload');

        try {
            post.execute(null);
            System.assert(false, 'Exception was expected');
        } catch (Exception e) {
            System.assert(e instanceof CalloutException);
        }
    }

    @isTest
    static void getAllEventChannelsShouldWork() {
        Map<String, List<FW_StreamingMonitorController.ComboBoxItem>> channels = FW_StreamingMonitorController.getAllEventChannels();
        System.assert(!channels.isEmpty(), 'Expected a list of channels');
    }

    @isTest
    static void getPushTopicEventChannelsShouldWork() {
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = 'TestPT';
        pushTopic.Query = 'SELECT Id, Name FROM Account';
        pushTopic.ApiVersion = 46.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = true;
        pushTopic.NotifyForOperationUndelete = true;
        pushTopic.NotifyForOperationDelete = true;
        pushTopic.NotifyForFields = 'Referenced';
        insert pushTopic;

        List<FW_StreamingMonitorController.ComboBoxItem> channels = FW_StreamingMonitorController.getPushTopicEventChannels();
        System.assertEquals(1, channels.size());
        System.assertEquals('TestPT', channels.get(0).value);
    }

    @isTest
    static void getGenericEventChannelsShouldWork() {
        insert new StreamingChannel(Name= '/u/TestSC');
        List<FW_StreamingMonitorController.ComboBoxItem> channels = FW_StreamingMonitorController.getGenericEventChannels();
        System.assertEquals(1, channels.size());
        System.assertEquals('TestSC', channels.get(0).value);
    }
}