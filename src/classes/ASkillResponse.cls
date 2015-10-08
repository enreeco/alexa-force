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

global class ASkillResponse {
   global class AOutputSpeech{
        global String type{get;set;}
        global String text{get;set;}
        global String ssml{get;set;}
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(type != null) gen.writeStringField('type', type);
                if(text != null && type == 'PlainText') gen.writeStringField('text', text);
                if(ssml != null && type == 'SSML') gen.writeStringField('ssml', ssml);
            }
	    gen.writeEndObject();
        }
    }
    
    global class ACard{
        global String type{get;set;}
        global String title{get;Set;}
        global String content{get;Set;}
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(type != null)gen.writeStringField('type', type);
                if(title != null)gen.writeStringField('title', title);
                if(content != null)gen.writeStringField('content', content);
            }
			gen.writeEndObject();
        }
    }
    
    global class AReprompt{
        global AOutputSpeech outputSpeech{get;set;}
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                gen.writeFieldName('outputSpeech');
                outputSpeech.serialize(gen);
            }
			gen.writeEndObject();
        }
    }
    
    global class AResponse{
        global AOutputSpeech outputSpeech{get;set;}
        global ACard card{get;set;}
        global AReprompt reprompt{get;set;}
        global Boolean shouldEndSession{get;set;}
        public void serialize(JSONGenerator gen){
            gen.writeStartObject();
            {
                if(outputSpeech != null){
	                gen.writeFieldName('outputSpeech');
    	            outputSpeech.serialize(gen);
                }
                if(card != null){
	                gen.writeFieldName('card');
    	            card.serialize(gen);
                }
                if(reprompt != null){
	                gen.writeFieldName('reprompt');
    	            reprompt.serialize(gen);
                }
                gen.writeBooleanField('shouldEndSession',shouldEndSession==true);
            }
			gen.writeEndObject();
        }
    }
    
    global String version{get;set;}
    global Map<String,Map<String,Object>> sessionAttributes{get;set;}
    global AResponse response{get;set;}
    
    global String serialize(Boolean prettify){
        JSONGenerator gen = JSON.createGenerator(prettify==true);
        gen.writeStartObject();
        if(version != null) gen.writeStringField('version', version);
        if(sessionAttributes != null){
            gen.writeFieldName('sessionAttributes');
            gen.writeStartObject();
            for(String name : sessionAttributes.keySet()){
                gen.writeFieldName(name);
                gen.writeStartObject();
                {
                    for(String key : sessionAttributes.get(name).keyset()){
                        Object val = sessionAttributes.get(name).get(key);
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
        if(response != null){
            gen.writeFieldName('response');
            response.serialize(gen);
        }
        gen.writeEndObject();
        return gen.getAsString();
    }
}
