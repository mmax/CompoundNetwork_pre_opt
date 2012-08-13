//
//  GraphCreator.m
//  CompoundNetwork
//
//  Created by max on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphCreator.h"
#import "MyDocument.h"
#import "Node.h"
#import "Graph.h"
#import "Material.h"
#import "Connection.h"

#define sqr(x) ((x)*(x)) 
#define sin_d(x) (sin((x)*M_PI/180)) 
#define cos_d(x) (cos((x)*M_PI/180)) 
#define tan_d(x) (tan((x)*M_PI/180)) 
#define asin_d(x) (asin(x)*180/M_PI) 
#define acos_d(x) (acos(x)*180/M_PI) 
#define atan_d(x) (atan(x)*180/M_PI) 

#define kResizeFactor 1.7
#define kRepositionDepthMax 100


@implementation GraphCreator


-(GraphCreator *)init{


	if(self = [super init]){
	
		dict = [[NSMutableDictionary alloc]init];
		dateString = [NSString stringWithString:@"DUMMYSTRING"];
	}
	return self;
}

-(void)dealloc{

	[dict removeAllObjects];
	[dict release];
	[super dealloc];
}


-(void)render{
[self createDateString];
	repositionDepth = 0;
	[doc setIndeterminateProgressTask:@"rendering..."];
	[doc displayProgress:YES];
	
	NSLog(@"rendering with size: %@", [NSValue valueWithSize:[self size]]);
	
	
	if(![self check]){
		[doc displayProgress:NO];
		return;
	}
	[self renderIdentityNodes];
	NSLog(@"identities rendered successfully. number of nodes: %lu", [[self valueForKey:@"identityNodes"]count]);
		[window orderFront:nil];
	[self renderMaterialNodes];
	NSLog(@"materials rendered successfully. number of nodes: %lu", [[self valueForKey:@"materialNodes"]count]);

	
	////
	/*
	[self createDateString];
	[graph setNeedsDisplay:YES];
	
	[window makeKeyAndOrderFront:nil];
	[doc displayProgress:NO];*/
	

}

-(BOOL)check{

	for(Material * m in (NSArray *)[doc valueForKey:@"materials"]){
		if (![(NSArray *)[m valueForKey:@"identities"]count]) {
			[doc createErrorFromString:[NSString stringWithFormat:@"ERROR: material %@ does not belong to any identities!", [m name]]];
			return NO;
		}
		if (![(NSArray *)[m valueForKey:@"tags"]count]) {
			[doc createErrorFromString:[NSString stringWithFormat:@"Warning: material %@ does not have any tags!", [m name]]];
			return NO;
		}
	}
	return YES;
}

-(void)retry{
	
	/* [NSTimer scheduledTimerWithTimeInterval:5 
											 target:self
										   selector: @selector(render) 
										   userInfo:nil
											repeats:NO]; */
	
	NSSize newSize = NSMakeSize([self size].width * kResizeFactor, [self size].height * kResizeFactor);
	[self resizeTo:newSize];
	
	[self render];
}

-(void)setDoc:(MyDocument *)d{doc = d;}

-(void)renderIdentityNodes{
	//NSLog(@"rendering identities");
	
	[doc setIndeterminateProgressTask:@"Rendering Identities..."];
	[doc displayProgress:YES];
	//NSMutableArray * identityNames = [self sortedIdentityNames];	
	NSMutableArray * identityNames = [[doc identityNames]retain];
	//	NSLog(@"identityNames:%@", identityNames);
	NSMutableSet * identityNodes = [[[NSMutableSet alloc]init]autorelease];
	

	int i,  max = [identityNames count];
	float a, b, x, y;
	NSSize ownSize = [self size];
	b = [self size].height*.5-kNodeSize*2;
	a = [self size].width*.5-kNodeSize*2;
	Node * n, * v;
	NSPoint center = [self center];
	NSEnumerator * e;
	
	BOOL retryFlag = YES;
	
	for(i=0;i<max;i++){
		
		x = a*cos((2*M_PI*i)/max);
		y = b*sin((2*M_PI*i)/max);
		
		retryFlag = NO;
		
		n = [[[Node alloc]init]autorelease];
		[n setName:[identityNames objectAtIndex:i]];
		[n setLocation:NSMakePoint(center.x+x-kNodeSize*.5, center.y+y-kNodeSize*.5)];
		e = [identityNodes objectEnumerator];
		while(v = [e nextObject]){
			
			if([self doesNodeRect:[n rect] collideWithNodeRect:[v rect]]){
				
				retryFlag = YES;
				[self resizeTo:NSMakeSize(ownSize.width*1.5, ownSize.height*1.5)];
				[identityNodes removeAllObjects];
				[graph allWhite];	
				NSLog(@"Creator:renderIndentityNodes:Collision:break");
				break;
			}
		}
		if(!retryFlag){
			[identityNodes addObject:n];
			//NSLog(@"adding node: %@", [ n name]);
		}
		else
			break;
		
	}
	[self setValue:identityNodes forKey:@"identityNodes"];
	if(retryFlag)
		[self renderIdentityNodes];
	else
		[self fixIdentityDistances];
	
	
	[identityNames release];
}

-(NSSize)size{return [graph bounds].size;}
-(NSPoint)center{return NSMakePoint([self size].width*.5, [self size].height*.5/* -(kNodeSize*.5) */);}


-(void)setValue:(id)value forKey:(NSString *)key{
	
	[dict setValue:value forKey:key];
}

-(id)valueForKey:(NSString *)key{
	
	return [dict valueForKey:key];
}

-(id)valueForKeyPath:(NSString *)keyPath{
	NSArray * keys = [keyPath componentsSeparatedByString:@"."];
	id val = self;
	for(NSString * key in keys)
		val = [val valueForKey:key];
	return val;
} 


-(BOOL)doesNodeRect: (NSRect) r1 collideWithNodeRect:(NSRect) r2{
	
	float distance = kNodeOffset;
	
	// build an enclosing rect for r1 that is big enough for r1 and one offset-unit in every direction:
	
	NSRect rectA = NSMakeRect(r1.origin.x-distance*.5, r1.origin.y-distance*.5, r1.size.width+distance, r1.size.height+distance);
	//NSLog(@"collide? testing %@ and %@", NSStringFromRect(rectA), NSStringFromRect(r2));
	return NSIntersectsRect(rectA, r2); // if r2 intersects with that enclosing rect, they are too close
	
}


-(void)fixIdentityDistances{
	
	double avgDistance= [self avgIdentityDistance];
	//NSLog(@"avgDist: %f", avgDistance);
	
	NSArray * sortedIdentities = [self sortedIdentities];
	
	//NSLog(@"sortedIdentities count: %d", [sortedIdentities count]);
	NSArray * points;//, *ellipseArray = [self pointArrayForEllipse];
	
	NSPoint nodeLocation, destination, ca, cb;
	NSSize nodeSize;
	Node * n;
	int i, index;
	[doc setIndeterminateProgressTask:@"fixing identity node locations..."];
	[doc displayProgress:YES];
	for(i=0;i<[sortedIdentities count];i++){
		
		n = [sortedIdentities objectAtIndex:i];	// get current node;
		points = [self intersectionPointsOnEllipse:[self pointArrayForEllipse] forNode:n withAverageDistance:avgDistance];//retain];	//get it's intersectionpoints
		//NSLog(@"points for node %@: %@", [n name], points);
		index = (i+1)%[sortedIdentities count];
		//NSLog(@"i: %d index: %d", i, index);
		n = [sortedIdentities objectAtIndex:index]; //get next node
		//NSLog(@"got next node: %@", [n name]);
		nodeSize = [n rect].size;
		nodeLocation = [n center]; // get it's location
		
		if([points count]!= 2){
			NSLog(@"GraphCreator:fixIdentityDistances:didn't get intersection points for node %@", [n name]);
			return;
		}
		//NSLog(@"trying to correct location for node %@\n\t currently located at %@\n\tnow choosing destination...", [n name], [NSValue valueWithPoint:nodeLocation]);
		ca = [[points objectAtIndex:0]pointValue];
		cb = [[points objectAtIndex:1]pointValue];
		if([self distanceBetweenPointA:ca andB:nodeLocation] < [self distanceBetweenPointA:cb andB:nodeLocation])
			destination = ca;
		else
			destination = cb;
		[n setLocation:NSMakePoint(destination.x - (nodeSize.width*0.5), destination.y - (nodeSize.height*0.5))];
		//[points release];
	}
	

}

-(NSArray *)intersectionPointsOnEllipse:(NSArray *)ellipsePoints forNode:(Node *)n withAverageDistance:(double)r{
	
	
	[ellipsePoints retain];
	NSMutableArray * points = [[[NSMutableArray alloc]init]autorelease];
	NSArray * circle = [[self pointArrayForCircleAroundNode:n radius:r]retain];
	long c;//, e;
	NSPoint cPoint, ePoint;
	double tolerance, aSquare, alpha = .5, a;
	aSquare = 2* pow(r, 2) - (2*pow(r, 2)*cos_d(alpha));
	a = pow(aSquare, 0.5);
	tolerance = a;
    NSValue * val;
	//NSLog(@"tolerance: %f", tolerance);
	
	for(c=0;c<[circle count];c++){
		cPoint = [[circle objectAtIndex:c]pointValue];
        NSEnumerator *en = [ellipsePoints objectEnumerator];
        
		//for(e=0;e<[ellipsePoints count];e++){
        while(val = [en nextObject]){
			ePoint = [val pointValue];
			if([self distanceBetweenPointA:cPoint andB:ePoint]<tolerance){
				[points addObject:[NSValue valueWithPoint:cPoint]];
				if([points count] && c<[circle count]*.25)
					c+=[circle count]*.25;
			}
		}
	}
	[ellipsePoints release];
	[circle release];
	return [self removeDuplicatePointsFromArray:points withTolerance:kNodeSize];
}

-(NSArray *)removeDuplicatePointsFromArray:(NSArray *)points withTolerance:(double)d{
	
	
	int i;
	//double xa,xb, ya, yb;
	//	NSPoint a, b;
	NSMutableArray * new = [[NSMutableArray alloc]init];
	[new addObject:[points objectAtIndex:0]];
	for(i=1;i<[points count];i++){
		if(![self isPoint:[[points objectAtIndex:i]pointValue] inArray:new withTolerance:d])
			[new addObject:[points objectAtIndex:i]];	
	}
	return [new autorelease];
}


-(double)avgIdentityDistance{
	
	NSArray * sortedIdentities= [self sortedIdentities];
	
	double distance, sum =0;
	int i, nextnode;
	
	for(i=0;i<[sortedIdentities count];i++){
		
		if(i<[sortedIdentities count]-1)	
			nextnode = i+1;
		else nextnode = 0;
		
		distance = [self distanceBetweenNode:[sortedIdentities objectAtIndex:i] andNode:[sortedIdentities objectAtIndex:nextnode]];
		//NSLog(@"distance: %f", distance);
		sum +=distance;
	}
	
	return sum / [(NSSet *)[self valueForKey:@"identityNodes"] count];
}

-(NSArray *)sortedIdentities{
	
	NSMutableArray * sortedIdentities= [[[NSMutableArray alloc]init]autorelease];
	NSArray * names = [doc identityNames];
	int i;
	for(i=0;i<[(NSSet *)[self valueForKey:@"identityNodes"] count];i++)
		[sortedIdentities addObject:[self identityNodeWithName:[names objectAtIndex:i]]];
	return sortedIdentities;//[sortedIdentities retain];
}

-(void)resizeTo:(NSSize)s{
	
	[graph setFrameSize:s];
	//[myGraph setNeedsDisplay:YES];
	
}

-(double) distanceBetweenNode:(Node *)a andNode:(Node *)b{
	
	return [self distanceBetweenPointA:[a center] andB:[b center]];
}

-(double)distanceBetweenPointA:(NSPoint)a andB:(NSPoint)b{
	
//	double deltaX = abs(b.x - a.x);
//	double deltaY = abs(b.y - a.y);
//	return pow(pow(deltaX, 2)+pow(deltaY, 2), 0.5);
    
    return pow(pow(b.x - a.x, 2)+pow(b.y - a.y, 2), 0.5);
}

-(Node *)identityNodeWithName:(NSString *)n{
	
	NSPredicate *pred  = [NSPredicate predicateWithFormat:@"%K MATCHES %@", @"name", n];
	NSSet * newSet =[(NSSet*)[self valueForKey:@"identityNodes"] filteredSetUsingPredicate:pred]; 
	return [newSet anyObject];
}

-(NSArray *)pointArrayForEllipse{
	
	float i, a, b, x, y=0;
	b = [self size].height*.5-kNodeSize*2;
	a = [self size].width*.5-kNodeSize*2;


	NSMutableArray * points = [[NSMutableArray alloc]init];
	NSPoint center = [self center];
	
	for (i=-1*a;i<a;i+=2){//0.5){
		x = i;
		y = pow( ( ( 1- ( pow(x, 2)/pow(a, 2) ) )*pow(b,2) ), 0.5);
		[points addObject:[NSValue valueWithPoint:NSMakePoint(x+center.x, y+center.y)]];
	}
	
	for (i=-1*a;i<=a;i+=2){//0.5){
		x = i;
		y = pow( ( ( 1- ( pow(x, 2)/pow(a, 2) ) )*pow(b,2) ), 0.5) * -1;
		[points addObject:[NSValue valueWithPoint:NSMakePoint(x+center.x, y+center.y)]];
	}
	return [points autorelease];
}

-(NSArray *)pointArrayForCircleAroundNode:(Node*)n radius:(double)r{
	//NSLog(@"inPointArray...");
	
	NSMutableArray * points = [[NSMutableArray alloc]init];
	float i, flag;
	double winkel, sinusWinkel, deltaX, deltaY;
	NSPoint M = [n center], p;
	
	for (i=0;i<=360;i+=2){//=0.5){
		winkel = i;
		sinusWinkel = sin(i*0.0174532925199);
		if(winkel<90 || winkel > 270)flag = -1;
		else flag = 1;
		deltaY = sinusWinkel*r;
		
		deltaX = sqrt(1-pow(sinusWinkel, 2))*r*flag;
		p = NSMakePoint(M.x+deltaX, M.y+deltaY);
		[points addObject:[NSValue valueWithPoint:p]];
	}
	//NSLog(@"%@", [points description]);
	return [points autorelease];
}

-(BOOL)isPoint:(NSPoint)p inArray:(NSArray *)points withTolerance:(double)d{
	
	int i;
	NSPoint b;
	for (i=0;i<[points count];i++){
		b = [[points objectAtIndex:i]pointValue];
		if(abs(b.x - p.x)<d && abs(b.y - p.y)<d)
			return YES;
	}
	return NO;
}

-(void)renderMaterialNodes{
	
	Node * n;
	NSString  * name;
	NSPoint perfectLocation;
	//int i;
	//NSSize newSize;
	NSMutableArray * materialNames = [NSMutableArray arrayWithArray:[doc materialNames]];
	NSArray * subsetNames;
	Material * mat = nil;
	[(NSMutableSet *)[self valueForKey:@"materialNodes"] removeAllObjects];
	NSMutableSet * materialNodes = [[[NSMutableSet alloc]init]autorelease];
	[self setValue:materialNodes forKey:@"materialNodes"];
	NSLog(@"materialNames count: %lu", [materialNames count]);
	/* for(NSString * name in materialNames){// */

	while([materialNames count]){

		repositionDepth = 0;
		
		name = [materialNames lastObject];
		mat = [doc getMaterialByName: name];
		
		if([mat isSubset]== YES){
			
			mat = [self getTopMaterialOfSubSetClusterWithMaterial:mat];
			name = [mat name];
		}
		
		[doc setIndeterminateProgressTask:[NSString stringWithFormat:@"Rendering Material: '%@'...", name]];
//		[doc setProgress:(100.0/[[doc materials] count]) * ([[doc materials] count] - [materialNames count])];
		
		// now sure to have a "supermaterial", BUT we could have N layers of subsets!
		
		perfectLocation = [self perfectLocationForMaterialNodeWithName:name];	
		n = [[[Node alloc]init]autorelease];
		//NSLog(@"creating node for material: %@", name);
		[n setLocation: perfectLocation];
		[n setName:name];
		[n setMaterial:mat];
		[n setIsVisible:[mat isVisible]];
		[mat setNode:n];
		if (![self alreadyHasNodeWithName: name inSet:materialNodes] ) {
			[materialNodes addObject:n];
		}

		
		if([[mat subsets]count]>0){
			NSLog(@"creating subset nodes...");
			[self createSubsetNodesForNode:n];
		}
		
		
		subsetNames = [[self getSubsetClusterNamesArrayForNode:n]retain];//[[doc materialWithName:name]subsetNames];
		
		///PROBABLY THIS DOES NOT WORK?
		//NSLog(@"before: count :%d]", [materialNames count]);
		[materialNames removeObjectsInArray:subsetNames];
		[subsetNames release];
		
		//NSLog(@"rendering material: %@, so far so good. now checking position...", name);
		
		if(![self repositionNodeIfNecessary:n]){ // if unsuccessful, 
			NSLog(@"GraphCreator: about to retry...");
			//delete all nodes, resize canvas an try again
			NSLog(@"RESTART_______________________________________\n____________________________________\n");
			//[(NSMutableSet *)[self valueForKey:@"identityNodes"] removeAllObjects];
			//[materialNodes removeAllObjects];
			
			//[graph allWhite];
			//[self retry];
			//[n release];
			//return;
		} 
		//[n release];
		[graph setNeedsDisplay:YES];
		//NSLog(@"all ok!");
		//NSLog(@"end: materialNames count: %d", [materialNames count]);
		
		repositionDepth = 0;
		/* break; */
	}
	
	
	[self renderMaterialNodePaths];
	NSLog(@"materialNodePaths rendered successfully");
	
	/*[self renderIdentityConnections];
	 //NSLog(@"materialConnections");
	 [self renderMaterialConnections];*/
	[self createPathsForMaterialIdentityConnections];
	NSLog(@"connections between materials and identities rendered successfully");	
	//NSLog(@"connectionConnections");	
	[self createPathsForConnections];
	NSLog(@"connections between materials rendered successfully");
	[self createDateString];
	[graph setNeedsDisplay:YES];
	
	[window orderFront:nil];
	[doc displayProgress:NO];
	
	
	//NSLog(@"DONE!");
	//NSLog(@"identityConnections");
	
}

-(BOOL)alreadyHasNodeWithName:(NSString *)name inSet:(NSSet *)materialNodes{

	for(Node * n in materialNodes){
		if([[n name]isEqualToString:name])
			return YES;
	}
	return NO;
}

-(Material *)getTopMaterialOfSubSetClusterWithMaterial:(Material *)m{	
	//	NSLog(@"doc: looking for topMaterialOfSubsetClusterWithMaterial: %@", [m name]);
	if([m isSubset])
		return [self getTopMaterialOfSubSetClusterWithMaterial:[m superMaterial]];
	//	NSLog(@"found: %@", [m name]);
	return m;
}

-(NSPoint)perfectLocationForMaterialNodeWithName:(NSString *)s{
	
	Material * mat = [doc getMaterialByName:s];
	NSPoint center = [self center];
	int i;
	
	if([(NSArray *)[mat valueForKey:@"identities"]count] == 0) return center;
	
	NSPoint point, dest;
	NSDictionary * d;
	
	float deltaX, deltaY,match;//, c;
	NSMutableArray * identityDicts = [NSMutableArray arrayWithArray: (NSArray *)[mat valueForKey:@"identities"]];
	
	NSSortDescriptor * sd = [[[NSSortDescriptor alloc]initWithKey:@"match" ascending:NO]autorelease];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[identityDicts sortUsingDescriptors:descriptors];
	
	d = [identityDicts objectAtIndex:0];
	point = [self startPointForIdentityNode:[self identityNodeWithName:[d valueForKey:@"name"]]];
	match = [[d valueForKey:@"match"]floatValue];
	
	if(match<100){
		
		dest = point;
		point = center;
		deltaX = ((dest.x - point.x)) * (match / 100);//100 natürlich eigentlich (percent) !!!
		deltaY = ((dest.y - point.y)) * (match / 100);//100 natürlich eigentlich (percent) !!!
		point.x+=deltaX;
		point.y+=deltaY;
	}
	// now, dragin the node toward other identities...
	
	
	for(i=1;i<[identityDicts count];i++){
		
		d = [identityDicts objectAtIndex:i];
		match = [[d valueForKey:@"match"]floatValue];
		//NSLog(@"identity: %@, match: %f", [dict valueForKey:@"name"], match);
		//computing 100% match - point for next identit
		dest = [self startPointForIdentityNode:[self identityNodeWithName:[dict valueForKey:@"name"]]];
		
		// now find out and apply the actual "deltas"
		
		deltaX = ((dest.x - point.x)/2) * ((match) / 100);//100 natürlich eigentlich (percent) !!!
		deltaY = ((dest.y - point.y)/2) * ((match) / 100);//100 natürlich eigentlich (percent) !!!
		
		point.x+=deltaX;
		point.y+=deltaY;
		//point = [self getPointNearerToCenter:kNodeSize*.5 fromPoint:point]; // move closer to center
	}
	
	return point;
}



-(NSPoint) startPointForIdentityNode:(Node *)n{
	
	NSPoint point = [n rect].origin;
	
	point.x += [n size]*.5;
	point.y += [n size]*.5;
	
	NSPoint center = [self center];
	float m, deltaX, deltaY, alpha, a, b, c;
	
	deltaX = (center.x - point.x);
	deltaY = (center.y - point.y);
	m = deltaY / deltaX; //*.5 new! and dirty!!
	
	alpha = atan(m);
	c = kNodeSize*7 + kNodeOffset; // min distance to "mother" identity // was 4 
	a = sin(alpha)*c;
	b = cos(alpha)*c;
	//NSLog(@"computing startPoint. a: %f", a);
	point.x += b * (deltaX > 0 ? 1 : -1) + (deltaX > 0 ? (deltaX * 0.2) : (deltaX * -0.2));
	point.y += abs(a) * (deltaY > 0 ? 1 : -1) + (deltaY > 0 ? (deltaY * 0.2) : (deltaY * -0.2));
	point.x -=[n size]*.5;
	point.y -=[n size]*.5;	
	
	return point;
}


-(void) createSubsetNodesForNode:(Node *)nod{

	float winkel, sinusWinkel, deltaX, deltaY, rDefault, uMin, uDefault, r, /* m, alpha, */ startWinkel, bow;//, t, g;
	NSArray * subsetNames = [[[nod material]subsetNames]retain];
	int flag, i, num = [subsetNames count];	
	
	NSPoint center = [nod center];
	Node * n;
	Material * mat;
	
	mat = [nod material];
	bow = 180;//360;

	if([mat isSubset]) 
		bow = 90;

	startWinkel = [self getStartWinkelForSubsetsOfNode:nod];//[self materialNodeWithName:[mat name]]];
	if([mat isSubset]) startWinkel+=90;
	
	for(i=0;i<num;i++){

		if(i==0) 
			winkel = 0;
		else
			winkel = (bow / (num-1))*i;

		winkel += startWinkel;
		if(winkel>360) winkel -=360;
		sinusWinkel = sin_d(winkel);//(winkel*0.0174532925199);
		uMin = num * (kNodeSubsetSize + kNodeOffset/2)*2;
		rDefault = kNodeSize*.5 + kNodeOffset;
		uDefault = 2*M_PI*rDefault;
		
		if(uMin > uDefault)
			r = uMin/2/M_PI;
		else
			r = rDefault;
		
		deltaY = sinusWinkel*r - (kNodeSubsetSize *.5);
		
		if(winkel<90 || winkel > 270)flag = -1;
		else flag = 1;
		
		deltaX = sqrt(1-pow(sinusWinkel, 2)) *r *flag- (kNodeSubsetSize*.5);
		n = [[[Node alloc]init]autorelease];
		[n setName:[subsetNames objectAtIndex:i]];
		
		[n setLocation:NSMakePoint(center.x+deltaX, center.y+deltaY)];//[self newPointForIdentity:[doc identityWithName:[identityNames objectAtIndex:i]]]];
		[n setSize:kNodeSubsetSize];
		mat = [doc getMaterialByName:[subsetNames objectAtIndex:i]];
		[n setMaterial:mat];
		[n setIsVisible:[mat isVisible]];		
		[mat setNode:n];
		[n setFontSize:kNodeSubsetFontSize];
		if (![self alreadyHasNodeWithName: [n name] inSet:[self valueForKey:@"materialNodes"]] )
			[[self valueForKey:@"materialNodes"] addObject:n];	
		
		if([[mat subsets]count]>0)
			[self createSubsetNodesForNode:n];
	}
	[subsetNames release];
}

-(float)getStartWinkelForSubsetsOfNode:(Node *)n{
	
	float deltaX, deltaY, /* m, */ alpha, startWinkel=0, /* flag, */ a, c, b;
	
	if([[n material]isSubset])
		return [self getStartWinkelForSubsetsOfNode:[self materialNodeWithName:[[[n material] superMaterial]name]]];
	
	NSPoint center = [self center];
	NSPoint nodeCenter = [n center];
	//NSLog(@"getStartWinkelForSubsetsOf:%@, position: %@", [n name], NSStringFromPoint([n rect].origin));
	deltaX = center.x - nodeCenter.x;
	deltaY = center.y - nodeCenter.y;
	
	a = deltaY;
	b = deltaX;
	
	c = sqrt(pow(a, 2)+pow(b, 2));
	alpha = asin_d(a/c);
	
	if(deltaX > 0 && deltaY > 0)	
		startWinkel = 90-alpha;
	else if(deltaX > 0 && deltaY < 0)
		startWinkel = 90+abs(alpha);
	else if(deltaX < 0 && deltaY > 0)
		startWinkel = 270+abs(alpha);
	else if(deltaX < 0 && deltaY < 0)
		startWinkel = 270-abs(alpha);
		//NSLog(@"%@: b:%f a:%f, aplha:%f, startWinkel:%f, flag: %f, nodeCenter: %@", [n name], b, a, alpha, startWinkel, flag,  NSStringFromPoint(nodeCenter));
	return startWinkel;
}


-(Node *)materialNodeWithName:(NSString *)s{
	
	/* NSPredicate *pred  = [NSPredicate predicateWithFormat:@"%K MATCHES %@", @"name", s];
		NSSet * newSet =[(NSSet *)[self valueForKey:@"materialNodes"] filteredSetUsingPredicate:pred]; 
		NSLog(@"materialNodeWithName: searching for node named: %@, found:%@", s, [newSet anyObject]);
		return [newSet anyObject]; */
	
	for(Node * n in (NSSet *)[self valueForKey:@"materialNodes"]){
		if ([[n name]isEqualToString:s])
			return n;
	}
	[doc createErrorFromString:[NSString stringWithFormat:@"could not find materialNode with name: %@", s]];
	return nil;	
}

-(NSMutableArray *)getSubsetClusterNamesArrayForNode:(Node *)n{
	
	//NSLog(@"createSubsetClusterNamesArrayForNode: %@", [n name]);
	NSString * name = [n name];
	Material  * subMaterial, * superMaterial = [doc getMaterialByName:name];
	NSEnumerator * subsetEnumerator = [[superMaterial subsets] objectEnumerator];
	NSMutableArray * clusterNames = [[[NSMutableArray alloc]init]autorelease];//, * clusterNodes = [[NSMutableArray alloc]init];
	
	while(subMaterial = [subsetEnumerator nextObject]){
		//NSLog(@"alright?, name:%@", name);
		name = [subMaterial name];
		[clusterNames addObject:name];
		
		if([[subMaterial subsets]count]>0){
			//NSLog(@"RECURSION!");
			Node * nod = [self materialNodeWithName:name];
			if(!nod){
			
				[doc createErrorFromString:[NSString stringWithFormat:@"coulndn't find node for material with name:%@", name]];
				break;
			}
			NSArray * nms = [self getSubsetClusterNamesArrayForNode:nod];
			//NSLog(@"namesarray: %@", nms);
			[clusterNames addObjectsFromArray:nms];
		}
		//NSLog(@"yes");
	}
	//NSLog(@"here? -> n:%@", n);
	//if(![clusterNames containsObject:[n name]])
		[clusterNames addObject:[n name]];
	//NSLog(@"no");
	
	
	return clusterNames;
}

-(BOOL)repositionNodeIfNecessary:(Node*)c{
	
	Node * n; 
	//repositionDepth=0;
	while((n = [self collidingNodeForNode:c]) && repositionDepth < kRepositionDepthMax){
		//repositionDepth++;
		
		[self repositionNodes:c and:n];

		repositionDepth++;
		//NSLog(@"repositionNodeIfNecessary: repositiondepth: %d", repositionDepth);
		//NSLog(@"repositionNodeIfNecessary: c: %@ node-center: %@", [c name], [NSValue valueWithPoint:[c center]]);
		
		if (![self isPoint:[c location] inRect:[self bounds]] || ![self isPoint:[c center] inRect:[self bounds]] ||
			![self isPoint:[n location] inRect:[self bounds]] || ![self isPoint:[n center] inRect:[self bounds]]){
			//NSLog(@"out of bounds!");
			NSPoint perfect = [self perfectLocationForMaterialNodeWithName:[c name]];
			//NSLog(@"trying to reposition to perfect spot: %@", [NSValue valueWithPoint:perfect]);
			[c setLocation:perfect];
			return [self repositionNodeIfNecessary:c];
			//return NO;
		}
		if(repositionDepth < kRepositionDepthMax){// && ![[n material]isSubset]){
			
			[self repositionNodeIfNecessary:n];
			
		}
	}
	if(repositionDepth < kRepositionDepthMax)
		return YES;
	
	return NO; // unsuccessful need to resize!
}

-(Node *)collidingNodeForNode:(Node*)c{
	/* if([[c material]isSubset])
	 [doc createErrorFromString:@"testing for Collision of a subset node!"];
	 */
	NSEnumerator * e;
	Node * n;
	e = [(NSSet *)[self valueForKey:@"materialNodes"] objectEnumerator];
	NSRect rectA, rectB;
	rectA = [[self getUnionRectForNode:c]rectValue];
//	Material * mat;
	while(n = [e nextObject]){
		if(![n isEqual:c] && ![self areNodesSubsetWiseConnected:n and:c]){
			//mat = [n material] ;
			//if([mat isSubset] == YES || [[mat subsetNames] count] > 0){ // if it is a subset or has subsets itsself look at the entire group of nodes
			rectB = [[self getUnionRectForNode:n] rectValue];
			
			if([self doesNodeRect:rectA collideWithNodeRect:rectB])
				return n;
		}
	}
	return nil;
}


-(void) repositionNodes: (Node *) nodeA and: (Node*) nodeB{ 
	//NSLog(@"repositioning nodes %@ and %@", [nodeA name],[nodeB name]);
	
	if([self areNodesSubsetWiseConnected:nodeA and:nodeB])
		[doc createErrorFromString:[NSString stringWithFormat:@"trying to reposition nodes within the same subsetCluster: %@ and %@", [nodeA name], [nodeB name]]];
	
	NSPoint center = [self center], origin;
	NSRect unionRectA, unionRectB;//, tempRect;
	float m, deltaX, deltaY, alpha, a, b, c, rx, ry, x, y;//, distance;//, deltaDistance;

	Node * na, *nb;
	if([[nodeA material] isSubset])
		na = [self materialNodeWithName:[[self getTopMaterialOfSubSetClusterWithMaterial:[nodeA material]]name]];
	else
		na = nodeA;
	
	if([[nodeB material] isSubset])	{
		
		nb = [self materialNodeWithName:[[self getTopMaterialOfSubSetClusterWithMaterial:[nodeB material]]name]];
		//NSLog(@"resetted nb to topofsubsetcluster. nb:name: %@", [nb name]);
	}
	else
		nb = nodeB;
	
	if(equalPoints([na rect].origin, [nb rect].origin)){
		NSLog(@"EQUAL POINTS");
		origin = [nb rect].origin;
		deltaX = center.x - origin.x;
		deltaY = center.y - origin.y;
		m = deltaY / deltaX;
		
		alpha = atan_d(m);
		c = kNodeSize + kNodeOffset;// 10 anything small // doesnt matter kNodeSize + kNodeOffset; // min distance to "mother" identity
		a = sin_d(alpha)*c;
		b = cos_d(alpha)*c;
		//NSLog(@"computing startPoint. a: %f", a);
		rx = b * (deltaX > 0 ? 1 : -1);
		ry = abs(a) * (deltaY > 0 ? 1 : -1);
		
		origin.x -= ry*.5; // vertauscht! ->  90° zur linie zum mittelpunkt
		origin.y += rx*.5;
		
		[nb setLocation:origin];

		origin = [na rect].origin;
		origin.x += ry*.5;
		origin.y -= rx*.5;
		[na setLocation:origin];
		
		//[self repositionNodes:na and:nb];
		//return;
	}
	
	else{
        
        //kNode = kNodeSize;
        NSPoint p1, p2;
        
        //make sure we have the rects for entire subset clusters if necessary
        unionRectA = [[self getUnionRectForNode:na]rectValue];
        unionRectB = [[self getUnionRectForNode:nb]rectValue];
        
        // compute distances and deltas ( with correct sign )
        deltaX = unionRectB.origin.x -  unionRectA.origin.x;
        deltaY = unionRectB.origin.y -  unionRectA.origin.y;
        //distance = sqrt(pow(deltaX, 2)+pow(deltaY, 2));
        
        // now sort them to compute the distance needed
        if(unionRectA.origin.x > unionRectB.origin.x){
           // tempRect = unionRectB;
            unionRectA = unionRectB;
            //unionRectB = tempRect;
        }
        
        if (deltaX == 0)
            deltaX=0.1;
        
        c = sqrt(pow(unionRectA.size.width+kNodeOffset, 2)+pow(unionRectA.size.height+kNodeOffset, 2));
        
        m	= deltaY/deltaX;
        alpha = atan_d(m);
        a = sin_d(alpha) * c;
        b = cos_d(alpha) * c;
        x = (a - deltaX) /2;
        y = (b - deltaY) /2;
        
        p1.x = [na rect].origin.x - x;
        p1.y = [na rect].origin.y - y;
        
        //NSLog(@"repositionNodes... setting new origin for node %@ at %@ to %@", [na name], [NSValue valueWithPoint:[na rect].origin], [NSValue valueWithPoint:p1]);
        [na setLocation:p1];
        
        p2.x = [nb rect].origin.x  + x;
        p2.y = [nb rect].origin.y  + y;
        //NSLog(@"repositionNodes... setting new origin for node %@ at %@ to %@", [nb name], [NSValue valueWithPoint:[nb rect].origin], [NSValue valueWithPoint:p2]);
        //NSLog(@"repositionNodes: x: %f, y: %f, a: %f, b: %f, m: %f", x, y, a, b, m);
        //	NSLog(@"repositionNodes: computational FUCKUP: x: %f, y: %f, a: %f, b: %f, m: %f, deltaX: %f", x, y, a, b, m, deltaX);
        
        [nb setLocation:p2];
    }
    
    if([self isNodeOutsideIdentityRim:na])
        [self repositionNodeInsideIdentityRim:na];
    
    if([self isNodeOutsideIdentityRim:nb])
        [self repositionNodeInsideIdentityRim:nb];           
   
    
	if([self isNodeMemberOfASubsetCluster:na])
		[self recreateSubsetNodesForNode:na];//[self dragSubsetNodesOfNode:na byX:x*(-1) y:y*(-1)];
	
	
	if([self isNodeMemberOfASubsetCluster:nb])
		[self recreateSubsetNodesForNode:nb];//[self dragSubsetNodesOfNode:nb byX:x y:y];

	//NSLog(@"done!\n");
}

-(void)repositionNodeInsideIdentityRim:(Node *)n{
    
    for(int i = 0;[self isNodeOutsideIdentityRim:n];i++){
        [self pullNodeTowardCenter:n];
        if(i>3){
            NSLog(@"resetting to perfect location: %@", [n name]);
            [n setLocation:[self perfectLocationForMaterialNodeWithName:[n name]]];//[self pullNodeTowardCenter:na];
            break;
        }
    }
    [self repositionNodeIfNecessary:n];
}

-(void)pullNodeTowardCenter:(Node *)n{
    NSLog(@"pulling towards center...: %@", [n name]);
    NSPoint location = [n location], center = [self center];
    if(location.x > center.x)
        location.x -= kNodeOffset*.5;
    else
        location.x += kNodeOffset*.5;
    
    if(location.y > center.y)
        location.y -= kNodeOffset*.5;
    else
        location.y += kNodeOffset*.5;
    
    [n setLocation:location];
    
}

-(BOOL) isNodeOutsideIdentityRim:(Node *)n{
    Node * strongestIdentityNode = [self identityNodeWithName:[[n material] strongestIdentity]];
    NSPoint identityLocation = [strongestIdentityNode location];
    NSPoint center = [self center], p = [n location];;
    int x, y;
    
    // find quadrant
    if(identityLocation.x >= center.x)
        x = 1;
    else
        x = -1;
    if(identityLocation.y >= center.y)
        y = 1;
    else
        y = -1;
    
    // 
    if(x > 0 && p.x > identityLocation.x - kNodeOffset)
        return YES;
    if(x < 0 && p.x < identityLocation.x - kNodeOffset)
        return YES;
    if(y > 0 && p.y > identityLocation.y - kNodeOffset)
        return YES;
    if(y < 0 && p.y < identityLocation.y - kNodeOffset)
        return YES;
    
    return NO;
}

-(BOOL) areNodesSubsetWiseConnected:(Node *)n and:(Node *)c{
	
	if (![[n className]isEqualToString:@"Node"]) {
		NSLog(@"areNodesSubsetWiseConnected: NOT A NODE! (n)");
		return NO;
	}
	
	if (![[c className]isEqualToString:@"Node"]) {
		NSLog(@"areNodesSubsetWiseConnected: NOT A NODE! (c)");
		return NO;
	}
	
	
	if(!([self isNodeMemberOfASubsetCluster:n] && [self isNodeMemberOfASubsetCluster:c])) // if only one of them is not part of a subsetcluser, they can't be subsetmässig connected!
		return NO;
	
	Material * a, *b, * topA, * topB;

	a = [n material];
	b = [c material];

	topA = [self getTopMaterialOfSubSetClusterWithMaterial:a];
	topB = [self getTopMaterialOfSubSetClusterWithMaterial:b];

	if([topA isEqual:topB])
		return YES;

	return NO;
}

BOOL equalPoints(NSPoint a, NSPoint b){
	
	if(a.x == b.x && a.y == b.y) return YES; return NO;
}



-(NSValue *)getUnionRectForNode:(Node *)n{
	
	if (![[n className]isEqualToString:@"Node"]) {
		NSLog(@"getUnionRectForNode: NOT A NODE!");
		return nil;
	}
	
	if(![self isNodeMemberOfASubsetCluster:n])
		return [NSValue valueWithRect:[n rect]];

	NSString * name;
	NSMutableArray * nodeNames;
	NSEnumerator * e;

	NSRect unionRect;
	Node * nod, * superNod;//
	Material * mat, * superMat;
	
	mat = [n material];
	superMat = [self getTopMaterialOfSubSetClusterWithMaterial:mat];
	//NSLog(@"getUnionRect...: [superMat name]: %@", [superMat name]);
	superNod	= [self materialNodeWithName:[superMat name]];
	//NSLog(@"getUnionRect...: superNod:%@", superNod);
	nodeNames	= [self getSubsetClusterNamesArrayForNode:superNod];
	
	e = [nodeNames objectEnumerator];
	name = [e nextObject];
	nod = [self materialNodeWithName:name];
	
	unionRect = [nod rect];

	while(name = [e nextObject]){
		
		nod = [self materialNodeWithName:name];
		unionRect = NSUnionRect(unionRect, [nod rect]);	
	}

	return [NSValue valueWithRect: unionRect];
}


-(BOOL)isNodeMemberOfASubsetCluster:(Node *)n{
	if (![[n className]isEqualToString:@"Node"]) {
		NSLog(@"isNodeMemberOfASubsetCluster: NOT A NODE!");
		return NO;
	}
	Material * mat = [n material];
	if([[mat subsets]count]>0 || [mat isSubset])
		return YES;
	return NO;
}

-(void)recreateSubsetNodesForNode:(Node *)n{
	
	
	//NSLog(@"recreating subsetnodes for node: %@", [n name]);
	NSMutableArray * subsets = [self getSubsetClusterNamesArrayForNode:n];
	[subsets removeObject:[n name]]; 
	NSEnumerator * e = [subsets objectEnumerator];
	NSString * name;
	//material * mat;
	while(name = [e nextObject]){
		if([(NSSet *)[self valueForKey:@"materialNodes"] containsObject:[self materialNodeWithName:name]])			
			[(NSMutableSet *)[self valueForKey:@"materialNodes"] removeObject:[self materialNodeWithName:name]];
	}
	[self createSubsetNodesForNode:n];
	
}

-(void)renderMaterialNodePaths{
	
	NSEnumerator * n;
	n = [(NSSet *)[self valueForKey:@"materialNodes"] objectEnumerator];
	Node *nod;
	Material *m;
	float offset = 2;
	NSRect innerRect;
	NSBezierPath *path,*innerPath;
	//float lineDash[2] = {1, 1};
	CGFloat lineDash[2] = {1, 1};
	CGFloat lineDash2[2] = {1, 1.5};
	while(nod = [n nextObject]){
		
		path = [NSBezierPath bezierPathWithOvalInRect:[nod rect]];
		m = [nod material];
		if([m isCompound]){
			
			innerRect= NSMakeRect([nod rect].origin.x+offset, [nod rect].origin.y+offset, [nod rect].size.width-offset*2, [nod rect].size.height-offset*2);
			innerPath = [NSBezierPath bezierPathWithOvalInRect:innerRect];
			[path appendBezierPath:innerPath];
			[path setLineDash:lineDash count:2 phase:0];
		}
		
		
		
		if([m isDerivative] && ![m isCompound]){
			[path setLineWidth:2];
			[path setLineDash:lineDash2 count:2 phase:0];
		}
		
		if([m isProjected])// || [[m files]count]==0)
			[nod setColor:[NSColor grayColor]];
		
		
		[nod setPath:path];
	}
	
}

-(void)createPathsForConnections{
	
	//NSLog(@"createPathsForConnectionConnections");
	NSPoint start, end, ctrl1, ctrl2;
	Node * nodeA, * nodeB;
	Connection * c;
	
	[[self valueForKey:@"connections"]removeAllObjects];
	[doc createConnections:self];
	
	if(![self valueForKey:@"connectionPaths"])
	   [self setValue:[[[NSMutableSet alloc]init]autorelease] forKey:@"connectionPaths"];
	else
	   [(NSMutableSet *)[self valueForKey:@"connectionPaths"]removeAllObjects];
	   
	[self setValue:[doc connections] forKey:@"connections"];
	
	NSMutableArray *connectionsBetweenAAndB, * connectionCopy = [NSMutableArray arrayWithArray:[[doc connections]allObjects]], * controlPoints;
	int i, o;
	float width, sizeWidth = [self size].width, offset;// =120;
	double factor, distance;
	Material * matA, *matB;
	NSBezierPath * path;
	//NSValue * c1, *c2;
	for(i=0;i<[connectionCopy count];i++){
		c = [connectionCopy objectAtIndex:i];
		matA = [c materialA];
		matB = [c materialB];
		
		if([matA isVisible] && [matB isVisible]){
			
			connectionsBetweenAAndB = [[self getAllConnectionsBetweenMaterial: matA and:matB]retain];	
			
			//... do some crazy stuff here to get separated paths
			for(o=0;o<[connectionsBetweenAAndB count];o++){
			}
			//... continuing with the line-width-method
			
			width = [connectionsBetweenAAndB count];
			//NSLog(@"found %d connections between %@ and %@ :%@", [connectionsBetweenAAndB count], [matA name], [matB name], connectionsBetweenAAndB);
			//con = [[NSMutableArray alloc]init];
			nodeA = [self materialNodeWithName:[matA name]];
			nodeB = [self materialNodeWithName:[matB name]];
			start = [nodeA center];
			end	= [nodeB center];
			path = [[[NSBezierPath alloc]init]autorelease];
			
			distance = [self distanceBetweenPointA:start andB:end];
			factor = distance*3 / sizeWidth;
			offset = 120 + 500*factor;
			//NSLog(@"distance: %f, factor: %f, offset %f", distance, factor, offset);
			
			controlPoints = [self getControlPointsForLineBetween:start and:end withOffset:offset];
			ctrl1 = [[controlPoints objectAtIndex:0]pointValue];
			ctrl2 = [[controlPoints objectAtIndex:1]pointValue];
			if([self areNodesSubsetWiseConnected:nodeA and:nodeB]){
				ctrl1 = start;//[[controlPoints objectAtIndex:0]pointValue];
				ctrl2 = end;//[[controlPoints objectAtIndex:1]pointValue];
				
				
			}
			[path moveToPoint:start];
			//		[path curveToPoint:end controlPoint1:start controlPoint2:end];
			[path curveToPoint:end controlPoint1:ctrl1 controlPoint2:ctrl2];		
			//[path setLineDash:lineDash count:2 phase:0];
			[path setLineWidth:width];
			[connectionCopy removeObjectsInArray:connectionsBetweenAAndB];
			//	NSLog(@"removed %d objects from array, %d remaining", [connectionsBetweenAAndB count], [connectionCopy count]);
			[(NSMutableSet *)[self valueForKey:@"connectionPaths"] addObject:path];
			i=-1;
			[connectionsBetweenAAndB release];
		}
	}
	//NSLog(@"renderAndCreatePathsForConnectionConnections: DONE");
}


-(NSMutableArray *)getAllConnectionsBetweenMaterial:(Material *) a and:(Material*)b{
	
	NSMutableArray * collection = [[NSMutableArray alloc]init];
	Material * matA, *matB;
	NSEnumerator *e = [(NSSet *)[self valueForKey:@"connections"] objectEnumerator];
	Connection *c;
	
	while(c = [e nextObject]){
		
		matA = [c materialA];
		matB = [c materialB];
		
		if( ([a isEqual:matA] || [a isEqual:matB]) && ([b isEqual:matA] || [b isEqual:matB]))
			[collection addObject:c];
	}

	return [collection autorelease];
	
}

-(NSMutableArray *)getControlPointsForLineBetween:(NSPoint)start and:(NSPoint)end withOffset:(float)offset {
	
	NSPoint c1, c2, ctrl;
	NSMutableArray * points = [[[NSMutableArray alloc]init]autorelease];
	float factor, deltaX, deltaY, centerX = [self center].x, centerY = [self center].y;
	
	ctrl.x = (end.x-start.x)/2+start.x;
	if(ctrl.x <= centerX) factor = -1; else factor = 1;
	ctrl.x +=offset*factor;
	
	ctrl.y = (end.y-start.y)/2+start.y;
	if(ctrl.y <= centerY) factor = -1; else factor = 1;
	ctrl.y +=offset*factor;
	
	deltaX = ctrl.x - start.x;
	c1.x = start.x+ (deltaX/4);
	c2.x = start.x+(deltaX/4)*3;
	deltaY = ctrl.y - start.y;
	c1.y = start.y+deltaY/4;
	c2.y = start.y+(deltaY/4)*3;
	
	[points addObject: [NSValue valueWithPoint:c1]];
	[points addObject: [NSValue valueWithPoint:c2]];
	return points;
}

-(void)createPathsForMaterialIdentityConnections{
	
	if(![self valueForKey:@"materialIdentityConnectionPaths"])
		[self setValue:[[[NSMutableSet alloc]init]autorelease] forKey:@"materialIdentityConnectionPaths"];
	else
		[[self valueForKey:@"materialIdentityConnectionPaths"]removeAllObjects];
	
	NSEnumerator * n, *d;
	n = [(NSMutableSet *) [self valueForKey:@"materialNodes"] objectEnumerator];
	Node * identityNode, *materialNode ;
	Material * mat;
	NSPoint start, end, ctrl1, ctrl2;
	NSBezierPath * path;
	NSDictionary * identity;
	NSMutableArray *controlPoints;
	float offset =100, brightness, match, width;
	CGFloat lineDash[2] = {3, 5};
	
	while(materialNode = [n nextObject]){
		if([materialNode isVisible]){
			//NSLog(@"createPathsForMaterialidentityConnections: node for material %@ appears to be visible. creating dentity connection!", [materialNode name]);
			start = [materialNode center];
			mat = [materialNode material];
			//NSLog(@"rendering connections for material: %@",[materialNode name]);
			d = [(NSArray *)[mat valueForKey:@"identities"] objectEnumerator];
			while(identity = [d nextObject]){
				
				//con = [[NSMutableArray alloc]init];
				identityNode = [self identityNodeWithName:[identity valueForKey:@"name"]];
				end = [identityNode center];
				
				match = [[identity valueForKey:@"match"] floatValue];
				brightness = 0.8 - (match/100)*.6;
				width = (match / 100)*.5 + .5;
				//NSLog(@"match : %f, brigthness: %f", match, brightness);
				path = [[NSBezierPath alloc]init];
				
				controlPoints = [self getControlPointsForLineBetween:start and:end withOffset:offset];
				ctrl1 = [[controlPoints objectAtIndex:0]pointValue];
				ctrl2 = [[controlPoints objectAtIndex:1]pointValue];
				//NSLog(@"\tstart:%@, end:%@", NSStringFromPoint(start), NSStringFromPoint(end));
				[path moveToPoint:start];
				[path curveToPoint:end controlPoint1:ctrl1 controlPoint2:ctrl2];
				[path setMiterLimit:brightness];
				[path setLineDash:lineDash count:2 phase:0];	
				[path setLineWidth:width];			
				
				//	NSLog(@"current lineWidth is: %f", [path lineWidth]);
				[(NSMutableSet *)[self valueForKey:@"materialIdentityConnectionPaths"] addObject:path];
				[path release];
			}
		}
	}
}


-(NSMutableSet *)identityNodes{
	//NSLog(@"GraphCreator: identityNodes: count: %d", [[self valueForKey:@"identityNodes"]count]);
	return (NSMutableSet *)[self valueForKey:@"identityNodes"];
}

-(NSMutableSet *)materialNodes{
	return (NSMutableSet *)[self valueForKey:@"materialNodes"];
}

-(NSMutableSet *)connectionPaths{
	return (NSMutableSet *)[self valueForKey:@"connectionPaths"];
}

-(NSMutableSet *)materialIdentityConnectionPaths{
	return (NSMutableSet *)[self valueForKey:@"materialIdentityConnectionPaths"];
}

-(void)createDateString{
		//NSLog(@"createDate...");
	int mats, cons, idents, x, y, comp, der, tags, files;
	mats = [[doc materials]count];
	cons = [[doc connections]count];
	idents = [[doc identityNames]count];
	x = [graph frame].size.width;
	y = [graph frame].size.height;
	comp = [doc compoundsCount];
	der = [doc derivativesCount];
	tags = [[doc valueForKey:@"allTags"]count];
    files = [[doc files]count];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
	
	NSString * fileName = @"CompoundNetwork";//[doc displayName];

	dateString = [NSString stringWithFormat:@"%@\ngraph created on\n%@\nby M.Marcoll\n%d x %d p\n%d materials\n%d derivatives\n%d cmpnd drvtvs\n%d connections\n%d identities\n%d tags\n%d files", 
				  fileName, formattedDateString, x, y, mats, der, comp,  cons, idents, tags, files];
	//NSLog(@"dateString: %@", dateString);
	dateString = [self spaceString:dateString by:1];
	//	dateString = [NSString stringWithString:[[NSDate date]description]];
	
}

-(NSString *)spaceString:(NSString *)s by:(int)x{
	
	int i, space;
	NSString * result = [[[NSString alloc]init]autorelease];
	for(i=0;i<[s length];i++){
		
		for(space=0;space<x;space++){
			result = [result stringByAppendingFormat:@" "];
		}
		result = [result stringByAppendingFormat:@"%c", [s characterAtIndex:i]];
	}
	return result;
	
}


-(NSString *)dateString{
	[self createDateString];
	return [dateString retain];
}

-(NSString *)descriptionForNodeWithName:(NSString *)n{
	
	Material * m = [doc getMaterialByName:n];
	if(!m) return nil;
	NSString * s = [NSString stringWithFormat:@"%@\n\n%@", [m comment], [m description]];
	
	return s;//[s retain];
	
}

//-(void)print{
//
//	NSSavePanel * savePanel;
//	int result;
//	NSString * path;		
//	savePanel = [NSSavePanel savePanel];
//	[savePanel setRequiredFileType:@"pdf"];
//	result = [savePanel runModalForDirectory:nil file:nil];
//	
//	if(result == NSOKButton) {
//		path = [NSString stringWithString:[savePanel filename]];		
//		NSData * data = [graph dataWithPDFInsideRect:[graph bounds]];
//		if(![data writeToFile:path atomically:YES])
//			[doc createErrorFromString:@"Could Not Print!"];	
//	}
//}

-(void)print{
    
	NSSavePanel * savePanel;
	int result;
	NSString * path;		
	savePanel = [NSSavePanel savePanel];
	[savePanel setRequiredFileType:@"pdf"];
	result = [savePanel runModalForDirectory:nil file:nil];
	
	if(result == NSOKButton) {
		path = [NSString stringWithString:[savePanel filename]];	
		NSData * data = [graph dataWithPDFInsideRect:[graph bounds]];
		if(![data writeToFile:path atomically:YES])
			[doc createErrorFromString:@"Could Not Print PDF!"];
        
        path = [path stringByAppendingFormat:@".tiff"];
        NSImage * img = [[[NSImage alloc]initWithData:data]autorelease];
        NSData * tiff = [img TIFFRepresentation];

        if(![tiff writeToFile:path atomically:YES])
			[doc createErrorFromString:@"Could Not Print TIFF!"];
	}
}


-(BOOL)isPoint:(NSPoint)p inRect:(NSRect)r{
	

	//if (p.x >= r.origin.x && p.x <= r.origin.x+r.size.width && p.y >= r.origin.y && p.y <= r.origin.y+r.size.height)
	if(p.x<r.size.width && p.y < r.size.height && p.x>=0 && p.y >=0)
		return YES;
	//NSLog(@"isPointInRect: point: %@, rect: %@", [NSValue valueWithPoint:p], [NSValue valueWithRect:r]);
	return NO;

	
}
-(NSRect)bounds{

	//NSLog(@"graph frame: %@", [NSValue valueWithRect:[graph frame]]);
	return [graph frame];
}
@end
