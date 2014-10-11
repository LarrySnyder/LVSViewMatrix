//
//  LVSViewMatrixController.m
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import "LVSViewMatrixController.h"

#ifndef kAnimationDuration
#define kAnimationDuration	0.5
#endif

typedef enum : NSUInteger {
    LVSPinchTypeNone,
    LVSPinchTypeRow,
    LVSPinchTypeCol
} LVSPinchType;


#pragma mark LVSCellLoc

@implementation LVSCellLoc

+ (LVSCellLoc *)cellLocwithRow:(int)row col:(int)col
{
    LVSCellLoc *loc = [[LVSCellLoc alloc] init];
    loc.row = row;
    loc.col = col;

    return loc;
}

@end

#pragma mark LVSViewMatrixController

@interface LVSViewMatrixController ()

@end

@implementation LVSViewMatrixController
{
    // Cells in the matrix, stored as an array of arrays. Outer array corresponds to rows, inner to columns.
    // Can access using _cells[r][c]. All objects are of type UIView*
    NSMutableArray *_cells;
    
    // Row and column origins (_rowOrigins[i] = origin of left-most cell in row i, _colOrigins[j] = origin
    // of top-most cell in col j)
//    NSMutableArray *_rowOrigins;
  //  NSMutableArray *_colOrigins;
    
    // Row heights and column widths as specified by user. Values <0 indicate that height/width
    // should be set automatically
    NSMutableArray *_userRowHeights;
    NSMutableArray *_userColWidths;
    
    // Actual row heights and column widths. If _rowHeights[r] = _userRowHeights[r] if _userRowHeights[r] < 0
    // and = value set automatically otherwise
    NSMutableArray *_rowHeights;
    NSMutableArray *_colWidths;
    
    // Alignment
    NSMutableArray *_rowAlignments;
    NSMutableArray *_colAlignments;
    
    // Info about current pinch (if any)
    LVSPinchType _currentPinchType;
    CGPoint _startPinchLoc0;            // loc0 is always the top-most touch (for row pinches)
    CGPoint _startPinchLoc1;            //      or left-most pinch (for col pinches)
    NSInteger _pinchRowCol0;            // index of rows/cols (depending on pinch type) pinch started on
    NSInteger _pinchRowCol1;            //      pinchRowCol0 is always top- or left-most pinch
    NSMutableArray *_origFrames;
    NSArray *_cellsBeingInserted;       // new row/col (depending on pinch type) being inserted
    CGFloat _maxSizeOfCellsBeingInserted;  // max height/width (depending on pinch type) of cells being inserted
    NSMutableArray *_origSizesOfCellsBeingInserted;
                                        // original sizes of cells being inserted (position is ignored but size is preserved)
}

#pragma mark Initializers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/* Designated initializer. */
- (id)initWithNumRows:(NSInteger)numRows withNumCols:(NSInteger)numCols
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Initialize properties
        self.rowMargin = 0.0;
        self.colMargin = 0.0;
        
        // Initialize _cells
        _cells = [[NSMutableArray alloc] initWithCapacity:numRows];
        
        // Initialize row/col origins
        //_rowOrigins = [[NSMutableArray alloc] initWithCapacity:numRows];
        //_colOrigins = [[NSMutableArray alloc] initWithCapacity:numCols];
        
        // Initialize row heights and column widths
        _userRowHeights = [[NSMutableArray alloc] initWithCapacity:numRows];
        _userColWidths = [[NSMutableArray alloc] initWithCapacity:numCols];
        _rowHeights = [[NSMutableArray alloc] initWithCapacity:numRows];
        _colWidths = [[NSMutableArray alloc] initWithCapacity:numCols];
        
        // Initialize row and column alignments
        _rowAlignments = [[NSMutableArray alloc] initWithCapacity:numRows];
        _colAlignments = [[NSMutableArray alloc] initWithCapacity:numCols];

        // Insert empty rows and columns
        for (int i = 0; i < numRows; i++)
        {
            NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:numCols];
            [self insertRow:row atRow:0 animated:NO];
        }
        for (int j = 0; j < numCols; j++)
        {
            NSMutableArray *col = [[NSMutableArray alloc] initWithCapacity:numRows];
            [self insertCol:col atCol:0 animated:NO];
        }
        
        // Initialize _currentPinchType
        _currentPinchType = LVSPinchTypeNone;
    }
    return self;
}

- (id)init
{
    self = [self initWithNumRows:0 withNumCols:0];
    return self;
}

#pragma mark Property Sets/Gets

- (NSInteger)numberOfRows
{
    return [_cells count];
}

- (NSInteger)numberOfCols
{
    if ([_cells count] == 0)
        return 0;
    else
        return [((NSMutableArray *)_cells[0]) count];
}

#pragma mark View Stuff

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up gesture recognizers
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    for (UIGestureRecognizer *gr in [self.view gestureRecognizers])
        NSLog(@"%@", gr.description);
    for (UIView *subview in [self.view subviews])
        for (UIGestureRecognizer *gr in [subview gestureRecognizers])
            NSLog(@"%@", gr.description);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Adding Rows and Columns

- (void)insertRow:(NSMutableArray *)row
            atRow:(NSInteger)rowNum
       withHeight:(CGFloat)height
    withAlignment:(LVSRowAlignment)alignment
         animated:(BOOL)animated
{
    if (rowNum > self.numberOfRows)
    {
        NSException *e = [NSException exceptionWithName:@"SubscriptOutOfBounds"
                                                 reason:@"Attempted to insert row(s) at a row index that does not exist"
                                               userInfo:nil];
        @throw e;
    }
    else
    {
        // Add null entries at end of row, if necessary
        for (NSInteger j = [row count]; j < self.numberOfCols; j++)
            row[j] = [NSNull null];
        
        // Insert new row into matrix
        [_cells insertObject:row atIndex:rowNum];
        
        // Add cells from new row as subviews
        for (int j = 0; j < [row count]; j++)
            if (row[j] != [NSNull null])
                [self.view addSubview:(UIView *)row[j]];
        
        // Insert items into _userRowHeights and _rowHeights
        [_userRowHeights insertObject:[NSNumber numberWithFloat:height] atIndex:rowNum];
        [_rowHeights insertObject:[NSNumber numberWithFloat:height] atIndex:rowNum];
        
        // Insert item into _rowAlignments
        [_rowAlignments insertObject:[NSNumber numberWithInteger:alignment] atIndex:rowNum];
        
        // If not animated, just do layout
        if (!animated)
            [self layoutCellsAnimated:NO];
        else
        {
            // Get new frames for all cells
            NSMutableArray *newFrames = [self calcFramesWithRowOffsets:nil withColOffsets:nil];
            
            // Set frames of new cells to 0 size to initiate animation
            for (int j = 0; j < self.numberOfCols; j++)
                if (_cells[rowNum][j] != [NSNull null])
                {
                    UIView *cell = _cells[rowNum][j];
                    CGRect newFrame = [newFrames[rowNum][j] CGRectValue];
                    cell.frame = CGRectMake(CGRectGetMidX(newFrame), CGRectGetMinY(newFrame), 0.0, 0.0);
                }
            
            // Animate insertion
            [UIView animateWithDuration:kAnimationDuration
                             animations:^{
                                 for (int i = 0; i < self.numberOfRows; i++)
                                     for (int j = 0; j < self.numberOfCols; j++)
                                         if (_cells[i][j] != [NSNull null])
                                             ((UIView *)_cells[i][j]).frame = [newFrames[i][j] CGRectValue];
                             }];
            
            // Update layout to insert row in view
//            [self layoutCellsAnimated:animated];
        }
    }
}

- (void)insertRow:(NSMutableArray *)row atRow:(NSInteger)rowNum animated:(BOOL)animated
{
    [self insertRow:row
              atRow:rowNum
         withHeight:-1
      withAlignment:LVSRowAlignmentMiddle
           animated:animated];
}

- (void)insertCol:(NSMutableArray *)col
            atCol:(NSInteger)colNum
        withWidth:(CGFloat)width
    withAlignment:(LVSColAlignment)alignment
         animated:(BOOL)animated
{
    if (colNum > self.numberOfCols)
    {
        NSException *e = [NSException exceptionWithName:@"SubscriptOutOfBounds"
                                                 reason:@"Attempted to insert column(s) at a column index that does not exist"
                                               userInfo:nil];
        @throw e;
    }
    else
    {
        // Add null entries at end of column, if necessary
        for (NSUInteger i = [col count]; i < self.numberOfRows; i++)
            col[i] = [NSNull null];
        
        // Insert new column into matrix rows
        for (int i = 0; i < self.numberOfRows; i++)
            [_cells[i] insertObject:col[i] atIndex:colNum];
        
        // Add cells from new column as subviews
        for (int i = 0; i < [col count]; i++)
            if (col[i] != [NSNull null])
                [self.view addSubview:(UIView *)col[i]];
        
        // Insert items into _userColWidths and _colWidths
        [_userColWidths insertObject:[NSNumber numberWithFloat:width] atIndex:colNum];
        [_colWidths insertObject:[NSNumber numberWithFloat:width] atIndex:colNum];
        
        // Insert item into _colAlignments
        [_colAlignments insertObject:[NSNumber numberWithInteger:alignment] atIndex:colNum];
        
        // If not animated, just do layout
        if (!animated)
            [self layoutCellsAnimated:NO];
        else
        {
            // Get new frames for all cells
            NSMutableArray *newFrames = [self calcFramesWithRowOffsets:nil withColOffsets:nil];
            
            // Set frames of new cells to 0 size to initiate animation
            for (int i = 0; i < self.numberOfRows; i++)
                if (_cells[i][colNum] != [NSNull null])
                {
                    UIView *cell = _cells[i][colNum];
                    CGRect newFrame = [newFrames[i][colNum] CGRectValue];
                    cell.frame = CGRectMake(CGRectGetMinX(newFrame), CGRectGetMidY(newFrame), 0.0, 0.0);
                }
            
            // Animate insertion
            [UIView animateWithDuration:kAnimationDuration
                             animations:^{
                                 for (int i = 0; i < self.numberOfRows; i++)
                                     for (int j = 0; j < self.numberOfCols; j++)
                                         if (_cells[i][j] != [NSNull null])
                                             ((UIView *)_cells[i][j]).frame = [newFrames[i][j] CGRectValue];
                             }];
        }
        
        // Update layout to insert column in view
//        [self layoutCellsAnimated:animated];
    }
}

- (void)insertCol:(NSMutableArray *)col atCol:(NSInteger)colNum animated:(BOOL)animated
{
    [self insertCol:col
              atCol:colNum
          withWidth:-1
      withAlignment:LVSColAlignmentCenter
           animated:animated];
}

#pragma mark Getting and Setting Views

- (void)setView:(UIView *)view forRow:(NSInteger)row forCol:(NSInteger)col
{
    _cells[row][col] = view;
}

- (UIView *)viewInRow:(NSInteger)row forCol:(NSInteger)col
{
    return _cells[row][col];
}

#pragma mark Layout

- (void)setHeight:(CGFloat)height forRow:(NSInteger)row
{
    _rowHeights[row] = [NSNumber numberWithFloat:height];
}

- (void)setWidth:(CGFloat)width forCol:(NSInteger)col
{
    _colWidths[col] = [NSNumber numberWithFloat:width];
}

- (CGFloat)getHeightForRow:(NSInteger)row
{
    return [_rowHeights[row] floatValue];
}

- (CGFloat)getWidthForCol:(NSInteger)col
{
    return [_colWidths[col] floatValue];
}


/*
 Sets row heights and column widths, then sets frames of all cells. 
 */
- (void)layoutCellsAnimated:(BOOL)animated
{
    // Calculate frames
    NSMutableArray *frames = [self calcFramesWithRowOffsets:nil withColOffsets:nil];
    
    // Determine duration
    CGFloat duration;
    if (animated)
        duration = kAnimationDuration;
    else
        duration = 0.0;
    
    // Set frames
    [UIView animateWithDuration:duration
                     animations:^{
                         for (int i = 0; i < self.numberOfRows; i++)
                             for (int j = 0; j < self.numberOfCols; j++)
                                 if (_cells[i][j] != [NSNull null])
                                 {
                                     UIView *cell = _cells[i][j];
                                     cell.frame = [frames[i][j] CGRectValue];
                                     [cell setNeedsDisplay];
                                 }
                     }];
    
    [self.view setNeedsDisplay];
}

- (LVSCellLoc *)locationInTableOfPoint:(CGPoint)point
{
    // Loop through rows to find one that contains point
    int i = 0;
    BOOL found = NO;
    while ((i < self.numberOfRows) && !found)
    {
        if (CGRectContainsPoint([self rectForRow:i], point))
            found = YES;
        else
            i++;
    }
    
    // If we found a row that contains point, loop through columns
    // to find one that contains point
    int j = 0;
    if (found)
    {
        found = NO;
        while ((j < self.numberOfCols) && !found)
        {
            if (CGRectContainsPoint([self rectForCol:j], point))
                found = YES;
            else
                j++;
        }
    }
    
    // If found = YES, we have found a row and col containing point
    if (found)
        return [LVSCellLoc cellLocwithRow:i col:j];
    else
        return [LVSCellLoc cellLocwithRow:-1 col:-1];
}

- (CGRect)rectForRow:(NSInteger)row
{
    CGRect rowRect = CGRectZero;
    
    if (row < self.numberOfRows)
        for (int j = 0; j < self.numberOfCols; j++)
            rowRect = CGRectUnion(rowRect, ((UIView *)_cells[row][j]).frame);
    
    return rowRect;
}

- (CGRect)rectForCol:(NSInteger)col
{
    CGRect colRect = CGRectZero;
    
    if (col < self.numberOfCols)
        for (int i = 0; i < self.numberOfRows; i++)
            colRect = CGRectUnion(colRect, ((UIView *)_cells[i][col]).frame);
    
    return colRect;
}

#pragma mark Private - Gesture Handling

/*
 Handles pinch gesture. When pinch-out gesture begins, if touches are on consecutive rows
 [columns], asks delegate for new row [column] to insert. As touches move, adjusts spacing
 of table. If gesture ends before row [column] expansion is complete, resets table layout. 
 To be handled, a pinch must contain exactly 2 touches, both touches must be in cells 
 (touches in margins don't count).
 */
- (void)handlePinch:(UIGestureRecognizer *)gesture
{
    if (gesture.numberOfTouches != 2)
        return;
    
    // Store touch locations
    CGPoint touchLoc0 = [gesture locationOfTouch:0 inView:self.view];
    CGPoint touchLoc1 = [gesture locationOfTouch:1 inView:self.view];
    LVSCellLoc *touchCell0 = [self locationInTableOfPoint:touchLoc0];
    LVSCellLoc *touchCell1 = [self locationInTableOfPoint:touchLoc1];
    
    // If state = began, set pinch properties
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"%@ %@", NSStringFromCGPoint([gesture locationOfTouch:0 inView:self.view]), NSStringFromCGPoint([gesture locationOfTouch:1 inView:self.view]));
        
        // Determine whether pinching rows, columns, or neither
        if ((touchCell0.col == touchCell1.col) && (abs(touchCell0.row - touchCell1.row) == 1))
        {
            // Set _currentPinchType
            _currentPinchType = LVSPinchTypeRow;
            
            // Set startPinchLoc's
            if (touchCell0.row < touchCell1.row)
            {
                _startPinchLoc0 = [gesture locationOfTouch:0 inView:self.view];
                _startPinchLoc1 = [gesture locationOfTouch:1 inView:self.view];
                _pinchRowCol0 = touchCell0.row;
                _pinchRowCol1 = touchCell1.row;
            }
            else
            {
                _startPinchLoc0 = [gesture locationOfTouch:1 inView:self.view];
                _startPinchLoc1 = [gesture locationOfTouch:0 inView:self.view];
                _pinchRowCol0 = touchCell1.row;
                _pinchRowCol1 = touchCell0.row;
            }
            
            // Ask delegate for new row
            _cellsBeingInserted = [self.delegate viewMatrix:self rowToInsertAtRow:_pinchRowCol1];
            if ([_cellsBeingInserted count] != self.numberOfCols)
            {
                NSException *e = [NSException exceptionWithName:@"IncorrectRowSize"
                                                              reason:@"Delegate provided row with the wrong number of cells"
                                                            userInfo:nil];
                @throw e;
            }
            
            // Remember sizes of cells being inserted, and determine max height of new cells
            _origSizesOfCellsBeingInserted = [[NSMutableArray alloc] initWithCapacity:self.numberOfCols];
            _maxSizeOfCellsBeingInserted = 0.0;
            for (int i = 0; i < self.numberOfCols; i++)
            {
                UIView *cell = _cellsBeingInserted[i];
                _origSizesOfCellsBeingInserted[i] = [NSValue valueWithCGSize:cell.frame.size];
                _maxSizeOfCellsBeingInserted = MAX(_maxSizeOfCellsBeingInserted, cell.frame.size.height);
            }
        }
        else if ((touchCell0.row == touchCell1.row) && (abs(touchCell0.col - touchCell1.col) == 1))
        {
            // Set _currentPinchType
            _currentPinchType = LVSPinchTypeCol;
            
            // Set startPinchLoc's
            if (touchCell0.col < touchCell1.col)
            {
                _startPinchLoc0 = [gesture locationOfTouch:0 inView:self.view];
                _startPinchLoc1 = [gesture locationOfTouch:1 inView:self.view];
                _pinchRowCol0 = touchCell0.col;
                _pinchRowCol1 = touchCell1.col;
            }
            else
            {
                _startPinchLoc0 = [gesture locationOfTouch:1 inView:self.view];
                _startPinchLoc1 = [gesture locationOfTouch:0 inView:self.view];
                _pinchRowCol0 = touchCell1.col;
                _pinchRowCol1 = touchCell0.col;
            }
            
            // Ask delegate for new col
            _cellsBeingInserted = [self.delegate viewMatrix:self colToInsertAtCol:_pinchRowCol1];
            if ([_cellsBeingInserted count] != self.numberOfRows)
            {
                NSException *e = [NSException exceptionWithName:@"IncorrectColumnSize"
                                                         reason:@"Delegate provided column with the wrong number of cells"
                                                       userInfo:nil];
                @throw e;
            }
            
            // Remember sizes of cells being inserted, and determine max width of new cells
            _origSizesOfCellsBeingInserted = [[NSMutableArray alloc] initWithCapacity:self.numberOfRows];
            _maxSizeOfCellsBeingInserted = 0.0;
            for (int j = 0; j < self.numberOfRows; j++)
            {
                UIView *cell = _cellsBeingInserted[j];
                _origSizesOfCellsBeingInserted[j] = [NSValue valueWithCGSize:cell.frame.size];
                _maxSizeOfCellsBeingInserted = MAX(_maxSizeOfCellsBeingInserted, cell.frame.size.width);
            }
        }
        else
        {
            // Set _currentPinchType
            _currentPinchType = LVSPinchTypeNone;
            
            // Cancel gesture recognizer (changes state to UIGestureRecognizerStateCancelled)
            gesture.enabled = NO;
            
            // Free _cellsBeingInserted
            _cellsBeingInserted = nil;
        }
        
        // If pinch is for real, remember original frames and add new cells as subviews
        if ((_currentPinchType == LVSPinchTypeRow) || (_currentPinchType == LVSPinchTypeCol))
        {
            // Remember original frames
            _origFrames = [[NSMutableArray alloc] initWithCapacity:self.numberOfRows];
            for (int i = 0; i < self.numberOfRows; i++)
            {
                _origFrames[i] = [[NSMutableArray alloc] initWithCapacity:self.numberOfCols];
                for (int j = 0; j < self.numberOfCols; j++)
                    _origFrames[i][j] = [NSValue valueWithCGRect:((UIView *)_cells[i][j]).frame];
            }
            
            // Add new cells as subviews, with 0 size
            for (UIView *cell in _cellsBeingInserted)
            {
                cell.frame = CGRectZero;
                [self.view addSubview:cell];
            }
        }
    }
    
    // If state = began or changed, move rows/cols
    if ((gesture.state == UIGestureRecognizerStateBegan) || (gesture.state == UIGestureRecognizerStateChanged))
    {
        // What kind of pinch?
        if (_currentPinchType == LVSPinchTypeRow)
        {
            // Determine top and bottom pinch locations
            CGPoint topPinchLoc;
            CGPoint botPinchLoc;
            if (touchLoc0.y < touchLoc1.y)
            {
                topPinchLoc = touchLoc0;
                botPinchLoc = touchLoc1;
            }
            else
            {
                topPinchLoc = touchLoc1;
                botPinchLoc = touchLoc0;
            }
            
            // Calculate up and down offsets
            CGFloat offsetUp = MIN(0.0, topPinchLoc.y - _startPinchLoc0.y);
            CGFloat offsetDn = MAX(0.0, botPinchLoc.y - _startPinchLoc1.y);
            
            // If total offset > new row height (plus margin, plus a bit more),
            // reduce offsets
            CGFloat maxTotalOffset = 1.1 * (_maxSizeOfCellsBeingInserted + self.rowMargin);
            if (offsetDn - offsetUp > maxTotalOffset) // NB: offsetUp <= 0
            {
                offsetUp *= maxTotalOffset / (offsetDn - offsetUp);
                offsetDn *= maxTotalOffset / (offsetDn - offsetUp);
            }

            // Move rows, and record bottom edge of _pinchRowCol0 and top edge of _pinchRowCol1
            CGFloat bottomEdge = 0.0;
            CGFloat topEdge = INFINITY;
            for (int i = 0; i < self.numberOfRows; i++)
                for (int j = 0; j < self.numberOfCols; j++)
                {
                    UIView *view = _cells[i][j];
                    CGRect origFrame = [_origFrames[i][j] CGRectValue];
                    
                    // Move cell
                    if (i <= _pinchRowCol0)
                        view.frame = CGRectOffset(origFrame, 0, offsetUp);
                    else
                        view.frame = CGRectOffset(origFrame, 0, offsetDn);
                    [view setNeedsDisplay];
                    
                    // If this is a pinch row, update edge
                    if (i == _pinchRowCol0)
                        bottomEdge = MAX(bottomEdge, CGRectGetMaxY(view.frame));
                    else if (i == _pinchRowCol1)
                        topEdge = MIN(topEdge, CGRectGetMinY(view.frame));
                }
            
            // Set frames of cells being inserted
            CGFloat xPos = CGRectGetMinX(self.view.bounds) + self.colMargin;
            for (int j = 0; j < self.numberOfCols; j++)
            {
                // TODO: handle vertical/horizontal alignment
                
                UIView *cell = _cellsBeingInserted[j];
                CGFloat y = bottomEdge + self.rowMargin;
                CGFloat height = MAX(0.0, topEdge - self.rowMargin - y);
                CGFloat width = [_origSizesOfCellsBeingInserted[j] CGSizeValue].width *
                    (height / [_origSizesOfCellsBeingInserted[j] CGSizeValue].height);
                CGFloat x = xPos + ([_colWidths[j] floatValue] - width) / 2.0;
                cell.frame = CGRectMake(x, y, width, height);
                
                // Update xPos
                xPos += [_colWidths[j] floatValue] + self.colMargin;
            }

        }
        else if (_currentPinchType == LVSPinchTypeCol)
        {
            // Determine left and right pinch locations
            CGPoint leftPinchLoc;
            CGPoint rghtPinchLoc;
            if (touchCell0.col < touchCell1.col)
            {
                leftPinchLoc = [gesture locationOfTouch:0 inView:self.view];
                rghtPinchLoc = [gesture locationOfTouch:1 inView:self.view];
            }
            else
            {
                leftPinchLoc = [gesture locationOfTouch:1 inView:self.view];
                rghtPinchLoc = [gesture locationOfTouch:0 inView:self.view];
            }
            
            // Move cols
            for (int i = 0; i < self.numberOfRows; i++)
                for (int j = 0; j < self.numberOfCols; j++)
                {
                    UIView *view = _cells[i][j];
                    CGRect origFrame = [_origFrames[i][j] CGRectValue];
                    
                    // Determine offset (ensure >= 0, <= a bit larger than new col width)
                    CGFloat offset;
                    if (j <= _pinchRowCol0)
                        offset = leftPinchLoc.x - _startPinchLoc0.x;
                    else
                        offset = rghtPinchLoc.x - _startPinchLoc1.y;
                    offset = MIN(MAX(0.0, offset), 1.1 * _maxSizeOfCellsBeingInserted);
                    
                    // Move cell
                    view.frame = CGRectOffset(origFrame, offset, 0);
                }
        }
    }
    else if ((gesture.state == UIGestureRecognizerStateCancelled) ||
             (gesture.state == UIGestureRecognizerStateEnded) ||
             (gesture.state == UIGestureRecognizerStateFailed))
    {
        _currentPinchType = LVSPinchTypeNone;
        _cellsBeingInserted = nil;
    }
    
    
}

#pragma mark Private - Layout

/* 
 Sets frames of all cells in matrix to the frames specified in frames.
 Frames must be a 2D array organized like _cells. Frames must be stored as
 CGRects converted to NSValue, otherwise an exception will be raised.
 Calling calcFrames and then calling setFramesTo using the frames returned
 is the same as calling layoutCells:animated(=NO). But separating the two allows
 something to be done in between, e.g., set temporary frames at start of animation.
 */
- (void)setFramesTo:(NSMutableArray *)frames
{
    for (int i = 0; i < self.numberOfRows; i++)
        for (int j = 0; j < self.numberOfCols; j++)
            if (frames[i][j] != [NSNull null]) // TODO: USE TRY BLOCK
                if (_cells[i][j] != [NSNull null])
                    ((UIView *)_cells[i][j]).frame = [frames[i][j] CGRectValue];
}

/* 
 Returns 2D array of frames corresponding to matrix cells after layout. Entries in
 the array are of type NSValue; use rect = [array[i][j] CGRectValue] to recover.
 Sets row heights and column widths first.

 rowOffsets and colOffsets are arrays of CGFloats indicating vertical offsets for rows
 and horizontal offsets for columns. Rows and columns are offset by these values from their
 nominal locations. Set to nil for no offset.
 
 Calling calcFrames with no offsets and then calling setFramesTo using the frames returned
 is the same as calling layoutFrames:animated(=NO).
 */
- (NSMutableArray *)calcFramesWithRowOffsets:(NSArray *)rowOffsets withColOffsets:(NSArray *)colOffsets
{
    // Create array
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:self.numberOfRows];
    for (int i = 0; i < self.numberOfRows; i++)
        frames[i] = [[NSMutableArray alloc] initWithCapacity:self.numberOfCols];
    
    // Set row heights and column widths
    [self setRowHeights];
    [self setColWidths];
    
    // Set nominal frames
    CGFloat yPos = CGRectGetMinY(self.view.bounds) + self.rowMargin;
    for (int i = 0; i < self.numberOfRows; i++)
    {
        CGFloat xPos = CGRectGetMinX(self.view.bounds) + self.colMargin;
        for (int j = 0; j < self.numberOfCols; j++)
        {
            if (_cells[i][j] != [NSNull null])
            {
                UIView *cell = _cells[i][j];
                CGFloat x, y;
                
                // Set vertical alignment
                if ([_rowAlignments[i] integerValue] == LVSRowAlignmentTop)
                    y = yPos;
                else if ([_rowAlignments[i] integerValue] == LVSRowAlignmentMiddle)
                    y = yPos + ([_rowHeights[i] floatValue] - cell.frame.size.height) / 2.0;
                else // LVSRowAlignmentBottom
                    y = yPos + [_rowHeights[i] floatValue] - cell.frame.size.height;
                
                // Set horizontal alignment
                if ([_colAlignments[j] integerValue] == LVSColAlignmentLeft)
                    x = xPos;
                else if ([_colAlignments[j] integerValue] == LVSColAlignmentCenter)
                    x = xPos + ([_colWidths[j] floatValue] - cell.frame.size.width) / 2.0;
                else // LVSColAlignmentRight
                    x = xPos + [_colWidths[j] floatValue] - cell.frame.size.width;
                
                CGRect frame = CGRectMake(x, y, cell.frame.size.width, cell.frame.size.height);
                frames[i][j] = [NSValue valueWithCGRect:frame];
            }
            xPos += [_colWidths[j] floatValue] + self.colMargin;
        }
        yPos += [_rowHeights[i] floatValue] + self.rowMargin;
    }
    
    // Adjust by offsets
    if (rowOffsets || colOffsets)
    {
        for (int i = 0; i < self.numberOfRows; i++)
            for (int j = 0; j < self.numberOfCols; j++)
            {
                UIView *cell = _cells[i][j];
                if (rowOffsets)
                    cell.frame = CGRectOffset(cell.frame, 0.0, [rowOffsets[i] floatValue]);
                if (colOffsets)
                    cell.frame = CGRectOffset(cell.frame, [colOffsets[j] floatValue], 0.0);
            }
    }
    
    return frames;
}

/*
 Sets _rowHeights. If _userRowHeights[r] < 0, sets _rowHeights[r] = height of tallest cell in the row,
 otherwise, sets _rowHeights[r] = _userRowHeights[r].
 */
- (void)setRowHeights;
{
    // Loop through rows
    for (int i = 0; i < self.numberOfRows; i++)
    {
        if ([_userRowHeights[i] floatValue] < 0)
        {
            // Find max height in row
            CGFloat maxHeight = 0.0;
            for (int j = 0; j < self.numberOfCols; j++)
                if (_cells[i][j] != [NSNull null])
                    maxHeight = MAX(maxHeight, ((UIView *)_cells[i][j]).frame.size.height);
            
            // Set row height
            _rowHeights[i] = [NSNumber numberWithFloat:maxHeight];
        }
        else
            _rowHeights[i] = _userRowHeights[i];
    }
}

/*
 Sets _colWidths. If _userColWidths[c] < 0, sets _colWidths[c] = width of widest cell in the column,
 otherwise, sets _colWidths[c] = _userColWidths[c].
 */
- (void)setColWidths;
{
    // Loop through columns
    for (int j = 0; j < self.numberOfCols; j++)
    {
        if ([_userColWidths[j] floatValue] < 0)
        {
            // Find max width in column
            CGFloat maxWidth = 0.0;
            for (int i = 0; i < self.numberOfRows; i++)
                if (_cells[i][j] != [NSNull null])
                    maxWidth = MAX(maxWidth, ((UIView *)_cells[i][j]).frame.size.width);
            
            // Set column width
            _colWidths[j] = [NSNumber numberWithFloat:maxWidth];
        }
        else
            _colWidths[j] = _userColWidths[j];
    }
}

@end
