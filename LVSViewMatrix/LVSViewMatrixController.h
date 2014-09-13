//
//  LVSViewMatrixController.h
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LVSViewMatrixController : UIViewController

#pragma mark Initializers

/*
 Designated initializer. 
 */
- (id)initWithNumRows:(NSInteger)numRows withNumCols:(NSInteger)numCols;

#pragma mark Size

/*
 Number of rows and columns in matrix. Read only.
 */
// (Not sure why I need to declare getter name explicitly, but I seem to...)
@property (nonatomic, readonly, getter = getNumberOfRows) NSInteger numberOfRows;
@property (nonatomic, readonly, getter = getNumberOfCols) NSInteger numberOfCols;

/*
 Inserting rows and columns. 
 
 insertRows:atRow:withHeight:
 row is an NSArray* containing cells, in order. If number of cells in row < number of 
 columns in matrix, remaining cells in new row are filled with NSNull.
 
 To insert a row after the last row, set atRow to numberOfRows. Raises an exception 
 if atRow > numberOfRows. 
 
 To compute height automatically, set height to anything <0.
 
 Similar comments for insertCols:atCol:withWidth:
 */
- (void)insertRow:(NSMutableArray *)row atRow:(NSInteger)rowNum withHeight:(CGFloat)height animated:(BOOL)animated;
- (void)insertCol:(NSMutableArray *)col atCol:(NSInteger)colNum withWidth:(CGFloat)width animated:(BOOL)animated;

#pragma mark Getting and Settings Cells

/*
 Adds a view to a given cell.
 */
- (void)setView:(UIView *)view forRow:(NSInteger)row forCol:(NSInteger)col;

/*
 Returns the view in a given cell.
 */
- (UIView *)getViewForRow:(NSInteger)row forCol:(NSInteger)col;

#pragma mark Layout

/*
 Margins to add between rows and columns (in points). Defaults to 0.
 */
@property (nonatomic, assign) CGFloat rowMargin;
@property (nonatomic, assign) CGFloat colMargin;

- (void)layoutCells; // THIS SHOULD BE PRIVATE; ACCESS IT ANOTHER WAY

@end
