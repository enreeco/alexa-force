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

//Implements the most part of am Alexa Skill and the logic behind the request/response paradigm
//This class can be extended in the "onIntentRequest", "onLaunchRequest" and "onSessionEndedRequest" methods.

public virtual class AlexaSkill {
    
    public class AlexSkillException extends Exception{}
    
    //Skill's intents
    private Map<String, AlexaIntent> intents{get;set;}
    //Default intent
    private AlexaIntent defaultIntent{get;set;}
    //On Lauch intent
    private AlexaIntent onLaunchIntent{get;set;}
    //Alexa Skill's ID
    private String applicationId{get;set;}
    
    //Constructor
    public AlexaSkill(){
        this.intents = new Map<String,AlexaIntent>();
    }
    
    //Called when the "LaunchRequest" request is done
    //If set, calls the "onLauchIntent"
    //@request - skill's request
    public virtual ASkillResponse onLaunchRequest(ASkillRequest request){
        if(this.onLaunchIntent != null){
            return this.onLaunchIntent.execute(request);
        }
        ASkillResponse resp = new ASkillResponse();
        resp.version = '1.0';
        resp.response = new ASkillResponse.AResponse();
        resp.response.shouldEndSession = false;
        return resp;
    }
    
    //Called when the "IntentRequest" request is done
    //Decides which intent to call
    //@request - skill's request
    public virtual ASkillResponse onIntentRequest(ASkillRequest request){
        AlexaIntent currentIntent = null;
        for(AlexaIntent intent : this.intents.values()){
            if(intent.getName() != request.request.intent.name){
                continue;
            }else{
                currentIntent = intent;
                break;
            }
        }
        if(currentIntent != null){
            return currentIntent.execute(request);
        }else{
            if(this.defaultIntent == null){
                return this.defaultIntent.execute(request);
            }
        }
        throw new AlexSkillException('Invalid intent');
    }

    //Called when the "SessionEndedRequest" request is done
    //@request - skill's request
    public virtual ASkillResponse onSessionEndedRequest(ASkillRequest request){
        ASkillResponse resp = new ASkillResponse();
        resp.version = '1.0';
        resp.response = new ASkillResponse.AResponse();
        resp.response.shouldEndSession = false;
        return resp;
    }
    
    //Executes a given request (main method) and sends back a response
    //@requestBody - json request string
    //@return - json response string
    public String execute(String requestBody){
        ASkillRequest sreq = ASkillRequest.deserialize(requestBody);
        ASkillResponse sresp = this.execute(sreq);
        return sresp.serialize(false);
    }
    
    //Executes a given request (main method) and sends back a response
    //@request - the request object
    //@return - the respose object
    public ASkillResponse execute(ASkillRequest request){
        if(this.applicationId != null && 
           request.session.application.applicationId != this.applicationId){
               throw new AlexSkillException('Invalid application ID');
           }
        if(request.request.type == 'LaunchRequest'){
            return this.onLaunchRequest(request);
        }else if(request.request.type == 'IntentRequest'){
            return this.onIntentRequest(request);
        }else if(request.request.type == 'SessionEndedRequest'){
            return this.onSessionEndedRequest(request);
        }else{
            throw new AlexSkillException('Unsupported intent type '+request.request.type);
        }
    }
    
    //Adds an intent to the skill
    //@intent - intent instance
    public void addIntent(AlexaIntent intent){
        if(intent == null || String.isBlank(intent.getName())){
            throw new AlexSkillException('Invalid intent');
        }
        this.intents.put(intent.getName(), intent);
    }
    
    //Removes an intent to the skill
    //@intentName - intent name
    public void removeIntent(String intentName){
        if(String.isBlank(intentName)) return;
        this.intents.remove(intentName);
    }
    
    //Describe the intent schema 
    //@return - json string containing intents' schema (to be used
    //when configuring the skill on Amazon dev site)
    public String getIntentSchema(){
        Map<String,Object> schema = new Map<String,Object>();
        List<Map<String,Object>> intentsSchema = new List<Map<String,Object>>();
        schema.put('intents',intentsSchema);
        if(this.intents.isEmpty()) return JSON.serializePretty(schema);
        for(AlexaIntent aint : this.intents.values()){
            Map<String,Object> aintSchema = new Map<String,Object>();
			aintSchema.put('intent',aint.getName());
            aintSchema.put('slots',aint.getSlots());
            intentsSchema.add(aintSchema);
        }
        return JSON.serializePretty(schema);
    }

    //List of utterances
    //@return - json string containing the list of utterances (to be used
    //when configuring the skill on Amazon dev site)
    public String getUtterances(){
        List<String> uttLists = new List<String>();
        for(AlexaIntent aint : this.intents.values()){
            for(String utt : aint.getUtterances()){
				uttLists.add(aint.getName()+' '+utt);
            }
        }
        return String.join(uttLists,'\n');
    }

    //Get application ID
    public String getApplicationId(){
        return this.applicationId;
    }

    //Set application ID
    public void setApplicationId(String appId){
        this.applicationId = appId;
    }

    //Adds the default intent
    //@intent - default intent to be called if no other intent is defined
    public void addDefaultIntent(AlexaIntent intent){
        this.defaultIntent = intent;
    }

    //Removes default intent
    public void removeDefaultIntent(){
        this.defaultIntent = null;
    }

    //Adds an intent on launch
    //@intent - intent launched when the "LaunchRequest" is sent
    public void addOnLaunchIntent(AlexaIntent intent){
        this.onLaunchIntent = intent;
    }

    //Removes the "onlaunch" intent
    public void removeOnLaunchIntent(){
        this.onLaunchIntent = null;
    }

    //Gets all intents
    public List<AlexaIntent> getIntents(){
        return this.intents.values();
    }

    //Gets the default intent
    public AlexaIntent getDefaultIntent(){
        return this.defaultIntent;
    }

    //Gets the "on launch" intent
    public AlexaIntent getOnLaunchIntent(){
        return this.onLaunchIntent;
    }
}