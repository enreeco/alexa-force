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

//Stop intent implementation

public class AlexaForceStopIntent extends AlexaIntent{
	public AlexaForceStopIntent(){
        super('AlexForceStop');
		List<AlexaIntent.Slot> slots = new List<AlexaIntent.Slot>();
        List<String> utterances = new List<String>();
        utterances.add('Stop');
        utterances.add('Bye'); 
        utterances.add('Bye bye');
        utterances.add('Shut up');
        utterances.add('Shut the fuck up'); 
        utterances.add('Go to sleep');
        utterances.add('sleep');
        this.setSlots(slots);
        this.setUtterances(utterances);
    }
    
    public override ASkillResponse execute(ASkillRequest request){
        String responseText = 'Bye';
        return this.say(responseText, null, null, null, true);
    }
}