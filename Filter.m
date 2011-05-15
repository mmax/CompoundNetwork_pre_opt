//
//  Filter.m
//  CompoundNetwork
//
//  Created by max on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Filter.h"


@implementation Filter


-(Filter *)init{

	if(self = [super init]){
	
		dict = [[NSMutableDictionary alloc]init];
		[self setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"tags"];

		[self setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"identities"];
		
		[self setValue:[[[NSMutableArray alloc]init]autorelease] forKey:@"networks"];
	}
	return self;
}

-(void)dealloc{

	[dict removeAllObjects];
	[super dealloc];
}

-(IBAction)clear:(id)sender{

	[self willChangeValueForKey:@"tags"];
	[[self valueForKey:@"tags"]removeAllObjects];
	[self didChangeValueForKey:@"tags"];
	
	[self willChangeValueForKey:@"identities"];
	[[self valueForKey:@"identities"]removeAllObjects];
	[self didChangeValueForKey:@"identities"];
	
	[self willChangeValueForKey:@"networks"];
	[[self valueForKey:@"networks"]removeAllObjects];
	[self didChangeValueForKey:@"networks"];
	
}

//-(IBAction)filter:(id)sender{
//	
//	[self deleteFiltration];
//	
//	BOOL visible = NO;
//	
//	for(Material * m in [doc materials]){
//	
//		for(NSDictionary * d in [self valueForKey:@"tags"]){
//		
//			if ([m hasTag:[d valueForKey:@"name"]])
//				visible = YES;
//		}
//		
//		for(NSDictionary * d in [self valueForKey:@"identities"]){
//			
//			if ([m hasIdentity:[d valueForKey:@"name"]])
//				 visible = YES;
//		}
//		
//		for(NSDictionary * d in [self valueForKey:@"networks"]){
//			
//			if ([m hasNetwork:[d valueForKey:@"name"]])
//				visible = YES;
//		}
//		
//		[m setIsVisible:visible];
//		visible = NO;
//	}
//    [doc updateMaterialListDisplay];
//	[self cancel:nil];
//}

-(IBAction)filter:(id)sender{

    [self deleteFiltration];
    
    BOOL visible = YES;

    for(Material * m in [doc materials]){
        for(NSDictionary * d in [self valueForKey:@"tags"]){
            if (![m hasTag:[d valueForKey:@"name"]]){
                visible = NO;
                break;
            }
        }
        
        for(NSDictionary * d in [self valueForKey:@"identities"]){
            if (![m hasIdentity:[d valueForKey:@"name"]]){
                visible = NO;
                break;
            }
        }
        
        for(NSDictionary * d in [self valueForKey:@"networks"]){
            if (![m hasNetwork:[d valueForKey:@"name"]]){
                visible = NO;
                break;
            }
        }
        
        [m setIsVisible:visible];
        visible = YES;
    }
    [doc updateMaterialListDisplay];
	[self cancel:nil];
}




-(void)deleteFiltration{

	for(Material * m in [doc materials])
		[m setIsVisible:YES];
    
    [doc updateMaterialListDisplay];
}


-(IBAction)addSelectedIdentity:(id)sender{
	NSString * identity  = [[[allIdentitiesArrayController selectedObjects]lastObject]valueForKey:@"name"];
	if([self hasIdentity:identity])return;
	[self willChangeValueForKey:@"identities"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:identity forKey:@"name"];
	[[self valueForKey:@"identities"]addObject:d];
	[self didChangeValueForKey:@"identities"];
	
}

-(IBAction)removeIdentity:(id)sender{
	
	//	id active = [[filterTagsArrayController selectedObjects]lastObject];
	[self willChangeValueForKey:@"identities"];
	[[self valueForKey:@"identities"] removeObject:[[filterIdentitiesArrayController selectedObjects]lastObject]];
	[self didChangeValueForKey:@"identities"];
	
}

-(IBAction)addSelectedTag:(id)sender{
	
	
	NSString * tag  = [[[allTagsArrayController selectedObjects]lastObject]valueForKey:@"name"];
	if([self hasTag:tag])return;
	[self willChangeValueForKey:@"tags"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:tag forKey:@"name"];
	[[self valueForKey:@"tags"]addObject:d];
	[self didChangeValueForKey:@"tags"];
	//NSLog(@"FILTER: added tag: %@ \ntags : %@", tag, [self valueForKey:@"tags"]);
}

-(IBAction)removeTag:(id)sender{
	
//	id active = [[filterTagsArrayController selectedObjects]lastObject];
	[self willChangeValueForKey:@"tags"];
	[[self valueForKey:@"tags"] removeObject:[[filterTagsArrayController selectedObjects]lastObject]];
	[self didChangeValueForKey:@"tags"];
	
}


-(IBAction)addSelectedNetwork:(id)sender{
	NSString * network  = [[[allNetworksArrayController selectedObjects]lastObject]valueForKey:@"name"];
	if([self hasNetwork:network])return;
	[self willChangeValueForKey:@"networks"];
	NSMutableDictionary * d = [[[NSMutableDictionary alloc]init]autorelease];
	[d setValue:network forKey:@"name"];
	[[self valueForKey:@"networks"]addObject:d];
	[self didChangeValueForKey:@"networks"];
	
}

-(IBAction)removeNetwork:(id)sender{
	
	//	id active = [[filterTagsArrayController selectedObjects]lastObject];
	[self willChangeValueForKey:@"networks"];
	[[self valueForKey:@"networks"] removeObject:[[filterNetworksArrayController selectedObjects]lastObject]];
	[self didChangeValueForKey:@"networks"];
	
}


-(BOOL)hasTag:(NSString *)tag{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"tags"]){
		if ([[d valueForKey:@"name"] isEqualToString:tag])
			return YES;
	}
	return NO;
}


-(BOOL)hasIdentity:(NSString *)net{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"networks"]){
		if ([[d valueForKey:@"name"] isEqualToString:net])
			return YES;
	}
	return NO;
}

-(BOOL)hasNetwork:(NSString *)iden{
	
	for(NSDictionary * d in(NSArray *)[self valueForKey:@"identities"]){
		if ([[d valueForKey:@"name"] isEqualToString:iden])
			return YES;
	}
	return NO;
}

-(void)setValue:(id)value forKey:(NSString *)key{
	
	[dict setValue:value forKey:key];
}

-(id)valueForKey:(NSString *)key{
	
	return [dict valueForKey:key];
}

-(void)wakeUp{
	[window makeKeyAndOrderFront:nil];
}
-(NSPanel*)window{
	
	return window;
}

-(IBAction)cancel:(id)sender{

	//[NSApp endSheet:window];
	[window orderOut:nil];
}


@end
