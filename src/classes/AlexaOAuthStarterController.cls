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