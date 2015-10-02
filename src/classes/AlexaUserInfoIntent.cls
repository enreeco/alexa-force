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

//Example of intent implementation using access token from the request
//This skill calls the "GetUserInfo" SOAP method and responds with the user's full name

public class AlexaUserInfoIntent extends AlexaIntent{
    
    public AlexaUserInfoIntent(){
        super('SFUserInfo');
        List<String> utterances = new List<String>();
        utterances.add('get my user info');
        utterances.add('get my user');
        utterances.add('my user');
        utterances.add('user info');
        this.setUtterances(utterances);
    }
    
    public override ASkillResponse execute(ASkillRequest request){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //change this with your current community folder name (or leave blank string)
        String communityFolder = '/alexaforce';
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm()+communityFolder+'/services/Soap/c/34.0';
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        req.setHeader('SOAPAction','getUserInfo');
        
        String authToken = request.session.user.accessToken;
        
        String soapBody = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">  <soapenv:Header><urn:SessionHeader><urn:sessionId>'
					+authToken+'</urn:sessionId></urn:SessionHeader></soapenv:Header><soapenv:Body><urn:getUserInfo /></soapenv:Body></soapenv:Envelope>';
        
        req.setBody(soapBody);
        HttpResponse resp = h.send(req);
        system.debug('## Request body: '+soapBody);
        system.debug('## Response body: '+resp.getBody());
        Dom.Document doc = resp.getBodyDocument();
        //Retrieve the root element for this document.
        Dom.XMLNode soapenvEnvelope  = doc.getRootElement();
        String SOAPENV_NS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String NS = 'urn:enterprise.soap.sforce.com';
        Dom.XMLNode bodyNode = soapenvEnvelope.getChildElement('Body', SOAPENV_NS);
        Dom.XMLNode userinfoRespNode = bodyNode.getChildElement('getUserInfoResponse', NS);
        Dom.XMLNode resultNode = userinfoRespNode.getChildElement('result', NS);
        Dom.XMLNode fullnameNode = resultNode.getChildElement('userFullName',NS);
        String fullName = fullnameNode.getText();
        String responseText = 'Your user\'s full name is '+fullName;
        return this.say(responseText, 'Salesforce User Info', responseText, null, true);

    }
    

}