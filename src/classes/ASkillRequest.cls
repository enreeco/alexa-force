/*
    Author: Enrico Murru (http://enree.co)
    
    Repository: https://github.com/enreeco/alexa-force
    
    The MIT License (MIT)

    Copyright (c) 2015 Enrico Murru

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

global class ASkillRequest {
    global class AApplication{
        global String applicationId{get;set;}
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(applicationId != null) gen.writeStringField('applicationId', applicationId);
            }
			gen.writeEndObject();
        }
    }
    
    global class AUser{
        global String userId{get;Set;}
        global String accessToken{get;set;}
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(userId != null) gen.writeStringField('userId', userId);
                if(accessToken != null) gen.writeStringField('accessToken', accessToken);
            }
			gen.writeEndObject();
        }
    }
    
    global class ASlot{
        global String name{get;Set;}
        global String value{get;set;}
        
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(name != null) gen.writeStringField('name', name);
                if(value != null) gen.writeStringField('value', value);
            }
			gen.writeEndObject();
        }
    } 
    
    global class AIntent{
        global String name{get;Set;}
        global Map<String,ASlot> slots{get;set;}
        
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(name != null) gen.writeStringField('name', name);
                gen.writeFieldName('slots');
                gen.writeStartObject();
                {
                    if(slots != null && !slots.isEmpty()){
                        for(String name : slots.keySet()){
                            gen.writeFieldName(name);
                            slots.get(name).serialize(gen);
                        }
                    }
                }
                gen.writeEndObject();

            }
			gen.writeEndObject();
        }
    }
    
    global class ASession{
        global Boolean isNew{get;Set;} //this should be "new" but is a reserved word
        global String sessionId{get;Set;}
        global AApplication application{get;set;}
        global Map<String,Map<String,Object>> attributes{get;set;}
        global AUser user{get;Set;}
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
	            gen.writeBooleanField('new', isNew);
            	if(sessionId != null) gen.writeStringField('sessionId', sessionId);
	            if(application != null){
    	        	gen.writeFieldName('application');
	            	application.serialize(gen);
                }
                if(attributes != null){
                    gen.writeFieldName('attributes');
                    gen.writeStartObject();
                    for(String name : attributes.keySet()){
                        gen.writeFieldName(name);
                        gen.writeStartObject();
                        {
                            for(String key : attributes.get(name).keyset()){
                                Object val = attributes.get(name).get(key);
                                if(val != null){
                                    gen.writeFieldName(key);
                                    gen.writeObject(val);
                                }
                            }
                        }
                        gen.writeEndObject();
                    }
                    gen.writeEndObject();
                }
                if(user != null){
    	        	gen.writeFieldName('user');
	            	user.serialize(gen);
                }
            }
            gen.writeEndObject();
        }
    }
    
    global class ARequest{
        global String type{get;Set;}
        global String requestId{get;Set;}
        global String timestamp{get;Set;}
        global String reason{get;Set;}
        global AIntent intent{get;set;}
        
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(type != null) gen.writeStringField('type', type);
                if(requestId != null) gen.writeStringField('requestId', requestId);
                if(timestamp != null) gen.writeStringField('timestamp', timestamp);
                if(reason != null) gen.writeStringField('reason', reason);
                if(intent != null){
    	        	gen.writeFieldName('intent');
	            	intent.serialize(gen);
                }
            }
			gen.writeEndObject();
        }
    }
    
    global String getSlot(String slotName){
        ASlot slot = this.request.intent.slots.get(slotName);
        if(slot == null) return null;
        return slot.value;
    }
    
    global String version{get;Set;}
    global ASession session{get;Set;}
    global ARequest request{get;set;}
    
    global String serialize(Boolean prettify){
        JSONGenerator gen = JSON.createGenerator(prettify==true);
        gen.writeStartObject();
        if(version != null) gen.writeStringField('version', version);
        if(session != null){
            gen.writeFieldName('session');
            session.serialize(gen);
        }
        if(request != null){
            gen.writeFieldName('request');
            request.serialize(gen);
        }
        gen.writeEndObject();
        return gen.getAsString();
    }
    
    global static ASkillRequest deserialize(String jsonStr){
        Map<String,Object> jsonObj = (Map<String,Object>)JSON.deserializeUntyped(jsonStr);
        ASkillRequest req = new ASkillRequest();
        req.version = (String)jsonObj.get('version');
        //session
        {
            Map<String,Object> session = (Map<String,Object>) jsonObj.get('session');
            req.session = new ASkillRequest.ASession();
            if(session != null){
                req.session.isNew = (Boolean) session.get('new') == true;
                req.session.sessionId = (String) session.get('sessionId');
                //application
                {
                    Map<String,Object> application = (Map<String,Object>) session.get('application');
                    req.session.application = new ASkillRequest.AApplication();
                    if(application != null){
                        req.session.application.applicationId = (String)application.get('applicationId');
                    }
                }
                //attributes
                {
                    req.session.attributes = new Map<String,Map<String,Object>>();
                    Map<String,Object> attributes = (Map<String,Object>)session.get('attributes');
                    if(attributes != null){
                        for(String keyAttr : attributes.keyset()){
                            Map<String,Object> obj = (Map<String,Object>)attributes.get(keyAttr);
                            if(obj != null){
                                req.session.attributes.put(keyAttr,obj);
                            }
                        }
                    }
                }
                //user
                {
                    Map<String,Object> usr = (Map<String,Object>) session.get('user');
                    req.session.user = new ASkillRequest.AUser();
                    if(usr != null){
                        req.session.user.userId = (String)usr.get('userId');
                        req.session.user.accessToken = (String)usr.get('accessToken');
                    }
                }
            }
        }
        //request
        {
            Map<String,Object> request = (Map<String,Object>) jsonObj.get('request');
            req.request = new ASkillRequest.ARequest();
            if(request != null){
                req.request.type = (String)request.get('type');
                req.request.requestId = (String)request.get('requestId');
                req.request.timestamp = (String)request.get('timestamp');
                req.request.reason = (String)request.get('reason');
                //intent
                {
                    Map<String,Object> intent = (Map<String,Object>) request.get('intent');
                    req.request.intent = new ASkillRequest.AIntent();
                    if(intent != null){
                        req.request.intent.name = (String)intent.get('name');
                        //slots
                        {
                            req.request.intent.slots = new Map<String,ASkillRequest.ASlot>();
                            Map<String,Object> slots = (Map<String,Object>) intent.get('slots');
                            if(slots != null){
                                for(String key : slots.keySet()){
                                    //slot
                                    ASkillRequest.ASlot aslot = new ASkillRequest.ASlot();
                                    Map<String,Object> slot = (Map<String,Object>) slots.get(key);
                                    if(slot != null){
                                        aslot.name = (String) slot.get('name');
                                        aslot.value = (String) slot.get('value');
                                        req.request.intent.slots.put(key,aslot);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return req;
    }
    
}