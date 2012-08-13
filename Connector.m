//
//  Connector.m
//  CompoundNetwork
//
//  Created by max on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connector.h"
#import "MyDocument.h"
#import "Connection.h"
#import "Material.h"


@implementation Connector

-(Connector *)init{

	if(self = [super init]){
	
		connections = [[NSMutableSet alloc]init];
	
	}
	return self;
}

-(void) dealloc{

	[connections removeAllObjects];
	[connections release];
	[super dealloc];
}


-(void)createConnections{
	
	[self disconnectEverything]; // wenn noch verbindungen da sind muessen die alle WEG!!!!

	[connections removeAllObjects];

	//NSLog(@"Connector: after disconnectEverything: connections: %@", connections);

	/* for(Material * m in [doc materials]){
		
			NSLog(@"material: %@ connections : %@", [m valueForKey:@"name"], [m valueForKey:@"connections"]);
		} */
	
	NSString * tag;
	NSMutableArray * tags = (NSMutableArray *)[doc valueForKey:@"allTags"];
	NSEnumerator *t= [tags objectEnumerator];
	NSMutableSet * group; 
	
	while((tag=[[t nextObject]valueForKey:@"name"])){
		
		group = [[self materialsWithTag:tag]retain];
		count = 0;
		//NSLog(@"found %d materials with the tag %@ should create %f connections", [group count], tag, [doc sollSum:[group count]-1]);
		[self connectAllMaterialsInSet:group viaTag:tag];
		[group release];
	}
	
	//NSLog(@"connector: DONE! created %d connections", [connections count]);
}

-(NSMutableSet *)materialsWithTag:(NSString *)tag{
//	NSLog(@"Connector: searching for materials with tag: %@", tag);
	NSMutableSet * g = [[NSMutableSet alloc]init];
	
	NSEnumerator * m = [[doc materials] objectEnumerator];
	Material * mat;
	while(mat = [m nextObject]){
		
		if([mat hasTag:tag])
			[g addObject:mat];
		
	}
	//NSLog(@"%d materials found. \n", [g count]);
	return [g autorelease];
}

-(void)connectAllMaterialsInSet:(NSMutableSet *)set viaTag:(NSString *)tag {
	
	NSMutableSet * g = [NSMutableSet setWithSet:set];
	Material * m;
	while([g count]>1){
		m = [g anyObject];
		[g removeObject:m];
		[self connectMaterial:m withAllMaterialsInSet:g viaTag:tag];
	}
}

-(void)connectMaterial:(Material *)mat withAllMaterialsInSet:(NSSet *)g viaTag:(NSString *)tag{
	
	NSEnumerator * e = [g objectEnumerator];
	Material * m;
	Connection * c;
	while(m = [e nextObject]){
		c = [[Connection alloc]initWithMaterialA:mat];
		[c setMaterialB:m];
		[c setTag: tag];
		[connections addObject:c];
		[doc addConnection:c];
		count++;
		//NSLog(@"connecting material %@ and %@ for tag %@: %d", [mat name], [m name], tag, count);
		[c autorelease];
	}
	
}

-(NSMutableSet *)connections{return connections;}
-(void)setDoc:(MyDocument *)d{doc = d;}

-(void)disconnectEverything{

	/*for(Material * m in [doc materials])	
		[m removeAllConnections];*/
	
	for(Connection * c in connections){
	
		[c disconnect];
	}
}

@end
