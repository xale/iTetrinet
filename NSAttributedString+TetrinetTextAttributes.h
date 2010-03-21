//
//  NSAttributedString+TetrinetTextAttributes.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/20/10.
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (TetrinetTextAttributes)

- (id)initWithPlineMessageData:(NSData*)messageData;

- (NSData*)plineMessageData;

@end
