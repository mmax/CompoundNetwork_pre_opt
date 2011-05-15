//
//  Graph.m
//  CompoundNetwork
//
//  Created by max on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Graph.h"
#import "Node.h"
#import "GraphCreator.h"

#define sin_d(x) (sin((x)*M_PI/180)) 
#define kDescriptionRectSize 200

@implementation Graph

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        descriptionString = nil;
		displayDescription = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)rect{
	
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	//	NSLog(@"tadaaa");
	NSMutableSet * identityNodes = [[controller identityNodes]retain];
	//NSLog(@"identityNodes count: %d", [identityNodes count]);
	NSMutableSet * materialNodes = [[controller materialNodes]retain];
//	NSLog(@"graph material nodes: %d", [materialNodes count]);
	//NSLog(@"materialNodes count: %d", [materialNodes count]);
	//CGFloat lineDash[2] = {2, 2};
	//	float solidDash[2] = {1, 0};
	/* lineDash[0] = 3;
	 lineDash[1] = 5;
	 */	
	/* NSMutableArray * identityConnectionPaths = [self createIdentityConnectionPaths:[controller identityConnections]];
	 NSMutableArray * materialConnectionPaths = [self createIdentityConnectionPaths:[controller materialConnections]]; */
	
	//NSMutableArray * identityConnectionPaths = [self createPathsForConnections:[controller identityConnections] withLineDashing:lineDash andControlOffset:100];
	NSMutableSet * materialIdentityConnectionPaths = [controller materialIdentityConnectionPaths];//[self createPathsForConnections:[controller materialConnections] withLineDashing:lineDash andControlOffset:100];//[self createIdentityConnectionPaths:[controller materialConnections]];
	NSMutableSet * connectionPaths = [controller connectionPaths];
//	int i, 
	int fontSize;
	Node * currentNode;
	NSRect r;
	NSBezierPath * path;
	NSFont *font;
	NSRange tRange;
	NSPoint point;
	NSMutableAttributedString * s;
	int nameOffset = 2, lw = [NSBezierPath defaultLineWidth];	
	float grayscale;
	[[NSColor lightGrayColor]set];
	
	/* for(i=0;i<[identityConnectionPaths count];i++){
		//NSLog(@"stroking identity path: %d", i);
		[[identityConnectionPaths objectAtIndex:i] stroke];
		
	} */
	[[NSColor grayColor]set];

	
	
	for(path in materialIdentityConnectionPaths){//i=0;i<[materialIdentityConnectionPaths count];i++){
			//	path = [materialIdenityConnectionPaths objectAtIndex:i];
			//NSLog(@"stroking material path: %d", i);
			grayscale = [path miterLimit]; // stored the brightness in there in the [graphCreator createPathsForMaterialIdentityConnections] method
			//[[NSColor colorWithDeviceRed:0 green:grayscale blue:1-grayscale alpha:1]set];
			[[NSColor colorWithDeviceRed:grayscale green:grayscale blue:grayscale alpha:1]set];		
			[path stroke];
		}  
	
	
	
	[[NSColor blackColor]set];
	

	for(path in connectionPaths){//i=0;i<[connectionPaths count];i++){
		//[[connectionPaths objectAtIndex:i] stroke];
		[path stroke];
	}
	
	[NSBezierPath setDefaultLineWidth:2];
	for(currentNode in identityNodes){//i=0;i<[identityNodes count];i++){
		
		//currentNode = [identityNodes objectAtIndex:i];
		r = [currentNode rect];
		//NSLog(@"%@", NSStringFromRect(r));
		path = [NSBezierPath bezierPathWithRect:r];//[NSBezierPath bezierPathWithRoundedRect:r xRadius:20 yRadius:20];
		
		
		[[NSColor whiteColor]set];
		[path fill];
		[[NSColor blackColor]set];
		[path stroke];
		fontSize =  [currentNode fontSize];//9;//([currentNode defaultSize]-nameOffset) / [[currentNode name] length] * 1.5;
		font = [NSFont fontWithName:@"Helvetica Neue" size:fontSize];//[NSFont systemFontOfSize:fontSize];//[NSFont userFixedPitchFontOfSize:fontSize];
		
		
		s = [NSMutableAttributedString alloc];
		//NSLog(@"here?");
		[s initWithString:[currentNode name]];
		//NSLog(@"no");
		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor]/*[item color]*/ range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint([currentNode rect].origin.x+nameOffset/* ([currentNode defaultSize]/2)-([s length]*fontSize*0.5) */, [currentNode rect].origin.y+([currentNode defaultSize]/2)-fontSize / 2);
		//[s drawAtPoint:point];
		float width = [currentNode size]-6;
		NSRect textRect = NSMakeRect([currentNode center].x-(width-2)/2, [currentNode center].y-width/2, width-2, width);
		[s drawInRect:textRect];
		
		
	}
	[NSBezierPath setDefaultLineWidth:lw];
	//NSLog(@"%d material nodes!", [materialNodes count]);
	//for(Node * n in materialNodes)NSLog(@"%@", [n name]);
	for(currentNode in materialNodes){//i=0;i<[materialNodes count];i++){
		//NSLog(@"got a node...");
	//	currentNode = [materialNodes objectAtIndex:i];
		if([currentNode isVisible]){
			r = [currentNode rect];
			path = [currentNode path];//[NSBezierPath bezierPathWithOvalInRect:r];//[NSBezierPath bezierPathWithRoundedRect:r xRadius:20 yRadius:20];			
			[[NSColor whiteColor]set];
			[path fill];
			[[currentNode color]set];
			[path stroke];
			fontSize = [currentNode fontSize];//9;//([currentNode defaultSize]-nameOffset) / [[currentNode name] length] * 1.5;
			font = [NSFont fontWithName:@"Helvetica Neue" size:fontSize];//font = [NSFont systemFontOfSize:fontSize];//[NSFont userFixedPitchFontOfSize:fontSize];
			
			float width = sin_d(45)*[currentNode size];//sqrt([currentNode defaultSize]/2);
			NSRect textRect = NSMakeRect([currentNode center].x-width/2, [currentNode center].y-width/2, width, width);

			s = [NSMutableAttributedString alloc];
			[s initWithString:[currentNode name]];
	
			
			tRange = NSMakeRange(0, [s length]);	
			[s addAttribute:NSForegroundColorAttributeName value:[currentNode color]/*[item color]*/ range:tRange];
			[s addAttribute:NSFontAttributeName value:font range:tRange];
			//point = NSMakePoint([currentNode rect].origin.x+nameOffset/* ([currentNode defaultSize]/2)-([s length]*fontSize*0.5) */, [currentNode rect].origin.y+([currentNode defaultSize]/2)-fontSize / 2);
			[s drawInRect:textRect];//[currentNode rect]];//[s drawAtPoint:point];
		}
		
	}
		s = [NSMutableAttributedString alloc];
		
		NSString * date = [controller dateString];
		[s initWithString:date];
		//NSLog(@"no");
		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		point = NSMakePoint(130, 130);
		[s drawAtPoint:point]; 
	
	//[ drawAtPoint:NSMakePoint(50, 50)];// withAttributes:
	
	
	if(displayDescription){
		//NSLog(@"now drawing description...");
		NSRect r = NSMakeRect(descriptionPoint.x, descriptionPoint.y, kDescriptionRectSize, kDescriptionRectSize);
		[[NSColor colorWithDeviceRed:.9 green:.9 blue:.9 alpha:.9]set];// whiteColor]set];
		[NSBezierPath fillRect:r];
		[[NSColor grayColor]set];
		[NSBezierPath strokeRect:r];
		s = [NSMutableAttributedString alloc];
		//NSLog(@"description string?");
		[s initWithString: descriptionString];
		//NSLog(@"no");
		//NSLog(@"initialized");
		tRange = NSMakeRange(0, [s length]);	
		[s addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor]/*[item color]*/ range:tRange];
		[s addAttribute:NSFontAttributeName value:font range:tRange];
		//NSLog(@"attributes all set, ready for drawing...");
		//point = NSMakePoint(70, 70);///* ([currentNode defaultSize]/2)-([s length]*fontSize*0.5) */, [currentNode rect].origin.y+([currentNode defaultSize]/2)-fontSize / 2);
		NSRect r2 = NSMakeRect(r.origin.x+5, r.origin.y+5, r.size.width-10, r.size.height-10);
		[s drawInRect:r2];//AtPoint:point];
		//NSLog(@"done!");
		
	}
	
	[identityNodes release];
	[materialNodes release];
	//[[NSColor lightGrayColor]set];
	//[[controller ellipse] stroke];
	//	if(![controller controlPath])NSLog(@"NONONONO");
	//	else[[controller controlPath]stroke];
}

-(void)awakeFromNib {
	
	scrollView = [self enclosingScrollView];
	
    if (!scrollView) return;
	
	[scrollView setDocumentView: self];
	
	[scrollView setDrawsBackground:YES];
	[scrollView setBackgroundColor:[NSColor whiteColor]];//[NSColor lightGrayColor]];
	
	
}



-(void)allWhite{
	[[NSColor redColor] set];
	[NSBezierPath fillRect:[self bounds]];
	[[NSColor blackColor] set];
}

@end
