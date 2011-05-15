//
//  Connection.m
//  CompoundNetwork
//
//  Created by max on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connection.h"
#import "Material.h"

@implementation Connection


-(Material *) materialA{return materialA;}
-(Material *) materialB{return materialB;}
-(NSString *) comment{return comment;}
-(NSString *) tag{return tag;}
-(NSNumber *) type{return type;}
-(NSNumber *) strength{return strength;}

-(void)setMaterialA:(Material *)m{
	
	materialA = m;
	[materialA addConnection:self];
}

-(void)setMaterialB:(Material *)m{
	
	materialB = m;
	[materialB addConnection:self];
}

-(void)setComment:(NSString *)s{
	if(comment)
		[comment release];
	comment = [s retain];
}

-(void)setTag:(NSString *)s{
	if(tag)
		[tag release];
	tag =[s retain];
}

-(void)setType:(NSNumber *)t{
	if(type)
		[type release];
	type = [t retain];
}

-(Connection *)initWithMaterialA:(Material *)m{
	self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		
		materialA = m;
		materialB = nil;
		comment = [NSString stringWithFormat:@"-"];
		tag = [NSString stringWithFormat:@"-"];
		type = [NSNumber numberWithInt:1];
		strength = [NSNumber numberWithInt:1];
		
    }
    return self;
}

-(void)dealloc{
	
	if(comment)
		[comment release];
	if(tag)
		[tag release];


	[super dealloc];
}

-(void)disconnect{
	//NSLog(@"disconnecting...");
	[materialA removeConnection:self];
	[materialB removeConnection:self];
}

-(NSDictionary *)dictionary{
	
	NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
	
	[dict setObject:comment forKey:@"comment"];
	if(![materialA name])
		NSLog(@"connection.m:dictinoary:materialA: no name!");
	
	[dict setObject:[materialA name] forKey:@"materialAName"];
	[dict setObject:[materialB name] forKey:@"materialBName"];
	[dict setObject:tag forKey:@"tag"];
	[dict setObject:type forKey:@"type"];
	
	/*	NSLog(@"connection.m:dictionary:writing dictionary for connection %@<->%@", [materialA name], [materialB name]);
	 if(![dict writeToFile:[NSString stringWithFormat:@"/Users/max/Desktop/TEST/connection_%@<->%@", [materialA name], [materialB name]] atomically:YES])
	 NSLog(@"FAILED!");
	 */	
	return [dict autorelease];
	
}


-(void)setIsVisible:(BOOL)b{
	
	visible = b;
}

-(BOOL)isVisible{
	return visible;
}

@end
