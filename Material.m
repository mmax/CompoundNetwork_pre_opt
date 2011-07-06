//
//  Material.m
//  CompoundNetwork
//
//  Created by max on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Material.h"
#import "MyDocument.h"
#import "Connection.h"

@implementation Material

-(Material *)init{

	if((self = [super init])){
		dict = [[NSMutableDictionary alloc]init];

	}
	
	return self;
}


-(Material *)initWithPath:(NSString *)path{

	if((self = [super init])){
		dict = [[NSMutableDictionary alloc]init];
		NSString * name = [path lastPathComponent];
		[self setValue:name forKey:@"name"];
		[self setValue:path forKey:@"path"];
		//[self setValue:[[NSImage alloc]initWithContentsOfFile:@"/Users/max/Desktop/fbp5/eb2.jpg"]forKey:@"image"];
		[self setValue:path forKey:@"comment"];
		[self setValue:[NSNumber numberWithBool:YES] forKey:@"visible"];
		[self setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"files"];
		[self setValue:[[[NSMutableSet alloc]init]autorelease] forKey:@"connections"];
		[self setValue:[NSArray arrayWithObjects:@"comment", @"tags", @"identities", @"networks", @"supersetName", @"subset", @"derivative", @"compound", @"projected", @"date", @"imagePath", nil] forKey:@"copyKeys"];
		[self readInfoFile];
		[self getFiles];
	}
	return self;
}

-(void) dealloc{

	[dict release];
	[super dealloc];
}

-(void)setValue:(id)value forKey:(NSString *)key{

	[dict setValue:value forKey:key];
}

-(id)valueForKey:(NSString *)key{

	return [dict valueForKey:key];
}


-(NSString *)name{

	return (NSString *)[self valueForKey:@"name"];
}
- (NSString *)humanReadableFileType:(NSString *)path {
	
	NSString *kind = nil;
	NSURL *url = [NSURL fileURLWithPath:path];//[path stringByExpandingTildeInPath]];
	LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);
	return kind ? [kind retain] : @""; // If kind happens to be an empty string, don't autorelease it
}

-(void)getFiles{
	
    //NSLog(@"getFiles!");
	NSString *path = (NSString *)[self valueForKey:@"path"];
	NSError *error = nil;
	NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
	if (array == nil) {
		NSLog(@"could not read material contents: %@", path);
	}
	
	for(NSString * filename in array){
		
		NSMutableDictionary * file = [[[NSMutableDictionary alloc ]init]autorelease];
		[file setValue:filename forKey:@"name"];
		[file setValue:[self humanReadableFileType:[NSString stringWithFormat:@"%@/%@", path, filename]]forKey:@"type"];
        [file setValue:[NSString stringWithFormat:@"%@/%@", path, filename] forKey:@"path"];
		if([filename characterAtIndex:0]!='.') // skip invisible files....
			[(NSMutableArray*)[self valueForKey:@"files"]addObject:file];
	}

    NSLog(@"%@: %lu files", [self valueForKey:@"name"], [array count]);
    if ([array count]<2)
        [self addNetwork:@"UNTOUCHED"];
    else{

        [self removeNetworkNamed:@"UNTOUCHED"];
    }
}

-(NSArray *)files{

    return [self valueForKey:@"files"];
}

-(NSString *)pathForFileWithName:(NSString *)name{

    for(NSDictionary * d in [self valueForKey:@"files"]){
    
        if([[d valueForKey:@"name"]isEqualToString:name])
            return [d valueForKey:@"path"];
    }
    return nil;
}

-(void)readInfoFile{

	NSString  * path = [NSString stringWithFormat:@"%@/.CompoundNetwork.plist", (NSString *)[self valueForKey:@"path"]];
	NSDictionary * file = [NSDictionary dictionaryWithContentsOfFile:path];
	if(!file){
		[self createInfoFile];
		return;
	}
	[self setValue:file forKey:@"file"];
	[self setValue:path forKey:@"filePath"];

	[self readFromFile];
	[self setValue:[[NSImage alloc]initWithContentsOfFile:[file valueForKey:@"imagePath"]]forKey:@"image"];
}

-(void)createInfoFile{

	NSLog(@"creating info file for material: %@", [self valueForKey:@"name"]);
	NSMutableDictionary * file = [[NSMutableDictionary alloc]init];
	[file setValue:@"this material's info file has just been created, it does not yet contain any useful information." forKey:@"comment"];
	if(![file writeToFile:[NSString stringWithFormat:@"%@/.CompoundNetwork.plist", (NSString *)[self valueForKey:@"path"]] atomically:YES])
		return;
	[self readInfoFile];
}

-(BOOL)writeToFile{

	//NSLog(@"writing to file: %@", [self valueForKey:@"name"]);
	
	for(NSString * key in (NSArray *)[self valueForKey:@"copyKeys"]){
		//NSLog(@"copying value for key: %@", key);
		[self writeToFileTheValueOfKey:key];
	}
	return [(NSDictionary *)[self valueForKey:@"file"]writeToFile:(NSString *)[self valueForKey:@"filePath"] atomically:YES];

	
}

-(void)readFromFile{
	for(NSString * key in (NSArray *)[self valueForKey:@"copyKeys"]){
		//NSLog(@"copying value for key: %@", key);
		[self readFromFileTheValueOfKey:key];
	}
}

-(void)writeToFileTheValueOfKey:(NSString *)key{
	
	[[self valueForKey:@"file"]setValue:[self valueForKey:key] forKey:key];
}

-(void)readFromFileTheValueOfKey:(NSString *)key{
	
	if([key isEqualToString:@"tags"]){
	
		NSMutableArray * tags = [[NSMutableArray alloc]initWithArray:[[self valueForKey:@"file"]valueForKey:key]];
		[self setValue:tags forKey:@"tags"];
		[tags autorelease];
	}
	else if ([key isEqualToString:@"identities"]){
		NSMutableArray * identities = [[NSMutableArray alloc]initWithArray:[[self valueForKey:@"file"]valueForKey:key]];
		[self setValue:identities forKey:@"identities"];
		[identities autorelease];
	}
	else if ([key isEqualToString:@"networks"]){
		NSMutableArray * networks = [[NSMutableArray alloc]initWithArray:[[self valueForKey:@"file"]valueForKey:key]];
		[self setValue:networks forKey:@"networks"];
		[networks autorelease];
	}
	else
		[self setValue:[[self valueForKey:@"file"]valueForKey:key]forKey:key];
}

-(void)chooseImage{

	NSOpenPanel* op = [NSOpenPanel openPanel];
	
	[op setTitle:@"choose image file"];
	
	int status = [op runModal];

	if(status==NSFileHandlingPanelOKButton){
		[self setValue:[[op URL]path] forKey:@"imagePath"];
		[self willChangeValueForKey:@"image"];
		[self setValue:[[[NSImage alloc]initWithContentsOfFile:(NSString *)[self valueForKey:@"imagePath"]]autorelease]forKey:@"image"];
		[self didChangeValueForKey:@"image"];
	}
}

-(void)addTag:(NSString *)tag{

	if([self hasTag:tag])
		return;

	[self willChangeValueForKey:@"tags"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:tag forKey:@"name"];
	[(NSMutableArray *)[self valueForKey:@"tags"]addObject:d];
	NSMutableArray * tags = (NSMutableArray *)[self valueForKey:@"tags"];
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[tags sortUsingDescriptors:descriptors];
	
	[(MyDocument *)[self valueForKey:@"document"]registerNewTag:tag];
	[self didChangeValueForKey:@"tags"];

}

-(BOOL)hasTag:(NSString *)tag{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"tags"]){
		if ([[d valueForKey:@"name"] isEqualToString:tag])
			return YES;
	}
	return NO;
}
-(void)removeTag:(NSDictionary *)tag{
	[self willChangeValueForKey:@"tags"];
	[(NSMutableArray*)[self valueForKey:@"tags"] removeObject:tag];
	[self didChangeValueForKey:@"tags"];
}

-(void)addIdentity:(NSString *)i{
	if([self hasIdentity:i])
		return;
	
	[self willChangeValueForKey:@"identities"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:i forKey:@"name"];
	[d setValue:[NSNumber numberWithInt:100] forKey:@"match"];
	[(NSMutableArray *)[self valueForKey:@"identities"]addObject:d];
	NSMutableArray * identities = (NSMutableArray *)[self valueForKey:@"identities"];
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"match" ascending:NO];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[identities sortUsingDescriptors:descriptors];
	
	[(MyDocument *)[self valueForKey:@"document"]registerNewIdentity:i];
	[self didChangeValueForKey:@"identities"];
}

-(BOOL)hasIdentity:(NSString *)i{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"identities"]){
		if ([[d valueForKey:@"name"] isEqualToString:i])
			return YES;
	}
	return NO;
}

-(void)removeIdentity:(NSDictionary *)i{
	[self willChangeValueForKey:@"identities"];
	[(NSMutableArray*)[self valueForKey:@"identities"] removeObject:i];
	[self didChangeValueForKey:@"identities"];
}

-(void)addNetwork:(NSString *)i{
	if([self hasNetwork:i])
		return;
	//NSLog(@"addNetwork:%@", i);
	[self willChangeValueForKey:@"networks"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:i forKey:@"name"];
	[(NSMutableArray *)[self valueForKey:@"networks"]addObject:d];
	NSMutableArray * networks = (NSMutableArray *)[self valueForKey:@"networks"];
	NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[networks sortUsingDescriptors:descriptors];
	
	[(MyDocument *)[self valueForKey:@"document"]registerNewNetwork:i];
	[self didChangeValueForKey:@"networks"];
}

-(BOOL)hasNetwork:(NSString *)i{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"networks"]){
		if ([[d valueForKey:@"name"] isEqualToString:i])
			return YES;
	}
	return NO;
}

-(void)removeNetwork:(NSDictionary *)i{
	[self willChangeValueForKey:@"networks"];
	[(NSMutableArray*)[self valueForKey:@"networks"] removeObject:i];
	[self didChangeValueForKey:@"networks"];
}

-(void)removeNetworkNamed:(NSString *)i{
    NSLog(@"%@: removeNetworkNamed:%@", [self valueForKey:@"name"], i);
    if(![self hasNetwork:i])
        return;

    NSDictionary * d;
    for(d in [self valueForKey:@"networks"]){
    
        if([[d valueForKey:@"name"]isEqualToString:i])
            break;
    }
    
    [self removeNetwork:d];
}

-(void)addConnection:(Connection *) c{
	/* if([self hasConnection:c])
			return; */
	
	[(NSMutableSet *)[self valueForKey:@"connections"] addObject:c];
}

-(void)removeConnection:(Connection *)c{
	[(NSMutableSet *)[self valueForKey:@"connections"] removeObject:c];
}

-(BOOL)hasConnection:(Connection *)c{

	
	return [[self valueForKey:@"connections"] containsObject:c];
}

-(void)removeAllConnections{
	
	NSEnumerator * e = [(NSMutableSet *)[self valueForKey:@"connections"] objectEnumerator];
	Connection * con;

	
	while(con = [e nextObject]){
		//[con retain]; // very dirty workaround to prevent Connection from deleting itsself while material's connection set is being enumerated
		
		[con disconnect];

	}
	
	
}

-(void)setNode:(Node *)n{

	[self setValue:n forKey:@"node"];
}

-(Node*)node{

	return (Node*)[self valueForKey:@"node"];
}

-(BOOL)isSubset{

	return [(NSNumber *)[self valueForKey:@"subset"]boolValue];
}

-(Material *)superMaterial{

	if(![self isSubset])return self;
	return [(MyDocument *)[self valueForKey:@"document"] getMaterialByName:(NSString *)[self valueForKey:@"supersetName"]];

}

-(void)setIsVisible:(BOOL)b{

	[self setValue:[NSNumber numberWithBool:b] forKey:@"visible"];
	for(Connection * c in [self valueForKey:@"connections"]){
		[c setIsVisible:b];
		[[self valueForKey:@"node"]setIsVisible:b];
	}
}

-(BOOL)isVisible{
	return [(NSNumber *)[self valueForKey:@"visible"]boolValue];
}

-(BOOL)isCompound{
	return [(NSNumber *)[self valueForKey:@"compound"]boolValue];
}

-(BOOL)isDerivative{
	return [(NSNumber *)[self valueForKey:@"derivative"]boolValue];
}

-(BOOL)isProjected{
	return [(NSNumber *)[self valueForKey:@"projected"]boolValue];
}
-(NSMutableSet *)subsets{

	NSMutableSet * s = [(MyDocument *)[self valueForKey:@"document"] subsetsOfMaterial:self];
	[self setValue:s forKey:@"subsets"];
	return s;
}

-(NSArray *)subsetNames{

	NSSet * s = [self subsets];
	NSMutableArray * n = [[[NSMutableArray alloc]init]autorelease];
	for(Material * m in s)
		[n addObject:[m valueForKey:@"name"]];
	
	return n;
}

-(NSString *)comment{
	return [self valueForKey:@"comment"];
}
@end
