//
//  iTetGeneralPrefsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetGeneralPrefsViewController.h"

@implementation iTetGeneralPrefsViewController

- (id)init
{
	if (![super initWithNibName:@"GeneralPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:@"Preferences"];
	
	return self;
}

@end
