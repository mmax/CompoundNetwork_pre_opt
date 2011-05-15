//
//  Node.m
//  CompoundNetwork
//
//  Created by max on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Node.h"


@implementation Node


-(NSRect)rect{
	
	NSRect cRect;
	cRect.origin=nodeLocation;
	cRect.size.width = width;
	cRect.size.height = height;
	
	return cRect;
}

-(int)defaultSize{return kNodeSize;}

-(void)setRect:(NSRect)crect{
	//NSLog(@"yes, node_rect_set!");
	rect = crect;
}

-(Node *)init{
	
	self = [super init];
    if (self) {
		
		width = kNodeSize;
		height = kNodeSize;
		isVisible = YES;
		fontSize = kNodeFontSize;//9;
		nodeColor = [NSColor blackColor];
		
	}
	return self;
}

-(void)dealloc{

	if(mat)
		[mat release];
	if(path)
		[path release];
	if(name)
		[name release];
	
	[super dealloc];
}

-(void)setLocation:(NSPoint)loc{
	
	nodeLocation = loc;
	
}

-(NSPoint)location{return nodeLocation;}
-(void)setName:(NSString *)s{
	if(name)
		[name release];
	name = [s retain];
	//NSLog(@"Node: setName: %@", name);
}

-(NSString *)name{return name;}

-(NSPoint)center{
	
	float x, y;
	
	x = nodeLocation.x+width*.5;
	y = nodeLocation.y+height*.5;
	return NSMakePoint(x, y);
	
}

-(void)setIsVisible:(BOOL)b{
	
	isVisible= b;
	
}
-(BOOL)isVisible{
	
	return isVisible;
}


-(int)size{
	
	return width;
}

-(void)setSize:(int)s{
	
	width = s;
	height = s;
}

-(void)setMaterial:(Material*)m{
	if(mat)
		[mat release];
	
	mat = [m retain];
	[self setIsVisible:[m isVisible]];
}

-(Material *)material{return mat;}

-(int)fontSize{return fontSize;}
-(void)setFontSize:(int)f{fontSize = f;}

-(NSBezierPath *)path{return path;}

-(void)setPath:(NSBezierPath *)p{
	if(path)[path release];
	path = [p retain];
}

-(void)setColor:(NSColor *)c{nodeColor = c;}
-(NSColor *)color{return nodeColor;}


@end
