//
//  MyDocument.m
//  CompoundNetwork
//
//  Created by max on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"

#import "Material.h"
#import "Connector.h"
#import "GraphCreator.h"
#import "Filter.h"
#import "QL.h"



@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
		dict = [[NSMutableDictionary alloc]init];
		NSMutableArray * materials = [[[NSMutableArray alloc]init]autorelease];
		[dict setValue:materials forKey:@"materials"];
		NSMutableArray * allTags = [[[NSMutableArray alloc]init]autorelease];
		[self setValue:allTags forKey:@"allTags"];
		NSMutableArray * allIdentities = [[[NSMutableArray alloc]init]autorelease];
		[self setValue:allIdentities forKey:@"allIdentities"];
		NSMutableArray * allNetworks = [[[NSMutableArray alloc]init]autorelease];
		[self setValue:allNetworks forKey:@"allNetworks"];
		NSMutableArray * connections = [[[NSMutableArray alloc]init]autorelease];
		[self setValue:connections forKey:@"connections"];
		
		connector = [[Connector alloc]init];
		[connector setDoc:self];
		

        preview = NO;
		
		/* graphCreator = [[GraphCreator alloc]init];
				[graphCreator setDoc:self]; */
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

-(void)dealloc{

	[dict release];
	[connector release];
	[super dealloc];
}

- (NSString *)windowNibName{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
 	NSString * error;
	/* NSMutableDictionary * session = [[NSMutableDictionary alloc]init];
		NSMutableArray * objects = [[NSMutableArray alloc]init];
		
		[session setValue:views forKey:@"views"];
		[session setValue:objects forKey:@"objects"]; */
	/* NSLog(@"writing file:"); 
	 NSLog(@"session: %@", session);
	 */	
	NSData * data = [NSPropertyListSerialization dataFromPropertyList:dict
															   format:NSPropertyListXMLFormat_v1_0
													 errorDescription:&error];	 	 
	//[session release];
	
	if(!data) {
		NSLog(@"%@", error);
		[self createErrorFromString:error];
		return nil;
	}
	return data;
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
	NSString *error;
	NSPropertyListFormat format;

	dict = [NSPropertyListSerialization propertyListFromData:data
																	mutabilityOption:NSPropertyListImmutable
																			  format:&format
																	errorDescription:&error];
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

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

-(IBAction)openPath:(id)sender{

	
	NSOpenPanel* op = [NSOpenPanel openPanel];
	[op setCanChooseDirectories:YES];
	[op setTitle:@"open network directory"];

	
	int status = [op runModal];
	/* NSError * error;
		NSString * path; */
	if(status==NSFileHandlingPanelOKButton){
		[self willChangeValueForKey:@"NetworkPath"];
		[self setValue:[[op URL]path] forKey:@"NetworkPath"];
		[self didChangeValueForKey:@"NetworkPath"];
		
		[(NSMutableArray *)[self valueForKey:@"materials"]removeAllObjects];
		[(NSMutableArray *)[self valueForKey:@"allTags"]removeAllObjects];		
		[(NSMutableArray *)[self valueForKey:@"allIdentities"]removeAllObjects];
		[(NSMutableArray *)[self valueForKey:@"allNetworks"]removeAllObjects];		
		[self loadMaterials];
	}
}

-(void)loadMaterials{

	//NSMutableArray * materials = [[[NSMutableArray alloc]init]autorelease];

	//NSLog(@"loading materials");
	NSString *path = (NSString *)[self valueForKey:@"NetworkPath"];
	NSError *error = nil;
	NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
	if (array == nil) {
		NSLog(@"could not read NetworkDirectory contents: %@", path);
		NSLog(@"%@", [error description]);
	}

	[self setProgressTask:@"Loading materials"];
	[self displayProgress:YES];
	NSString * p;
    float prog, c = [array count];
	for(int i=0;i<[array count];i++){//NSString * path in array){
        p = [array objectAtIndex:i];
        prog = i/c * 100.0;
        [self setProgress:prog];
		[self setProgressTask:[NSString stringWithFormat:@"Loading Material: %@", [p lastPathComponent]]];
		[self createMaterialFromPath:p];
	}
//	[self setValue:[NSMutableArray arrayWithArray:array] forKey:@"MaterialPaths"];
    NSSortDescriptor * sd = [[[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]autorelease];
    NSArray * sds = [NSArray arrayWithObject:sd];
    [[self valueForKey: @"materials"] sortUsingDescriptors:sds];
	[materialArrayController bind:@"contentArray" toObject:self withKeyPath:@"materials" options:nil];
	[self displayProgress:NO];
	//NSLog(@"%@", [self valueForKey:@"MaterialPaths"]);
}

-(void)createMaterialFromPath:(NSString *)path{

	//NSLog(@"creating material from path: %@", path);

	if([path characterAtIndex:0] == '.')	// skip invisible files....
		return;
	Material * m = [[[Material alloc]initWithPath:[NSString stringWithFormat:@"%@/%@", [self valueForKey:@"NetworkPath"], path]]autorelease];
	[self willChangeValueForKey:@"allTags"];
	for(NSDictionary * d in (NSArray *)[m valueForKey:@"tags"])
		[self registerNewTag:[d valueForKey:@"name"]];
	[self didChangeValueForKey:@"allTags"];

	[self willChangeValueForKey:@"allIdentities"];
	for(NSDictionary * d in (NSArray *)[m valueForKey:@"identities"])
		[self registerNewIdentity:[d valueForKey:@"name"]];
	[self didChangeValueForKey:@"allIdentities"];
	
	[self willChangeValueForKey:@"allNetworks"];
	for(NSDictionary * d in (NSArray *)[m valueForKey:@"networks"])
		[self registerNewNetwork:[d valueForKey:@"name"]];
	[self didChangeValueForKey:@"allNetworks"];
	
	[m setValue:self forKey:@"document"];
	
	[(NSMutableArray *)[self valueForKey:@"materials"]addObject:m];

}

-(IBAction)materialArraySelectionChanged:(id)sender{
	
	//NSLog(@"name of selected object: %@", [[[materialArrayController selectedObjects]lastObject]valueForKey:@"name"]);
	//NSLog(@"%@", [[[materialArrayController selectedObjects]lastObject]valueForKey:@"files"]);
		
}

-(Material *)getMaterialByName:(NSString *)name{

	for(Material * m in (NSArray *)[self valueForKey:@"materials"]){
	
		if ([(NSString *)[m valueForKey:@"name"]isEqualToString:name]) {
			return m;
		}
	}
	return nil;
}

-(IBAction)saveMaterial:(id)sender{

	for(Material * m in (NSArray *)[self valueForKey:@"materials"])
		[m writeToFile];
//	[[[materialArrayController selectedObjects]lastObject]writeToFile];
}

-(IBAction)setImage:(id)sender{

	[[[materialArrayController selectedObjects]lastObject]chooseImage];
}

-(IBAction)addTag:(id)sender{
	[[[materialArrayController selectedObjects]lastObject]addTag:[sender stringValue]];
	
}

-(IBAction)removeTag:(id)sender{

	Material * active = [[materialArrayController selectedObjects]lastObject];
	
	[active removeTag:[[tagArrayController selectedObjects]lastObject]];
	
}

-(void)registerNewTag:(NSString *)s{

	if ([self hasTag:s])
		return;
	
	//NSLog(@"doc: addingTag: %@", s);
	[self willChangeValueForKey:@"allTags"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:s forKey:@"name"];
	
	[(NSMutableArray *)[self valueForKey:@"allTags"]addObject:d];
	
	NSMutableArray * tags = (NSMutableArray *)[self valueForKey:@"allTags"];
	NSSortDescriptor * sd = [[[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES]autorelease];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[tags sortUsingDescriptors:descriptors];
	[self didChangeValueForKey:@"allTags"];
	
}


-(BOOL)hasTag:(NSString *)tag{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"allTags"]){
		if ([[d valueForKey:@"name"] isEqualToString:tag])
			return YES;
	}
	return NO;
}

-(IBAction)addSelectedTag:(id)sender{

	NSString * tag  = [[[allTagsArrayController selectedObjects]lastObject]valueForKey:@"name"];
	[[[materialArrayController selectedObjects]lastObject]addTag:tag];
}

-(IBAction)addIdentity:(id)sender{
	[[[materialArrayController selectedObjects]lastObject]addIdentity:[sender stringValue]];
	
}

-(IBAction)removeIdentity:(id)sender{
	
	Material * active = [[materialArrayController selectedObjects]lastObject];
	
	[active removeIdentity:[[identityArrayController selectedObjects]lastObject]];
	
}

-(void)registerNewIdentity:(NSString *)s{
	
	if ([self hasIdentity:s])
		return;
	
//	NSLog(@"doc: addingIdentity: %@", s);
	[self willChangeValueForKey:@"allIdentities"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:s forKey:@"name"];
	
	[(NSMutableArray *)[self valueForKey:@"allIdentities"]addObject:d];
	
	NSMutableArray * tags = (NSMutableArray *)[self valueForKey:@"allIdentities"];
	NSSortDescriptor * sd = [[[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES]autorelease];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[tags sortUsingDescriptors:descriptors];
	[self didChangeValueForKey:@"allIdentities"];
	
}


-(BOOL)hasIdentity:(NSString *)iden{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"allIdentities"]){
		if ([[d valueForKey:@"name"] isEqualToString:iden])
			return YES;
	}
	return NO;
}

-(IBAction)addSelectedIdentity:(id)sender{
	
	NSString * iden  = [[[allIdentitiesArrayController selectedObjects]lastObject]valueForKey:@"name"];
	[[[materialArrayController selectedObjects]lastObject]addIdentity:iden];
}

-(IBAction)addNetwork:(id)sender{
	[[[materialArrayController selectedObjects]lastObject]addNetwork:[sender stringValue]];
	
}

-(IBAction)removeNetwork:(id)sender{
	
	Material * active = [[materialArrayController selectedObjects]lastObject];
	
	[active removeNetwork:[[networkArrayController selectedObjects]lastObject]];
	
}

-(void)registerNewNetwork:(NSString *)s{
	
	if ([self hasNetwork:s])
		return;
	
	
	[self willChangeValueForKey:@"allNetworks"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:s forKey:@"name"];
	
	[(NSMutableArray *)[self valueForKey:@"allNetworks"]addObject:d];
	
	NSMutableArray * networks = (NSMutableArray *)[self valueForKey:@"allNetworks"];
	NSSortDescriptor * sd = [[[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES]autorelease];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[networks sortUsingDescriptors:descriptors];
	[self didChangeValueForKey:@"allNetworks"];
	
}


-(BOOL)hasNetwork:(NSString *)net{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"allNetworks"]){
		if ([[d valueForKey:@"name"] isEqualToString:net])
			return YES;
	}
	return NO;
}

-(IBAction)addSelectedNetwork:(id)sender{
	
	NSString * net  = [[[allNetworksArrayController selectedObjects]lastObject]valueForKey:@"name"];
	[[[materialArrayController selectedObjects]lastObject]addNetwork:net];
}

-(NSMutableArray *)materials{return (NSMutableArray *)[self valueForKey:@"materials"];}

-(NSSet *)files{

    NSMutableSet * files = [[[NSMutableSet alloc]init]autorelease];
    for(Material * m in [self materials]){
        [files addObjectsFromArray:[m files]];
    }
    return files;
}

-(IBAction)renderGraphics:(id)sender{

	[graphCreator resizeTo:NSMakeSize(4000, 2828)];//8000,5656)];

	[graphCreator render];
}

-(IBAction)createConnections:(id)sender{

	[connector createConnections];
}

-(NSMutableArray *)identityNames{

	NSMutableArray * names = [[[NSMutableArray alloc]init]autorelease];
	//NSLog(@"allIdentities: %@", [self valueForKey:@"allIdentities"]);
	for(NSDictionary * d in (NSDictionary *)[self valueForKey:@"allIdentities"])
		[names addObject:(NSString *)[d valueForKey:@"name"]];
	

	return names;
}

-(NSMutableArray *)materialNames{
	
	NSMutableArray * names = [[[NSMutableArray alloc]init]autorelease];
	for(Material * m in (NSArray *)[self valueForKey:@"materials"])
		[names addObject:(NSString *)[m valueForKey:@"name"]];
	return names;
}


-(NSMutableSet *)subsetsOfMaterial:(Material *)m{

	NSMutableSet * s = [[[NSMutableSet alloc]init]autorelease];
	for(Material * c in (NSArray *)[self valueForKey:@"materials"]){
	
		if([(NSString *)[c valueForKey:@"supersetName"]isEqualToString:(NSString *)[m valueForKey:@"name"]] && ![m isEqual:c])
			[s addObject:c];
	}
	return s;
}

-(void) displayProgress:(BOOL) display {
	
	if(display) {
		
		[[progressBar window] makeKeyAndOrderFront:nil];
		[[progressBar window]display];
		
		if([progressBar isIndeterminate]) {
			[progressBar startAnimation:nil];
			[progressBar displayIfNeeded];
		}
		
	}	
	else {
		
		if([progressBar isIndeterminate]) {
			[progressBar stopAnimation:nil];
			[progressBar setIndeterminate:NO];
			[progressBar setUsesThreadedAnimation:NO];
		}
		
		[[progressBar window] orderOut:nil];
		[self setProgress:0];
		
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setProgress:(float)progress {
	
	[progressBar setDoubleValue:progress];
	
	[progressBar displayIfNeeded];
	//if([progressBar isIndeterminate])[progressBar animate:nil];
} 

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setProgressTask:(NSString *) task {
	
	if([progressBar isIndeterminate]) {
		[progressBar stopAnimation:nil];
		[progressBar setIndeterminate:NO];
		[progressBar setUsesThreadedAnimation:NO];
	}
	[progressText setStringValue:task];
	[[progressBar window]display];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) setIndeterminateProgressTask:(NSString *) task {
	
	[progressBar setIndeterminate:YES];
	[progressBar setUsesThreadedAnimation:YES];
	[progressText setStringValue:task];
	[[progressBar window]display];
}

-(void)createErrorFromString:(NSString *)s{
	
	NSMutableDictionary * d = [NSMutableDictionary dictionaryWithObject:s forKey:NSLocalizedDescriptionKey];
	
	NSError * error = [NSError errorWithDomain:@"network" code:0 userInfo:d];
	[self presentError:error];
	
}

-(void)addConnection:(Connection *)c{

	NSMutableSet * connections = (NSMutableSet *)[self valueForKey:@"connections"];

	if(![connections containsObject:c])
		[connections addObject:c];
}

-(NSMutableSet *)connections{

	return (NSMutableSet *)[self valueForKey:@"connections"];
}

-(int)compoundsCount{

	int i=0;
	
	for(Material * m in (NSArray *)[self valueForKey:@"materials"]){
		if([m isCompound])
			i++;
	}
	return i;
}

-(int)derivativesCount{
	int i=0;
	
	for(Material * m in (NSArray *)[self valueForKey:@"materials"]){
		if([m isDerivative])
			i++;
	}
	return i;
}

-(IBAction)exportPDF:(id)sender{

	[graphCreator print];
}

-(IBAction)filter:(id)sender{
	//[[pe window]makeKeyAndOrderFront:nil];
	/* [NSApp beginSheet:[filter window]
			   modalForWindow:mainWindow
				modalDelegate:nil
			   didEndSelector:NULL
				  contextInfo:nil]; */

  //  [self willChangeValueForKey:@"materials"];
	[filter wakeUp];
   // 
//    [self didChangeValueForKey:@"materials"];
	/* NSWindow * w = [filter window];
		if(!w)NSLog(@"no window!");
		[w makeKeyAndOrderFront:sender]; */
}

-(IBAction)deleteFiltration:(id)sender{

	[filter deleteFiltration];
}

-(void)updateMaterialListDisplay{
    [materialArrayController rearrangeObjects];
}

-(IBAction)retry:(id)sender{
	[graphCreator retry];
}

-(float)sollSum:(float)max{

	return max/2 * (max+1);
}

//-(void)openQuickLookPanel:(NSString*)path{		
//	[[QLPreviewPanel sharedPreviewPanel] setURLs:[NSArray arrayWithObject:[NSURL fileURLWithPath:path]] currentIndex:0 preservingDisplayState:YES];
//	
//	[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFrontWithEffect:1];   // 1 = fade in 
//}
//
//-(IBAction)preview:(id)sender{
//
//    NSLog(@"huhu!");
//    
//    if(preview){
//		[[QLPreviewPanel sharedPreviewPanel] closeWithEffect:1];
//		//[window makeKeyAndOrderFront:nil];
//		preview = NO;
//	}
//	else preview = YES;
//  
//  NSString * path =  [[filesArrayController selection]valueForKey:@"path"];
//  //  NSLog(@"path: %@", path);
//    
////	NSString  * path = [[[activeMaterial files] objectAtIndex:[fileTable selectedRow]]path];
//	NSURL *url = [NSURL fileURLWithPath:path];
//	NSArray * URLs = [NSArray arrayWithObject:url];
//	
//	[[QLPreviewPanel sharedPreviewPanel] setURLs:URLs currentIndex:0 preservingDisplayState:YES];
//	[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFrontWithEffect:2];
//}
//
//// Quick Look panel data source
//
//- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
//{
//    return 1;
//}
//
//- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
//{
//    return [selectedDownloads objectAtIndex:index];
//}

@end
