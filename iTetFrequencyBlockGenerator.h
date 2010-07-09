//
//  iTetFrequencyBlockGenerator.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/9/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>
#import "iTetRandomBlockGenerator.h"

@interface iTetFrequencyBlockGenerator : iTetRandomBlockGenerator
{
	NSArray* blockFrequencies;
}

- (id)initWithBlockFrequencies:(NSArray*)frequencies;

@end
