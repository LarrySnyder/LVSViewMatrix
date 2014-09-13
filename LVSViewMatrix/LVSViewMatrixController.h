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
@property (nonatomic, readonly) NSInteger numberOfRows;
@property (nonatomic, readonly) NSInteger numberOfCols;

/*
 Inserting rows and columns. To insert a row [column] after the last row [column],
 set atRow [atCol] to numberOfRows [numberOfCols]. Raises an exception if atRow > numberOfRows
 [atCol > numberOfCols].
 */
- (void)insertRows:(NSInteger)numRows atRow:(NSInteger)row;
- (void)insertCols:(NSInteger)numCols atCol:(NSInteger)col;

#pragma mark Getting and Settings Cells

/*
 Adds a view to a given cell.
 */
- (void)setView:(UIView *)view forRow:(NSInteger)row forCol:(NSInteger)col;

/*
 Returns the view in a given cell.
 */
- (UIView *)getViewForRow:(NSInteger)row forCol:(NSInteger)col;

@end
