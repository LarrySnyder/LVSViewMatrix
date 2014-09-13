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
    // Can access using _cells[r][c]
    NSMutableArray *_cells;
    
    // Row heights and column widths
    NSMutableArray *_rowHeights;
    NSMutableArray *_colWidths;
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
        
        // Set size (in general use insertRows: and insertColumns: to change the size,
        // but this is safe here because we know the matrix is empty)
    //    self.numberOfRows = numRows;
      //  self.numberOfCols = numCols;
        
        // Insert empty rows and columns
        for (int i = 0; i < numRows; i++)
            [self insertRow:[[NSMutableArray alloc] initWithCapacity:numCols]
                      atRow:0
                 withHeight:0
                   animated:NO];
        for (int j = 0; j < numCols; j++)
            [self insertCol:[[NSMutableArray alloc] initWithCapacity:numRows]
                      atCol:0
                  withWidth:0
                   animated:NO];
        
        // Initialize _cells
        _cells = [[NSMutableArray alloc] initWithCapacity:numRows];
        for (int i = 0; i < numRows; i++)
        {
            _cells[i] = [[NSMutableArray alloc] initWithCapacity:numCols];
            for (int j = 0; j < numCols; j++)
                _cells[i][j] = [NSNull null];
        }
        
        // Initialize row heights and column widths
        _rowHeights = [[NSMutableArray alloc] initWithCapacity:numRows];
        _colWidths = [[NSMutableArray alloc] initWithCapacity:numCols];
    }
    return self;
}

- (id)init
{
    self = [self initWithNumRows:0 withNumCols:0];
    return self;
}

#pragma mark Property Sets/Gets

- (NSInteger)getNumberOfRows
{
    return [_cells count];
}

- (NSInteger)getNumberOfCols
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

#pragma mark Size

- (void)insertRow:(NSMutableArray *)row atRow:(NSInteger)rowNum withHeight:(CGFloat)height animated:(BOOL)animated
// NEED TO HANDLE withHeight:
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

- (void)insertCol:(NSMutableArray *)col atCol:(NSInteger)colNum withWidth:(CGFloat)width animated:(BOOL)animated
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
        // Loop through rows
        for (int i = 0; i < self.numberOfRows; i++)
        {
/*            for (int j = 0; j < numCols; j++)
                // Insert empty cell into row
                [_cells[i] insertObject:[NSNull null] atIndex:col];
  */      }
    }
}

#pragma mark Getting and Setting Cells

- (void)setView:(UIView *)view forRow:(NSInteger)row forCol:(NSInteger)col
{
    _cells[row][col] = view;
}

- (UIView *)getViewForRow:(NSInteger)row forCol:(NSInteger)col
{
    return _cells[row][col];
}


#pragma mark Private - Layout

/* 
 Sets row heights and column widths, then sets frames of all cells. 
 */
- (void)layoutCells
{
    // Set row heights and column widths
    [self setRowHeights];
    [self setcolWidths];
    
/*    for (int i = 0; i < self.numberOfRows; i++)
        NSLog(@"row %d height %f", i, [_rowHeights[i] floatValue]);
    for (int j = 0; j < self.numberOfCols; j++)
        NSLog(@"col %d width %f", j, [_colWidths[j] floatValue]);*/
    
    // Set frames
    CGFloat yPos = CGRectGetMinY(self.view.bounds) + self.rowMargin;
    for (int i = 0; i < self.numberOfRows; i++)
    {
        CGFloat xPos = CGRectGetMinX(self.view.bounds) + self.colMargin;
        for (int j = 0; j < self.numberOfCols; j++) // USE FAST ENUMERATION??????
        {
            UIView *cell = _cells[i][j];
            cell.frame = CGRectMake(xPos, yPos, cell.frame.size.width, cell.frame.size.height);
            [cell setNeedsDisplay];
            xPos += [_colWidths[j] floatValue] + self.colMargin;
        }
        yPos += [_rowHeights[i] floatValue] + self.rowMargin;
    }
    
    for (int i = 0; i < self.numberOfRows; i++)
        for (int j = 0; j < self.numberOfCols; j++)
            NSLog(@"%d %d %@", i, j, NSStringFromCGRect(((UIView *)_cells[i][j]).frame));
    
    [self.view setNeedsDisplay];
}

/*
 Sets height of each row equal to the height of the tallest cell in the row.
 */
- (void)setRowHeights;
{
    // Loop through rows
    for (int i = 0; i < self.numberOfRows; i++)
    {
        // Find max height in row
        CGFloat maxHeight = 0.0;
        for (int j = 0; j < self.numberOfCols; j++)
            maxHeight = MAX(maxHeight, ((UIView *)_cells[i][j]).frame.size.height);
        
        // Set row height
        _rowHeights[i] = [NSNumber numberWithFloat:maxHeight];
    }
}

/*
 Sets width of each column equal to the width of the widest cell in the column.
 */
- (void)setcolWidths;
{
    // Loop through columns
    for (int j = 0; j < self.numberOfCols; j++)
    {
        // Find max width in column
        CGFloat maxWidth = 0.0;
        for (int i = 0; i < self.numberOfRows; i++)
            maxWidth = MAX(maxWidth, ((UIView *)_cells[i][j]).frame.size.width);
        
        // Set column width
        _colWidths[j] = [NSNumber numberWithFloat:maxWidth];
    }
}

@end
