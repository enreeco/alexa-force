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

//This REST class should be set as public on your community public profile.
//Implements GET and POST request creating a new skill.
//The service URL will be: [https://your_community_url/services/apexrest/AlexaRestTest]
//Uses the AlexaSkillRESTApp class that handle the methods

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