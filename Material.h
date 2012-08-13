//
//  Material.h
//  CompoundNetwork
//
//  Created by max on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "Connection.h"
@class Connection, Node;

@interface Material : NSObject {

	NSMutableDictionary * dict;

}

-(Material *)initWithPath:(NSString *)path;
-(void)setValue:(id)value forKey:(NSString *)key;
-(id)valueForKey:(NSString *)key;
-(NSString *)name;
-(NSString *)humanReadableFileType:(NSString *)path;
-(void)getFiles;
-(NSArray *)files;
-(void)readInfoFile;
-(void)createInfoFile;
-(BOOL)writeToFile;
-(void)writeToFileTheValueOfKey:(NSString *)key;
-(void)readFromFile;
-(void)readFromFileTheValueOfKey:(NSString *)key;
-(void)chooseImage;
-(void)addTag:(NSString *)tag;
-(BOOL)hasTag:(NSString *)tag;
-(void)removeTag:(NSDictionary *)tag;
-(void)addIdentity:(NSString *)i;
-(BOOL)hasIdentity:(NSString *)i;
-(void)removeIdentity:(NSDictionary *)i;
-(void)addNetwork:(NSString *)i;
-(BOOL)hasNetwork:(NSString *)i;
-(void)removeNetwork:(NSDictionary *)i;
-(void)removeNetworkNamed:(NSString *)i;
-(void)addConnection:(Connection *)c;
-(void)removeConnection:(Connection *)c;
-(NSString *)strongestIdentity;
//-(BOOL)hasConnection:(Connection *)c;

-(void)setNode:(Node *)n;
-(Node*)node;
-(BOOL)isSubset;	
-(Material *)superMaterial;
-(BOOL)isVisible;
-(void)setIsVisible:(BOOL)b;
-(void)removeAllConnections;
-(NSMutableSet *)subsets;
-(NSArray *)subsetNames;
-(BOOL)isCompound;
-(BOOL)isDerivative;
-(BOOL)isProjected;
-(NSString *)comment;
-(NSString *)pathForFileWithName:(NSString *)name;
@end
