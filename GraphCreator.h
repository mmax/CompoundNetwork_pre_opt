//
//  GraphCreator.h
//  CompoundNetwork
//
//  Created by max on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyDocument, Graph, Node, Material;

@interface GraphCreator : NSObject {

	IBOutlet MyDocument* doc;
	IBOutlet Graph * graph;
	IBOutlet NSPanel * window;
	int repositionDepth;
	NSMutableDictionary * dict;
	NSString * dateString;
}

-(void)render;
-(BOOL)check;
-(void)retry;
-(void)setDoc:(MyDocument *)d;
-(void)setValue:(id)value forKey:(NSString *)key;
-(id)valueForKey:(NSString *)key;
-(id)valueForKeyPath:(NSString *)keyPath;

-(void)renderIdentityNodes;
-(NSSize)size;
-(NSPoint)center;
-(BOOL)doesNodeRect: (NSRect) r1 collideWithNodeRect:(NSRect) r2;
-(void)fixIdentityDistances;
-(double)avgIdentityDistance;
-(NSArray *)sortedIdentities;
-(void)resizeTo:(NSSize)s;
-(double) distanceBetweenNode:(Node *)a andNode:(Node *)b;
-(double)distanceBetweenPointA:(NSPoint)a andB:(NSPoint)b;
-(Node *)identityNodeWithName:(NSString *)n;
-(NSArray *)pointArrayForEllipse;
-(NSArray *)intersectionPointsOnEllipse:(NSArray *)ellipsePoints forNode:(Node *)n withAverageDistance:(double)r;
-(NSArray *)removeDuplicatePointsFromArray:(NSArray *)points withTolerance:(double)d;
-(NSArray *)pointArrayForCircleAroundNode:(Node*)n radius:(double)r;
-(BOOL)isPoint:(NSPoint)p inArray:(NSArray *)points withTolerance:(double)d;

-(void)renderMaterialNodes;
-(Material *)getTopMaterialOfSubSetClusterWithMaterial:(Material *)m;
-(NSPoint)perfectLocationForMaterialNodeWithName:(NSString *)s;
-(NSPoint) startPointForIdentityNode:(Node *)n;
-(void) createSubsetNodesForNode:(Node *)nod;
-(float)getStartWinkelForSubsetsOfNode:(Node *)n;
-(Node *)materialNodeWithName:(NSString *)s;
-(NSMutableArray *)getSubsetClusterNamesArrayForNode:(Node *)n;
-(BOOL)repositionNodeIfNecessary:(Node*)c;
-(Node *)collidingNodeForNode:(Node*)c;
-(void) repositionNodes: (Node *) nodeA and: (Node*) nodeB;
-(BOOL) areNodesSubsetWiseConnected:(Node *)n and:(Node *)c;
BOOL equalPoints(NSPoint a, NSPoint b);
-(NSValue *)getUnionRectForNode:(Node *)n;
-(BOOL)isNodeMemberOfASubsetCluster:(Node *)n;
-(void)recreateSubsetNodesForNode:(Node *)n;
-(void)renderMaterialNodePaths;
-(void)createPathsForConnections;
-(NSMutableArray *)getControlPointsForLineBetween:(NSPoint)start and:(NSPoint)end withOffset:(float)offset;
-(NSMutableArray *)getAllConnectionsBetweenMaterial:(Material *) a and:(Material*)b;
-(void)createPathsForMaterialIdentityConnections;
-(NSMutableSet *)identityNodes;
-(NSMutableSet *)materialNodes;
-(NSMutableSet *)connectionPaths;
-(NSMutableSet *)materialIdentityConnectionPaths;

-(void)createDateString;
-(NSString *)dateString;
-(NSString *)descriptionForNodeWithName:(NSString *)n;
-(void)renderMaterialNodePaths;
-(NSString *)spaceString:(NSString *)s by:(int)x;
-(void)print;
-(BOOL)isPoint:(NSPoint)p inRect:(NSRect)r;
-(NSRect)bounds;
-(BOOL)alreadyHasNodeWithName:(NSString *)name inSet:(NSSet *)materialNodes;
@end
