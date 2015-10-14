# Salesforce Alexa Skills Kit

Author: @enreeco (http://enree.co)

Repository: https://github.com/enreeco/alexa-force

This is an Apex implementation of the [Alexa Skills Kit](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit) request/response paradigm.

## Deploy on your Salesforce ORG

Click the following button to automatically deploy the Salesforce Alexa Skills Kit on your Org.

<a href="https://githubsfdeploy.herokuapp.com?owner=enreeco&repo=alexa-force">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## Setup actions

To enable the functionalities of the provided `AlexaRestTest` skill implementation you need:

- Create a Site / Community to expose a custom domain URL
- Expose the `AlexaRestTest` class on the public profile of the Site
- Create a Connected App for the profiles you want to access the service
- Create an Alexa Skill configuration on the [Amazon Developer Site](https://developer.amazon.com/public/solutions/devices/echo)
- The *Redirect URL* of your connected account configuration is **[community-url]**/AlexaOAuthStarter

If you don't need account linking, the *connected app* steps are not necessary (you just need a public endpoint for your REST services).

#### Example Code changes

The example classes needs some changes to be correctly executed on your Org.

*AlexaOAuthStarterController*

```java
//Class used to handle Amazon Echo linked accounts, controller of the AlexaOAuthStarter Visualforce page
//Executes a redirect appending the mandatory "redirect_uri" parameter that the Alexa's Skill configuration
//cannot handle at the moment.
//ATTENTION: this class must be customized based on your Org's configuration
public class AlexaOAuthStarterController {

    //Load action executed by the visualforce page called by Alexa's linked account attempt
    //ATTENTION: change the "communityName" and "alexaOauthCallbackURL" variables with the 
    //correct values
    public PageReference onLoad(){
        //change this with your current community folder name (or leave blank string)
        String communityFolder = '/alexaforce';
        //redirect uri configured in the Alexa Skill configuration
        String alexaOauthCallbackURL = 
            'https://pitangui.amazon.com/spa/skill/account-linking-status.html?vendorId=XXXXXXXXX';
        String communityURL = URL.getSalesforceBaseUrl().toExternalForm()+communityFolder;
        PageReference page = new PageReference(communityURL+'/services/oauth2/authorize');
        for(String k : ApexPages.currentPage().getParameters().keyset()){
            page.getParameters().put(k, ApexPages.currentPage().getParameters().get(k));
        }
        //appends the "redirect_uri" that amazon's configuration does not send
        //this class should be configured to change depending on the context (1 visualorce page per skill?)
        page.getParameters().put('redirect_uri',alexaOauthCallbackURL);
        return page;
    }
}
```

Change the *communityFolder* variable value with the name of the folder of your Site/Community (leave blank string if not set).

*AlexaRestTest*

```java
@RestResource(urlMapping='/AlexaRestTest/*')
global class AlexaRestTest {
	@HttpGet
    global static void get(){
        AlexaSkillRESTApp.handleGet(createAlexaSkill());
    }
	@HttpPost
    global static void post(){
        AlexaSkillRESTApp.handlePost(createAlexaSkill());
    }
    
    //Creates a new Skill
    private static AlexaSkill createAlexaSkill(){
        AlexaSkill skill = new AlexaSkill();
        skill.setApplicationId('amzn1.echo-sdk-ams.app.APP_ID');
        skill.addIntent(new AlexaUserInfoIntent());
        skill.addIntent(new AlexaForceHelpIntent());
        skill.addIntent(new AlexaForceStopIntent());
        skill.addOnLaunchIntent(new AlexaForceHelpIntent());
        return skill;
    }

}
```

This is the skill's webservice pubblicly exposed by your Site/Community: change the *setApplicationId()* with the value of your own application ID (from Alexa skill configuration page, first step).

*AlexaSkillRESTApp*

```java
public class AlexaSkillRESTApp {
    
    //Enable debug
    public static BOOLEAN ENABLE_DEBUG{
        get{
            //to be replace with a CS / Custom Metadata
            return true;
        }
    }

    //. . .
}
```

You can disable the debugging feature that stores in the *RestLog__c* Sobject the request/response couple for every request (makes debugging easier).

## Library usage

#### Create an Intent

Extend the *AlexaIntent* class to handle your intent:

```java
public class MyEchoIntent extends AlexaIntent{
	public AlexaForceHelpIntent(){
        super('EchoIntent');
		List<AlexaIntent.Slot> slots = new List<AlexaIntent.Slot>();
		slots.add(new AlexaIntent.Slot('name','AMAZON.LITERAL'));
        List<String> utterances = new List<String>();
        utterances.add('My name is {name}'); 
        this.setSlots(slots);
        this.setUtterances(utterances);
    }
    
    public override ASkillResponse execute(ASkillRequest req){
    	Stirng slotName = req.getSlot('name');
        String responseText = 'Your name is '+slotName;
        return this.say(responseText, null, null, null, true);
    }
}
```

Use the intent's constructor to define the intent's name, schema and utterances (this will be output when describing the skill).

The `say(String text, String cardTitle, String cardContent, String reprompt, Boolean shouldEndSession)` method allow to create a valid response on the fly.

#### Create a Skill

Create a new instance of the *AlexaSkill* class:

```java
AlexaSkill skill = new AlexaSkill();
skill.setApplicationId('amzn1.echo-sdk-ams.app.APP_ID');
skill.addIntent(new MyEchoIntent());
skill.addDefaultIntent(new MyEchoIntent());
skill.addOnLaunchIntent(new MyEchoIntent());
```
 A skill can have:

 * As manu intents as you want (`addIntent()`)
 * A default intent (`addDefaultIntent()`, this is used as a **precaution** to handle unimplemented intents)
 * An **on launch** intent (`addOnLaunchIntent()`, this is used when you activate a skill without saying any utterance; e.g. **Alexa ask myskill**)

#### Create the REST service

Use the *AlexaSkillRESTApp* to handle most of the service logic:

```java
@RestResource(urlMapping='/AlexaRestTest/*')
global class AlexaRestTest {
	@HttpGet
    global static void get(){
        AlexaSkillRESTApp.handleGet(createAlexaSkill());
    }
	@HttpPost
    global static void post(){
        AlexaSkillRESTApp.handlePost(createAlexaSkill());
    }
    
    //Creates a new Skill
    private static AlexaSkill createAlexaSkill(){
        AlexaSkill skill = new AlexaSkill();
		skill.setApplicationId('amzn1.echo-sdk-ams.app.APP_ID');
		skill.addIntent(new MyEchoIntent());
		skill.addDefaultIntent(new MyEchoIntent());
		skill.addOnLaunchIntent(new MyEchoIntent());
		return skill;
        return skill;
    }

}
```

The *GET* method will give you the skill's schema and utterances list to help you configure the skill on Amazon's site.

E.g.
	GET https://[community-domain]/services/apexrest/AlexaRestTest?schema=utterances

```
MyEchoIntent my name is {name}
```

E.g.
	GET https://[community-domain]/services/apexrest/AlexaRestTest

```
{
  "intents" : [ {
    "slots" : [ {
      "type" : "AMAZON.LITERAL",
      "name" : "name"
    } ],
    "intent" : "MyEchoIntent"
  } ]
}
```

The *POST* method will decide which intent execute.


## Examples

Refer to the *AlexaRestTest* class for a complete REST webservice example.

To complete the account linking configuration use the *AlexaOAuthStarter* page as main login page.

#### Test classes

No test class available in this version of the library.

## License

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
