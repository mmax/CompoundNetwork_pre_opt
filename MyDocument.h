//
//  MyDocument.h
//  CompoundNetwork
//
//  Created by max on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class Connector, Material, GraphCreator, Connection, Filter;




@interface MyDocument : NSDocument
{
	
	NSMutableDictionary * dict;
	IBOutlet NSArrayController * materialArrayController;
	IBOutlet NSArrayController * tagArrayController;
	IBOutlet NSArrayController * allTagsArrayController;
	IBOutlet NSArrayController * identityArrayController;
	IBOutlet NSArrayController * allIdentitiesArrayController;
	IBOutlet NSArrayController * networkArrayController;
   	IBOutlet NSArrayController * filesArrayController;
	IBOutlet NSArrayController * allNetworksArrayController;
	Connector * connector;
	IBOutlet NSProgressIndicator * progressBar;
	IBOutlet NSTextField * progressText;
	IBOutlet GraphCreator * graphCreator;
	IBOutlet Filter * filter;
	IBOutlet NSWindow * mainWindow;
    BOOL preview;
}

-(IBAction)exportPDF:(id)sender;
-(IBAction)filter:(id)sender;
-(IBAction)deleteFiltration:(id)sender;
-(void)updateMaterialListDisplay;
-(IBAction)openPath:(id)sender;
-(IBAction)materialArraySelectionChanged:(id)sender;
-(void)setValue:(id)value forKey:(NSString *)key;
-(id)valueForKey:(NSString *)key;
-(id)valueForKeyPath:(NSString *)keyPath;
-(void)loadMaterials;
-(void)createMaterialFromPath:(NSString *)path;
-(Material *)getMaterialByName:(NSString *)name;
-(IBAction)saveMaterial:(id)sender;
-(IBAction)setImage:(id)sender;
-(IBAction)addTag:(id)sender;
-(IBAction)removeTag:(id)sender;
-(void)registerNewTag:(NSString *)s;
-(BOOL)hasTag:(NSString *)tag;
-(IBAction)addSelectedTag:(id)sender;
-(IBAction)addIdentity:(id)sender;
-(IBAction)removeIdentity:(id)sender;
-(void)registerNewIdentity:(NSString *)s;
-(BOOL)hasIdentity:(NSString *)iden;
-(IBAction)addSelectedIdentity:(id)sender;
-(IBAction)addNetwork:(id)sender;
-(IBAction)removeNetwork:(id)sender;
-(void)registerNewNetwork:(NSString *)s;
-(BOOL)hasNetwork:(NSString *)iden;
-(IBAction)addSelectedNetwork:(id)sender;
-(NSMutableArray *)materials;
-(NSSet *)files;
-(IBAction)renderGraphics:(id)sender;
-(IBAction)createConnections:(id)sender;
-(NSMutableArray *)identityNames;

-(void) displayProgress:(BOOL) display;
-(void) setProgress:(float)progress;
-(void) setProgressTask:(NSString *) task;
-(void) setIndeterminateProgressTask:(NSString *) task;
-(NSMutableArray *)materialNames;
-(NSMutableSet *)subsetsOfMaterial:(Material *)m;
-(void)createErrorFromString:(NSString *)s;
-(void)addConnection:(Connection *)c;
-(NSMutableSet *)connections;
-(int)compoundsCount;
-(int)derivativesCount;
-(IBAction)retry:(id)sender;
-(float)sollSum:(float)max;
//-(void)openQuickLookPanel:(NSString*)path;
//-(IBAction)preview:(id)sender;
@end
