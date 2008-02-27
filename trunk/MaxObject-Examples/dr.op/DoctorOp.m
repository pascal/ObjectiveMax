/*
	==============================================================================

	This file is part of the ObjectiveMax Library and Framework
	An Objective-C API for writing Max external objects
	Copyright 2007 by Electrotap, LLC.

	------------------------------------------------------------------------------

	ObjectiveMax can be redistributed and/or modified under the terms of the
	GNU General Public License, as published by the Free Software Foundation;
	either version 2 of the License, or (at your option) any later version.

	ObjectiveMax is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with ObjectiveMax; if not, visit www.gnu.org/licenses or write to the
	Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
	Boston, MA 02111-1307 USA

	------------------------------------------------------------------------------

	If you'd like to release a closed-source product which uses ObjectiveMax, 
	commercial licenses are also available.  Visit 
		http://electrotap.com/ObjectiveMax
	for more information.

	==============================================================================
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
	atom_arg_getsym(&modeAttribute, 0, argc, argv);			// support a 'normal' (non-attribute) arguments
	atom_arg_getfloat(&operandAttribute, 1, argc, argv);	// attribute processing is handled automatically afterwards
	
	[self createInletWithIndex:0	named:"main_inlet"	withAssistanceMessage:"(int/float) Input"];
	[self createInletWithIndex:1	named:"set_inlet"	withAssistanceMessage:"(int/float) Operand"];
	[self createOutletWithIndex:0	named:"main_outlet"	withAssistanceMessage:"Computed Output"];

	return self;
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
		object_error(maxObjectBridge, "invalid mode attribute for calculation");
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
	return (t_max_err)[self floatMessage:(double)value];
}


- (t_max_err) listTypedMessage:(t_symbol *)s withNumArgs:(long)argc andValues:(t_atom *)argv
{
	if(argc == 2){
		input = atom_getfloat(argv+0);
		operandAttribute = atom_getfloat(argv+1);
		return [self bangMessage];
	}
	object_error(maxObjectBridge, "wrong number of args for list");
	return MAX_ERR_GENERIC;
}


- (t_max_err) postoperatorsTypedMessage:(t_symbol *)s withNumArgs:(long)argc andValues:(t_atom *)argv
{
	object_post(maxObjectBridge, "Available operators for this object are: +, -, *, /");
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
	object_post(maxObjectBridge, "custom getter called");
	return autotriggerAttribute;
}

@end // DoctorOp implementation
