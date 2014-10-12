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

/* 
 Tiny object to store (row,col) for a cell. 
 */
@interface LVSCellLoc : NSObject
@property (nonatomic, assign) int row;
@property (nonatomic, assign) int col;
+ (LVSCellLoc *)cellLocwithRow:(int)row col:(int)col;
@end

@class LVSViewMatrixController;

#pragma mark LVSViewMatrixControllerDelegate

@protocol LVSViewMatrixControllerDelegate <NSObject>

/* 
 Asks the delegate for an array of cells to insert as a new row at a given location.
 Raises exception if delegate provides a row/column with the wrong number of cells.
 */
- (NSArray *)viewMatrix:(LVSViewMatrixController *)viewMatrix rowToInsertAtRow:(NSInteger)row;
- (NSArray *)viewMatrix:(LVSViewMatrixController *)viewMatrix colToInsertAtCol:(NSInteger)col;

/*
 Asks the delegate for alignment and size for new row/col at a given location.
 */
@optional
- (LVSRowAlignment)viewMatrix:(LVSViewMatrixController *)viewMatrix alignmentForRow:(NSInteger)row;
- (LVSColAlignment)viewMatrix:(LVSViewMatrixController *)viewMatrix alignmentForCol:(NSInteger)col;
- (CGFloat)viewMatrix:(LVSViewMatrixController *)viewMatrix heightForRow:(NSInteger)row;
- (CGFloat)viewMatrix:(LVSViewMatrixController *)viewMatrix widthForCol:(NSInteger)col;

// TODO: add methods for getting alignment and size
@end


@interface LVSViewMatrixController : UIViewController

#pragma mark Initializers

/*
 Designated initializer. 
 */
- (id)initWithNumRows:(NSInteger)numRows withNumCols:(NSInteger)numCols;

/*
 Delegate.
 */
@property (nonatomic, weak) id <LVSViewMatrixControllerDelegate> delegate;

#pragma mark Size

/*
 Number of rows and columns in matrix. Read only.
 */
@property (nonatomic, readonly) NSInteger numberOfRows;
@property (nonatomic, readonly) NSInteger numberOfCols;

#pragma mark Inserting and Deleting Rows and Columns

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

/*
 Delete Remove row or column.
 */
- (void)deleteRow:(NSInteger)rowNum animated:(BOOL)animated;
- (void)deleteCol:(NSInteger)colNum animated:(BOOL)animated;

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

/*
 Returns LVSCellLoc containing row and column that contain a given point. Point
 must be in view matrix's coordinates. If the point is not contained in the table, 
 returns an LVSCellLoc containing (-1,-1).
 */
- (LVSCellLoc *)locationInTableOfPoint:(CGPoint)point;

/*
 Returns CGRect equal to the union of all cells in a given row or column.
 Rect is in view matrix's own coordinates.
 Returns CGRectZero if the given row or column does not exist.
 */
- (CGRect)rectForRow:(NSInteger)row;
- (CGRect)rectForCol:(NSInteger)col;


@end
