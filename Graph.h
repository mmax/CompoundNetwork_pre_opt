//
//  Graph.h
//  CompoundNetwork
//
//  Created by max on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GraphController, GraphCreator;

@interface Graph : NSView {

	NSScrollView * scrollView;
	IBOutlet GraphCreator * controller;
	BOOL displayDescription;
	NSString * descriptionString;
	NSPoint descriptionPoint;
}

-(void)allWhite;

@end
