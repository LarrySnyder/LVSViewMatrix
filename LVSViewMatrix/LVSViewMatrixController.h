//
//  LVSViewMatrixController.h
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LVSRowAlignmentTop,
    LVSRowAlignmentMiddle,
    LVSRowAlignmentBottom
} LVSRowAlignment;

typedef enum : NSUInteger {
    LVSColAlignmentLeft,
    LVSColAlignmentCenter,
    LVSColAlignmentRight
} LVSColAlignment;



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

#pragma mark Adding Rows and Columns

/*
 insertRow:atRow:withHeight:withAlignment:animated:
 - row is an NSArray* containing cells, in order. If number of cells in row < number of
 columns in matrix, remaining cells in new row are filled with NSNull.
 - To insert a row after the last row, set atRow to numberOfRows. Raises an exception
 if atRow > numberOfRows. 
 
 insertRow:atRow:
 - Same as insertRow:atRow:withHeight:withAlignment:animated: but uses default values 
 for height and alignment.
 
 Similar comments for insertCol:atCol:withWidth:withAlignment:animated and insertCol:atCol:withWidth:.
 */
- (void)insertRow:(NSMutableArray *)row atRow:(NSInteger)rowNum withHeight:(CGFloat)height withAlignment:(LVSRowAlignment)alignment animated:(BOOL)animated;
- (void)insertRow:(NSMutableArray *)row atRow:(NSInteger)rowNum animated:(BOOL)animated;
- (void)insertCol:(NSMutableArray *)col atCol:(NSInteger)colNum withWidth:(CGFloat)width withAlignment:(LVSColAlignment) alignment animated:(BOOL)animated;
- (void)insertCol:(NSMutableArray *)col atCol:(NSInteger)colNum animated:(BOOL)animated;

#pragma mark Getting and Settings Views

/*
 Adds a view to a given cell.
 */
- (void)setView:(UIView *)view forRow:(NSInteger)row forCol:(NSInteger)col;

/*
 Returns the view in a given cell.
 */
- (UIView *)viewInRow:(NSInteger)row forCol:(NSInteger)col;

#pragma mark Layout

/*
 Margins to add between rows and columns (in points). Defaults to 0.
 */
@property (nonatomic, assign) CGFloat rowMargin;
@property (nonatomic, assign) CGFloat colMargin;

/*
 Set/get row height and column width. Set to anything <0 to set automatically.
 If no height/width is set for a row/column, it defaults to -1. 
 getHeightForRow: and getWidthForCol: return actual height/width if set to <0.
 */
- (void)setHeight:(CGFloat)height forRow:(NSInteger)row;
- (void)setWidth:(CGFloat)width forCol:(NSInteger)col;
- (CGFloat)getHeightForRow:(NSInteger)row;
- (CGFloat)getWidthForCol:(NSInteger)col;

/*
 Sets frames of all cells.
 */
- (void)layoutCellsAnimated:(BOOL)animated;


@end
