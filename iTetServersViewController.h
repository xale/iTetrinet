//
//  iTetServersViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/5/09.
//

#import <Cocoa/Cocoa.h>

@class iTetPreferencesController;

@interface iTetServersViewController : NSViewController
{
	
}

+ (id)viewController;

@property (readonly) iTetPreferencesController* preferencesController;
@property (readonly) NSArray* valuesForProtocolPopUpCell;

@end
