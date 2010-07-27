//
//  IPSIntegerGeometry.h
//  iTetrinet
//
//  Created by Alex Heinz on 7/27/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

#pragma mark Coordinate Pairs

typedef struct IPSCoord
{
	NSInteger row, col;
} IPSCoord;

NS_INLINE IPSCoord IPSMakeCoord(NSInteger row, NSInteger col)
{
	IPSCoord c;
	c.row = row;
	c.col = col;
	return c;
}

NS_INLINE BOOL IPSEqualCoords(IPSCoord a, IPSCoord b)
{
	return ((a.row == b.row) && (a.col == b.col));
}

extern const IPSCoord IPSZeroCoord;

#pragma mark Regions

typedef struct IPSRegion
{
	NSInteger minRow, minCol, maxRow, maxCol;
} IPSRegion;

NS_INLINE IPSRegion IPSMakeRegion(NSInteger minRow, NSInteger minCol, NSInteger maxRow, NSInteger maxCol)
{
	IPSRegion r;
	r.minRow = minRow;
	r.minCol = minCol;
	r.maxRow = maxRow;
	r.maxCol = maxCol;
	return r;
}

NS_INLINE BOOL IPSEqualRegions(IPSRegion a, IPSRegion b)
{
	return ((a.minRow == b.minRow) && (a.minCol == b.minCol) && (a.maxRow == b.maxRow) && (a.maxCol == b.maxCol));
}

extern const IPSRegion IPSEmptyRegion;
