public class TaskUpdateChatTranscript {
    
    
    public static String getS3EndPointURL(Task tsk, Integer manageMinute){
        String chatTranscriptURL='callout:AWS_S3/'+Label.AmazonChatInstance+'/ChatTranscripts/'+tsk.CreatedDate.format('YYYY/MM/dd');
        chatTranscriptURL+='/'+tsk.CallObject;
        String utcDateTime = +'_'+tsk.CreatedDate.addMinutes(manageMinute).format('yyyy-MM-dd\'T\'HH:mm', 'UTC');
        utcDateTime=utcDateTime.replace('-','');
        utcDateTime=utcDateTime.replace(':','%3A');
        //System.debug('UTC datetime: ' + utcDateTime);
        chatTranscriptURL+=utcDateTime+'_UTC.json';
        return chatTranscriptURL;
    }
    
    public static String getChatTranscript(String s3Endpoint){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(s3Endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        if(!Test.isRunningTest()){
            res = http.send(req);
            //System.debug('### Response Status - StatusCode - Body:'+res.getStatus()+' - '+res.getStatusCode()+' - '+res.getBody());
            if(res.getStatusCode()==404){ return '404'; } else { return res.getBody(); }
        }else{
            return '{"Version":"2019-08-26","AWSAccountId":"855196461275","InstanceId":"2d5314e5-802f-4c63-a3a4-36d6b522267f","InitialContactId":"6b6bda6f-911f-4ad0-8350-57e1c2e79982","ContactId":"e16cd9a2-c85d-41e4-845e-fafdc69e45b8","Participants":[{"ParticipantId":"762cd2d9-882f-42e6-b833-e149978206cc"},{"ParticipantId":"55c28258-4a51-4e88-b8b5-f17cf58830d0"},{"ParticipantId":"d281e526-87a5-4529-ad37-fba0933f7c79"}],"Transcript":[{"AbsoluteTime":"2023-04-12T02:08:36.987Z","Content":"The chat has been disconnected. If you send a message in the next 15 minutes, the chat will pick up where it left off. Sorry for the inconvenience, please leave your phone number or Email Address, and someone will get back to you as soon as possible.","ContentType":"text/plain","Id":"5806bcc7-f352-440a-b270-7dc9826a2ce0","Type":"MESSAGE","ParticipantId":"55c28258-4a51-4e88-b8b5-f17cf58830d0","DisplayName":"SYSTEM_MESSAGE","ParticipantRole":"SYSTEM"},{"AbsoluteTime":"2023-04-12T02:12:08.269Z","Content":"one more chat","ContentType":"text/markdown","Id":"4de35070-0a4a-4349-8e96-ca84418b5f3d","Type":"MESSAGE","ParticipantId":"762cd2d9-882f-42e6-b833-e149978206cc","DisplayName":"Customer","ParticipantRole":"CUSTOMER"},{"AbsoluteTime":"2023-04-12T02:12:08.784Z","Content":"You are now being transferred to queue to chat with another agent.","ContentType":"text/plain","Id":"82b01e18-02b5-4f15-9922-674a53fa1847","Type":"MESSAGE","ParticipantId":"55c28258-4a51-4e88-b8b5-f17cf58830d0","DisplayName":"SYSTEM_MESSAGE","ParticipantRole":"SYSTEM"},{"AbsoluteTime":"2023-04-12T02:12:12.308Z","Content":"All agents are currently busy.","ContentType":"text/plain","Id":"481363e2-3181-44ef-a5e2-0345e6366415","Type":"MESSAGE","ParticipantId":"55c28258-4a51-4e88-b8b5-f17cf58830d0","DisplayName":"SYSTEM_MESSAGE","ParticipantRole":"SYSTEM"},{"AbsoluteTime":"2023-04-12T02:12:13.779Z","ContentType":"application/vnd.amazonaws.connect.event.participant.joined","Id":"d937b33d-27f1-4516-b6ef-67a4c8379716","Type":"EVENT","ParticipantId":"d281e526-87a5-4529-ad37-fba0933f7c79","DisplayName":"Gavin","ParticipantRole":"AGENT"},{"AbsoluteTime":"2023-04-12T02:12:32.263Z","Content":"some more chat","ContentType":"text/markdown","Id":"5902d1c9-70c5-4bc7-9017-fec4da01f66a","Type":"MESSAGE","ParticipantId":"d281e526-87a5-4529-ad37-fba0933f7c79","DisplayName":"Gavin","ParticipantRole":"AGENT"},{"AbsoluteTime":"2023-04-12T02:12:42.251Z","ContentType":"application/vnd.amazonaws.connect.event.participant.left","Id":"9ffa3b86-31b2-4da6-9440-c86dec7a287e","Type":"EVENT","ParticipantId":"d281e526-87a5-4529-ad37-fba0933f7c79","DisplayName":"Gavin","ParticipantRole":"AGENT"}]}';
        }
    }
    
    @AuraEnabled
    public static String updateChatTranscript(String tskId){
        try {
            list<Task> tskList = [Select Id, Type, Subject, Description, CallObject, CreatedDate From Task Where Id=:tskId limit 1];
            Task result = tskList != null && tskList.size()>0 ? tskList[0] : new Task();
            system.debug('### task data: '+result);
            if(result != null && result.Id != null && result.Type=='Chat'){
                String s3Endpoint = getS3EndPointURL(result, 0);
                system.debug('### s3Endpoint: '+s3Endpoint);
                result.Chat_Transcript_URL__c=s3Endpoint;
                String chatString=getChatTranscript(s3Endpoint);
                
                if(chatString != null && chatString=='404'){
                    s3Endpoint = getS3EndPointURL(result, -1);
                    system.debug('### s3Endpoint: '+s3Endpoint);
                    result.Chat_Transcript_URL__c=s3Endpoint;
                    chatString=getChatTranscript(s3Endpoint);
                }
                
                if(chatString != null && chatString.trim().length()>0 && chatString != '404'){
                    //chatString=chatString.escapeEcmaScript();
                    if(chatString.contains('\n')){
                        chatString=chatString.replace('\n', ' ');
                    }
                    AmazonChatTranscriptModel data = AmazonChatTranscriptModel.parse(chatString);
                    //system.debug('### Data parsed successfully');
                    if(data.InitialContactId != null && data.InitialContactId.trim().length()>0){
                        //system.debug('### data.InitialContactId: '+data.InitialContactId);
                        if(result.Description==null){result.Description='';}
                        if(data.Transcript != null && data.Transcript.size()>0){
                            String chatStartTxt='';
                            String chatEndTxt='';
                            String chatConversation='';
                            for(AmazonChatTranscriptModel.Transcript chat: data.Transcript){
                                String chatMessage='';
                                if(chat.DisplayName != null){
                                    chatMessage+=chat.DisplayName+': ';
                                }else{
                                    chatMessage+='SYSTEM: ';
                                }
                                
                                if(chat.ContentType=='application/vnd.amazonaws.connect.event.participant.joined'){
                                    chatMessage+='Joined Chat';
                                }else if(chat.ContentType=='application/vnd.amazonaws.connect.event.chat.ended'){
                                    chatMessage+='Ended Chat';
                                }else if(chat.ContentType=='application/vnd.amazonaws.connect.event.participant.left'){
                                    chatMessage+='Left Chat';
                                }
                                
                                if(chat.Content != null){
                                    chatMessage+=chat.Content+' - ';
                                }else{
                                    chatMessage+=' - ';
                                }
                                chatMessage+=chat.AbsoluteTime+'\n';
                                chatConversation+=chatMessage;
                            }
                            result.Description=chatStartTxt+chatConversation+chatEndTxt;
                        }else{
                            return 'Chat not found.';
                        }
                        update result;
                        return 'Success';
                        
                    }else{
                        return 'InitialContactId is not given.';
                    }
                }else{
                    return 'Chat not found in AWS.';
                }
            }else{
                return 'Task for Chat not found.';
            }
        } catch (DmlException e) {
            RestContext.response.statusCode = 400;
            return 'Error: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static Task updateCall(String tskId, String callType){
        Task tsk = new Task (Id=tskId, CallType__c=callType);
        update tsk;
        return tsk;
    }
      
    @AuraEnabled
    public static String sendEmail(String subject, String body, String toAddress, String tskId) {
        try {
            System.debug('### To'+toAddress);
            System.debug('### Subject'+subject);
            System.debug('### body'+body+' - '+tskId);
            if((tskId != null && tskId.trim().length()>0) && (toAddress != null && toAddress.trim().length()>0)){
                list<Task> tskList = [Select Id, Type, Subject, Description From Task where Id =:tskId];
                if(tskList != null && tskList.size()>0){
                    if(tskList[0].Description != null && tskList[0].Description.trim().length()>0){
                        list<String> emailIds = new list<String>();
                        emailIds.add(toAddress);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setSubject(subject);
                        mail.setToAddresses(emailIds);
                        String emailBody=body+'</br></br>';
                        emailBody=emailBody+'<pre>'+tskList[0].Description+'</pre>';
                        mail.setHTMLBody(emailBody);
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                        return 'Email Sent';
                    }else{
                        return 'Please pull the chat if exist.';
                    }
                }else{
                    return 'Task not found.';
                }
            }else{
                return 'Please provide To Address, Subject.';
            }
        } catch (DmlException e) {
            return 'Error: '+e.getMessage();
        }
    }

    @AuraEnabled (cacheable= true)   
    public static List<Task> getTask(String recordId){
     list<Task> tsk = [Select Id, Type, Subject, Description From Task where Id =:recordId];
        return tsk;
    }
}