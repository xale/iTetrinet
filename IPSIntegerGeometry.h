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

NS_INLINE NSString* IPSStringFromCoord(IPSCoord coord)
{
	return [NSString stringWithFormat:@"(%d, %d)", coord.row, coord.col];
}

extern const IPSCoord IPSZeroCoord;

#pragma mark Areas

typedef struct IPSArea
{
	NSUInteger height, width;
} IPSArea;

NS_INLINE IPSArea IPSMakeArea(NSUInteger height, NSUInteger width)
{
	IPSArea a;
	a.height = height;
	a.width = width;
	return a;
}

NS_INLINE BOOL IPSEqualAreas(IPSArea a, IPSArea b)
{
	return ((a.height == b.height) && (a.width == b.width));
}

NS_INLINE NSString* IPSStringFromArea(IPSArea area)
{
	return [NSString stringWithFormat:@"{%u, %u}", area.height, area.width];
}

extern const IPSArea IPSZeroArea;

#pragma mark Regions

typedef struct IPSRegion
{
	IPSCoord origin;
	IPSArea area;
} IPSRegion;

NS_INLINE IPSRegion IPSMakeRegion(NSInteger row, NSInteger col, NSInteger height, NSInteger width)
{
	IPSRegion r;
	r.origin.row = row;
	r.origin.col = col;
	r.area.height = height;
	r.area.width = width;
	return r;
}

NS_INLINE IPSRegion IPSMakeRegionFromBounds(NSInteger minRow, NSInteger minCol, NSInteger maxRow, NSInteger maxCol)
{
	IPSRegion r;
	r.origin.row = minRow;
	r.origin.col = minCol;
	r.area.height = ((maxRow - minRow) + 1);
	r.area.width = ((maxCol - minCol) + 1);
	return r;
}

NS_INLINE NSInteger IPSMinRow(IPSRegion region)
{
	return region.origin.row;
}

NS_INLINE NSInteger IPSMinCol(IPSRegion region)
{
	return region.origin.col;
}

NS_INLINE NSInteger IPSMaxRow(IPSRegion region)
{
	return ((region.origin.row + region.area.height) - 1);
}

NS_INLINE NSInteger IPSMaxCol(IPSRegion region)
{
	return ((region.origin.col + region.area.width) - 1);
}

NS_INLINE BOOL IPSEqualRegions(IPSRegion a, IPSRegion b)
{
	return (IPSEqualCoords(a.origin, b.origin) && IPSEqualAreas(a.area, b.area));
}

NS_INLINE NSString* IPSStringFromRegion(IPSRegion region)
{
	return [NSString stringWithFormat:@"{(%d, %d), {%u, %u}}", region.origin.row, region.origin.col, region.area.height, region.area.width];
}

extern const IPSRegion IPSEmptyRegion;
