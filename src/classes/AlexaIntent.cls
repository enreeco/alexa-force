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

//Intent Base Class
//Extends this class to create your own Amazon Echo Intent

public abstract class AlexaIntent{

    //Store the slots definitions

    public class Slot{
        public Slot(String name, String type){
            this.name = name;
            this.type = type;
        }
        public String name{get;Set;}
        public String type{get;Set;}
    }
    
    //intent's name
    private String name{get;Set;}
    //slots definitions
    private List<Slot> slots{get;set;}
    //utterances
    private List<String> utterances{get;set;}
    
    //Constructor
    //@name - intent's name
    public AlexaIntent(String name){
        this.slots = new List<Slot>();
        this.utterances = new List<String>();
        this.name = name;
    }
    
    //Intent behavior. Extend this method in your own intent class
    //@request - request coming from Alexa
    public abstract ASkillResponse execute(ASkillRequest request);
    
    //Gets the list utterances that defines the intent
    public List<String> getUtterances(){
        return this.utterances;
    }

    //Gets the list of Slot objects that describes the intent
    public List<Slot> getSlots(){
        return this.slots;
    }

    //Set the utterances
    //@uttList - list of utterances
    public void setUtterances(List<String> uttList){
        if(uttList == null) this.utterances.clear();
        else this.utterances = uttList.clone();
    }

    //Sets the slots
    //@slots - list of slots
    public void setSlots(List<Slot> slots){
        if(slots == null) this.slots.clear();
        else this.slots = slots.clone();
    }

    //Gets the itent's name
    public String getName(){
        return this.name;
    }

    //Sets the intent's name
    //@intentName - intent name
    public void setName(String intentName){
        this.name = intentName;
    }
    
    //Helper method to make a response
    //@text - text of the response
    //@cardTitle - title of the card (null for no card)
    //@cardContent - content of the card (unused if @cardTitle is null)
    //@reprompt - reprompt text
    //@shouldEndSession - true if this response ends skill's session
    public ASkillResponse say(String text, String cardTitle, String cardContent, String reprompt, Boolean shouldEndSession){
        ASkillResponse resp = new ASkillResponse();
        resp.version = '1.0';
        resp.response = new ASkillResponse.AResponse();
        resp.response.outputSpeech = new ASkillResponse.AOutputSpeech();
        resp.response.outputSpeech.type = 'PlainText';
        resp.response.outputSpeech.text = text;
        if(String.isNotBlank(cardTitle)){
	        resp.response.card = new ASkillResponse.ACard();
    	    resp.response.card.type = 'Simple';
        	resp.response.card.title = cardTitle;
	        resp.response.card.content = cardContent;
        }
        if(String.isNotBlank(reprompt)){
            resp.response.reprompt = new ASkillResponse.AReprompt();
            resp.response.reprompt.outputSpeech = new ASkillResponse.AOutputSpeech();
            resp.response.reprompt.outputSpeech.type = 'PlainText';
            resp.response.reprompt.outputSpeech.text = reprompt;
        }
        resp.response.shouldEndSession = shouldEndSession;
        return resp;
    } 
    //Helper method to make a response
    //@text - text of the response
    //@isSSMLSpeech - outputspeech is in SSML
    //@cardTitle - title of the card (null for no card)
    //@cardContent - content of the card (unused if @cardTitle is null)
    //@reprompt - reprompt text
    //@isSSMLReprompt - reprompt is in SSML
    //@shouldEndSession - true if this response ends skill's session
    public ASkillResponse say(String text, Boolean isSSMLSpeech, String cardTitle, String cardContent, String reprompt, Boolean isSSMLReprompt, Boolean shouldEndSession){
        ASkillResponse resp = new ASkillResponse();
        resp.version = '1.0';
        resp.response = new ASkillResponse.AResponse();
        resp.response.outputSpeech = new ASkillResponse.AOutputSpeech();
        resp.response.outputSpeech.type = (isSSMLSpeech==true)?'SSML':'PlainText';
        if(isSSMLSpeech==true){
            resp.response.outputSpeech.ssml = text;
        }else{
            resp.response.outputSpeech.text = text;
        }
        if(String.isNotBlank(cardTitle)){
	        resp.response.card = new ASkillResponse.ACard();
    	        resp.response.card.type = 'Simple';
        	resp.response.card.title = cardTitle;
	        resp.response.card.content = cardContent;
        }
        if(String.isNotBlank(reprompt)){
            resp.response.reprompt = new ASkillResponse.AReprompt();
            resp.response.reprompt.outputSpeech = new ASkillResponse.AOutputSpeech();
            resp.response.reprompt.outputSpeech.type = (isSSMLReprompt==true)?'SSML':'PlainText';
            resp.response.reprompt.outputSpeech.text = reprompt;
            if(isSSMLReprompt == true){
                resp.response.outputSpeech.ssml = reprompt;
            }else{
                resp.response.outputSpeech.text = reprompt;
            }
        }
        resp.response.shouldEndSession = shouldEndSession;
        return resp;
    } 
}
