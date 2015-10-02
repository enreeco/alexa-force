# Salesforce Alexa Skills Kit

Author: Enrico Murru (http://enree.co)

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