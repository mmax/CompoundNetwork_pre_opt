//
//  Connection.h
//  CompoundNetwork
//
//  Created by max on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Material;

@interface Connection : NSObject {
	
	Material * materialA;
	Material * materialB;
	NSString * comment;
	NSString * tag;
	NSNumber * type;
	NSNumber * strength;
	BOOL visible;
}


-(Material *) materialA;
-(Material *) materialB;
-(NSString *) comment;
-(NSString *) tag;
-(NSNumber *) type;
-(NSNumber *) strength;

-(void)setMaterialA:(Material *)m;
-(void)setMaterialB:(Material *)m;
-(void)setComment:(NSString *)s;
-(void)setTag:(NSString *)s;
-(void)setType:(NSNumber *)t;
-(BOOL)isVisible;
-(void)setIsVisible:(BOOL)b;

-(Connection *)initWithMaterialA:(Material *)m;
-(void)disconnect;
-(NSDictionary *)dictionary;

@end