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


#pragma mark --- LVSViewMatrixRow ---

@interface LVSViewMatrixRow : NSObject

/*
 NSMutableArray of cells in row. Allocated by init.
 */
@property (nonatomic, strong) NSMutableArray *cells;

/*
 Number of cells in row. Read only.
 */
@property (nonatomic, readonly) NSInteger numCells;

/*
 Row height. Set to anything <0 to set height automatically.
 Defaults to -1.
 */
@property (nonatomic, assign) CGFloat height;

/*
 Vertical alignment. Choose from {LVSRowAlignmentTop,
 LVSRowAlignmentMiddle, LVSRowAlignmentBottom}. Defaults to
 LVSRowAlignmentMiddle. */
@property (nonatomic, assign) LVSRowAlignment alignment;

@end




#pragma mark --- LVSViewMatrixController ---

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
 Inserting rows and columns. 
 
 insertRows:atRow:withHeight:
 row is an NSArray* containing cells, in order. If number of cells in row < number of 
 columns in matrix, remaining cells in new row are filled with NSNull.
 
 To insert a row after the last row, set atRow to numberOfRows. Raises an exception 
 if atRow > numberOfRows. 
 
 To compute height automatically, set height to anything <0.
 
 Similar comments for insertCols:atCol:withWidth:
 */
- (void)insertRow:(LVSViewMatrixRow *)row atRow:(NSInteger)rowNum animated:(BOOL)animated;
//- (void)insertRow:(NSMutableArray *)row atRow:(NSInteger)rowNum withHeight:(CGFloat)height animated:(BOOL)animated;
//- (void)insertCol:(NSMutableArray *)col atCol:(NSInteger)colNum withWidth:(CGFloat)width animated:(BOOL)animated;

#pragma mark Getting and Settings Cells

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

- (void)layoutCells; // THIS SHOULD BE PRIVATE; ACCESS IT ANOTHER WAY

@end
