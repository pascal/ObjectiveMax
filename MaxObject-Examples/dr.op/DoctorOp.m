/*
	Copyright (c) 2009, 74 Objects LLC.
	
	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions are met:
	
	 1. Redistributions of source code must retain the above copyright notice, 
	    this list of conditions and the following disclaimer.
	 2. Redistributions in binary form must reproduce the above copyright notice,
	    this list of conditions and the following disclaimer in the documentation
	    and/or other materials provided with the distribution.
	 3. Neither the name of ObjectiveMax nor the names of its contributors may be
	    used to endorse or promote products derived from this software without
	    specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
	MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
	EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


// dr.op object -- cheesy example of creating a Max external using Objective-C 
#import "MaxObject/MaxObject.h"

@interface DoctorOp : MaxObject 
{
	@public
		t_symbol	*modeAttribute;				// '+', '-', '*', or '/' -- ends with 'Attribute' so it will be an attribute in Max
		float		 operandAttribute;
		long		 autotriggerAttribute;		// send output when the right inlet receives a value
	
	@private
		float		input;
}
@end


// Entry Point when loaded by Max
int main(void)
{
	[MaxObject createMaxClassWithName:"dr.op" fromObjcClassWithName:"DoctorOp"];
	return 0;
}


/********************************************************************************************************/
@implementation DoctorOp


- (id) initWithObject:(t_object *)x name:(t_symbol *)s numArgs:(long)argc andValues:(t_atom *)argv;
{
	[super initWithObject:x name:s numArgs:argc andValues:argv];
	modeAttribute = gensym("+");							// set default
	atom_arg_getsym(&modeAttribute, 0, argc, argv);			// support a 'normal' (non-attribute) argument
	atom_arg_getfloat(&operandAttribute, 1, argc, argv);	// ...
	
	[self createInletWithIndex:0	named:"main_inlet"	withAssistanceMessage:"(int/float) Input"];
	[self createInletWithIndex:1	named:"set_inlet"	withAssistanceMessage:"(int/float) Operand"];
	[self createOutletWithIndex:0	named:"main_outlet"	withAssistanceMessage:"Computed Output"];

	return self;	// attribute processing is handled automatically after we return
}


- (void)dealloc
{
    [super dealloc];
}


/********************************************************************************************************/

- (t_max_err) bangMessage
{
	if(modeAttribute == gensym("+"))
		[self sendFloat:(input + operandAttribute) toOutlet:0];
	else if(modeAttribute == gensym("-"))
		[self sendFloat:(input - operandAttribute) toOutlet:0];
	else if(modeAttribute == gensym("*"))
		[self sendFloat:(input * operandAttribute) toOutlet:0];
	else if(modeAttribute == gensym("/"))
		[self sendFloat:(input / operandAttribute) toOutlet:0];
	else{
		[self postError:"invalid mode attribute for calculation"];
		return MAX_ERR_GENERIC;
	}
	return MAX_ERR_NONE;
}


- (t_max_err) floatMessage:(double)value
{
	if(inletNum == 0){
		input = value;
		return [self bangMessage];
	}
	else{
		[self setFloat:value forKey:@"operandAttribute"];
		return MAX_ERR_NONE;
	}
}


- (t_max_err) intMessage:(long)value
{
	return [self floatMessage:(double)value];
}


- (t_max_err) listTypedMessage:(t_symbol *)s withNumArgs:(long)argc andValues:(t_atom *)argv
{
	if(argc == 2){
		input = atom_getfloat(argv+0);
		operandAttribute = atom_getfloat(argv+1);
		return [self bangMessage];
	}

	[self postError:"wrong number of args for list: received %ld, expected 2", argc];
	return MAX_ERR_GENERIC;
}


- (t_max_err) postoperatorsTypedMessage:(t_symbol *)s withNumArgs:(long)argc andValues:(t_atom *)argv
{
	[self postMessage:"Available operators for this object are: +, -, *, /"];
	return MAX_ERR_NONE;
}


// The following are examples of defining custom attribute accessors:

// An attribute setter...
- (void) setOperandAttribute:(long)value
{
	operandAttribute = value;
	if(autotriggerAttribute)
		[self bangMessage];
}

// And an attribute getter...
- (long) autotriggerAttribute
{
	[self postMessage:"custom getter called"];
	return autotriggerAttribute;
}

@end // DoctorOp implementation
