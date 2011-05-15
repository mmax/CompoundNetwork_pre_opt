//
//  Node.h
//  CompoundNetwork
//
//  Created by max on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



#define kNodeSize 120 //65//50
#define kNodeSubsetSize 100 //90 //45//35
#define kNodeOffset 250 //140
#define kNodeFontSize 18 //9
#define kNodeSubsetFontSize 18 //9//7

@class Material;

@interface Node : NSObject {
	
	NSPoint nodeLocation;
	NSRect rect;
	float width;
	float height;
	NSString * name;
	BOOL isVisible;
	Material * mat;
	int fontSize;
	NSBezierPath * path;
	NSColor * nodeColor;
	
}

-(void)setRect:(NSRect)rect;
-(NSRect)rect;
-(void)setLocation:(NSPoint)loc;
-(void)setName:(NSString *)s;
-(int)defaultSize;
-(NSString *)name;
-(NSPoint)center;
-(void)setIsVisible:(BOOL)b;
-(BOOL)isVisible;
-(int)size;
-(void)setSize:(int)s;
-(void)setMaterial:(Material*)m;
-(Material *)material;
-(int)fontSize;
-(void)setFontSize:(int)f;
-(NSBezierPath *)path;
-(void)setPath:(NSBezierPath *)p;
-(void)setColor:(NSColor *)c;
-(NSColor *)color;
-(NSPoint)location;
@end
