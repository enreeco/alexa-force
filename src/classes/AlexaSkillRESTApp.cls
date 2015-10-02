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

//REST Helper class to be used as REST handler for GET/POST requests

public class AlexaSkillRESTApp {
    
    //Enable debug
    public static BOOLEAN ENABLE_DEBUG{
        get{
            //to be replace with a CS / Custom Metadata
            return true;
        }
    }

    //Handle WS GET request
    //Outputs the schema
    //@skill - skill's implementation
    //@params
    //      "schema" = "utterances" - response with the list of utterances
    //      "schema" = "anything" - response with the skill's schema
    public static void handleGet(AlexaSkill skill){
        RestRequest request = RestContext.request;
        String responseBody = null; 
        if(request.params.get('schema') != 'utterances'){
            responseBody = skill.getIntentSchema();
        }else{
            responseBody = skill.getUtterances(); 
        }
        RestResponse response = RestContext.response;
        response.statusCode = 200;
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(responseBody);
    }
    
    //Handle sthe post request calling the request
    //@skill - skill's implementation
    public static void handlePost(AlexaSkill skill){
        String body = RestContext.request.requestBody.toString();
        
        if(body != null){ 
            body = JSON.serializePretty(JSON.deserializeUntyped(body));
        }
        RestLog__c requestLog = new RestLog__c(Body__c = body, 
                              Method__c = RestContext.request.httpMethod,
                              Headers__c = JSON.serializePretty(RestContext.request.headers));
        RestResponse response = RestContext.response;
        try{
            response.statusCode = 200;
            response.addHeader('Content-Type', 'application/json');
            String respBody = skill.execute(body);
            requestLog.Response__c = respBody;
            response.responseBody = Blob.valueOf(respBody);
        }catch(Exception e){
            response.statusCode = 500;
            response.responseBody = Blob.valueOf(e.getMessage()+'\n'+e.getStackTraceString());
            requestLog.Exception__c = e.getMessage()+'\n'+e.getStackTraceString();
        }
        if(ENABLE_DEBUG){
            try{
	            insert requestLog;   
            }catch(Exception e){
                system.debug('## Error inserting log: '+e.getMessage()+'\n'+e.getStackTraceString());
            }
        }
    }
}