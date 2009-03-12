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


// dr.op~ object -- cheesy example of creating an MSP external using Objective-C 
#import "MaxObject/MaxObject.h"
#import "MaxObject/MaxAudioSignal.h"

@interface DoctorOpTilde : MaxObject 
	{
		@public
		t_symbol	*modeAttribute;				// '+', '-', '*', or '/' -- ends with 'Attribute' so it will be an attribute in Max
		float		 operandAttribute;
		
		@private
		float		input;
	}
@end


// Globals -- Cached Symbols
static t_symbol	*ps_addsym,
				*ps_subtractsym,
				*ps_multiplysym,
				*ps_dividesym;


// Entry Point when loaded by Max
int main(void)
{	
	t_class *c;
	
	// cache these symbols so it is faster to do comparisons in the audio processing code
	ps_addsym = gensym("+");
	ps_subtractsym = gensym("-");
	ps_multiplysym = gensym("*");
	ps_dividesym = gensym("/");

	c = [MaxObject createMaxClassWithName:"dr.op~" fromObjcClassWithName:"DoctorOpTilde"];

	// Creating a MaxObject class returns the Max t_class pointer.  This allows us to do
	// further customization of the class if desired.  In this case we add some style to
	// one of our attributes for the Max inspector.
	CLASS_ATTR_LABEL(c,	"mode",	0,	"Operation Mode (+, -, *, /)");
	
	return 0;
}


/********************************************************************************************************/
@implementation DoctorOpTilde


- (id) initWithObject:(t_object *)x name:(t_symbol *)s numArgs:(long)argc andValues:(t_atom *)argv;
{
	[super initWithObject:x name:s numArgs:argc andValues:argv];
	modeAttribute = gensym("+");							// set default
	atom_arg_getsym(&modeAttribute, 0, argc, argv);			// support a 'normal' (non-attribute) arguments
	atom_arg_getfloat(&operandAttribute, 1, argc, argv);	// attribute processing is handled automatically afterwards
	
	[self createInletWithIndex:0	named:"signalIn0"	withAssistanceMessage:"(signal) Input"];
	[self createInletWithIndex:1	named:"signalIn1"	withAssistanceMessage:"(signal/float) Operand"];
	[self createOutletWithIndex:0	named:"signalOut"	withAssistanceMessage:"(signal) Output"];
	
	return self;
}


- (void)dealloc
{
    [super dealloc];
}


/********************************************************************************************************/

- (t_max_err) floatMessage:(double)value
{
	operandAttribute = value;
	return MAX_ERR_NONE;
}


- (t_max_err) intMessage:(long)value
{
	return (t_max_err)[self floatMessage:value];
}


- (t_max_err) processAudioWithInput:(MaxAudioSignal *)signals_in andOutput:(MaxAudioSignal *)signals_out
{
	short	vs = signals_in->vs;				// we assume that the vectorsize is the same for both signals
	float	*in1 = signals_in->vectors[0];
	float	*in2 = signals_in->vectors[1];		// this will set the in2 pointer to NULL if there is no valid audio here
	float	*out = signals_out->vectors[0];

	if(modeAttribute == ps_addsym){
		while(vs--){
			if(in2)
				operandAttribute = *in2++;
			*out++ = *in1++ + operandAttribute;
		}
	}
	else if(modeAttribute == ps_subtractsym){
		while(vs--){
			if(in2)
				operandAttribute = *in2++;
			*out++ = *in1++ - operandAttribute;
		}
	}
	else if(modeAttribute == ps_multiplysym){
		while(vs--){
			if(in2)
				operandAttribute = *in2++;
			*out++ = *in1++ * operandAttribute;
		}
	}
	else if(modeAttribute == ps_dividesym){
		while(vs--){
			if(in2)
				operandAttribute = *in2++;
			*out++ = *in1++ / operandAttribute;
		}
	}
	
	return MAX_ERR_NONE;
}


@end // DoctorOp implementation
