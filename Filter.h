//
//  Filter.h
//  CompoundNetwork
//
//  Created by max on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyDocument.h"

@interface Filter : NSObject {

	IBOutlet MyDocument * doc;
	IBOutlet NSPanel * window;
	IBOutlet NSArrayController * allTagsArrayController;
	IBOutlet NSArrayController * allIdentitiesArrayController;
	IBOutlet NSArrayController * allNetworksArrayController;
	IBOutlet NSArrayController * filterTagsArrayController;
	IBOutlet NSArrayController * filterIdentitiesArrayController;
	IBOutlet NSArrayController * filterNetworksArrayController;	
	NSMutableDictionary * dict;
}


-(void)setValue:(id)value forKey:(NSString *)key;
-(id)valueForKey:(NSString *)key;
-(IBAction)clear:(id)sender;
-(IBAction)filter:(id)sender;
-(void)deleteFiltration;
-(IBAction)cancel:(id)sender;
-(IBAction)addSelectedIdentity:(id)sender;
-(IBAction)removeIdentity:(id)sender;
-(IBAction)addSelectedTag:(id)sender;	
-(IBAction)removeTag:(id)sender;
-(IBAction)addSelectedNetwork:(id)sender;	
-(IBAction)removeNetwork:(id)sender;
-(NSPanel*)window;
-(void)wakeUp;
-(BOOL)hasTag:(NSString *)tag;
-(BOOL)hasIdentity:(NSString *)iden;
-(BOOL)hasNetwork:(NSString *)net;
@end
