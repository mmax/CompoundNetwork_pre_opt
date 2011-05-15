//
//  Connector.h
//  CompoundNetwork
//
//  Created by max on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@class Material, MyDocument;

@interface Connector : NSObject {

	NSMutableSet * connections;
	MyDocument * doc;
	int count;
}

-(void)createConnections;
-(void)connectMaterial:(Material *)m withAllMaterialsInSet:(NSSet *)g viaTag:(NSString *)tag;
-(void)connectAllMaterialsInSet:(NSMutableSet *)set viaTag:(NSString *)tag ;
-(NSMutableSet *)materialsWithTag:(NSString *)tag;
-(NSMutableSet *)connections;
-(void)setDoc:(MyDocument *)d;
-(void)disconnectEverything;
@end
