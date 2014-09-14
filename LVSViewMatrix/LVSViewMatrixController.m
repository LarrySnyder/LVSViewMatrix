//
//  LVSViewMatrixController.m
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import "LVSViewMatrixController.h"

#ifndef kInsertRowAnimationDuration
#define kInsertRowAnimationDuration	1.0
#define kInsertColAnimationDuration 1.0
#endif


@interface LVSViewMatrixController ()

@end

@implementation LVSViewMatrixController
{
    // Cells in the matrix, stored as an array of arrays. Outer array corresponds to rows, inner to columns.
    // Can access using _cells[r][c]. All objects are of type UIView*
    NSMutableArray *_cells;
    
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
    // Do any additional setup after loading the view.
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
        for (int j = [row count]; j < self.numberOfCols; j++)
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
        
        // Set animation duration
        CGFloat duration;
        if (animated)
            duration = kInsertRowAnimationDuration;
        else
            duration = 0.0;
        
        // Update layout to insert row in view
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:0
                         animations:^{
                             [self layoutCells];
                         }
                         completion:nil];
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
        for (int i = [col count]; i < self.numberOfRows; i++)
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
        
        // Set animation duration
        CGFloat duration;
        if (animated)
            duration = kInsertRowAnimationDuration;
        else
            duration = 0.0;
        
        // Update layout to insert row in view
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:0
                         animations:^{
                             [self layoutCells];
                         }
                         completion:nil];    }
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


#pragma mark Private - Layout

/* 
 Sets row heights and column widths, then sets frames of all cells. 
 */
- (void)layoutCells
{
    // Set row heights and column widths
    [self setRowHeights];
    [self setColWidths];
    
    // Set frames
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
                
                // Set horizontal alignment
                if ([_rowAlignments[i] integerValue] == LVSRowAlignmentTop)
                    y = yPos;
                else if ([_rowAlignments[i] integerValue] == LVSRowAlignmentMiddle)
                    y = yPos + ([_rowHeights[i] floatValue] - cell.frame.size.height) / 2.0;
                else // LVSRowAlignmentBottom
                    y = yPos + [_rowHeights[i] floatValue] - cell.frame.size.height;
                
                // Set vertical alignment
                if ([_colAlignments[j] integerValue] == LVSColAlignmentLeft)
                    x = xPos;
                else if ([_colAlignments[j] integerValue] == LVSColAlignmentCenter)
                    x = xPos + ([_colWidths[j] floatValue] - cell.frame.size.width) / 2.0;
                else // LVSColAlignmentRight
                    x = xPos + [_colWidths[j] floatValue] - cell.frame.size.width;
                
                cell.frame = CGRectMake(x, y, cell.frame.size.width, cell.frame.size.height);
                [cell setNeedsDisplay];
            }
            xPos += [_colWidths[j] floatValue] + self.colMargin;
        }
        yPos += [_rowHeights[i] floatValue] + self.rowMargin;
    }
    
    [self.view setNeedsDisplay];
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
