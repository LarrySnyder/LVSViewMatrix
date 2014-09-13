//
//  LVSViewMatrixController.m
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import "LVSViewMatrixController.h"

@interface LVSViewMatrixController ()

// Redeclare some properties as read-write
@property (nonatomic, readwrite) NSInteger numberOfRows;
@property (nonatomic, readwrite) NSInteger numberOfCols;

@end

@implementation LVSViewMatrixController
{
    // Cells in the matrix, stored as an array of arrays. Outer array corresponds to rows, inner to columns.
    // Can access using _cells[r][c]
    NSMutableArray *_cells;
}

@synthesize numberOfRows;
@synthesize numberOfCols;

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
        // Set size (in general use insertRows: and insertColumns: to change the size,
        // but this is safe here because we know the matrix is empty)
        self.numberOfRows = numRows;
        self.numberOfCols = numCols;
        
        // Initialize _cells
        _cells = [[NSMutableArray alloc] initWithCapacity:numRows];
        for (int i = 0; i < numRows; i++)
        {
            _cells[i] = [[NSMutableArray alloc] initWithCapacity:numCols];
            for (int j = 0; j < numCols; j++)
                _cells[i][j] = nil;
        }
    }
    return self;
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

- (void)insertRows:(NSInteger)numRows atRow:(NSInteger)row
{
    if (row > self.numberOfRows)
    {
        NSException *e = [NSException exceptionWithName:@"SubscriptOutOfBounds"
                                                 reason:@"Attempted to insert row(s) at a row index that does not exist"
                                               userInfo:nil];
        @throw e;
    }
    else
    {
        for (int i = 0; i < numRows; i++)
        {
            // Create new row and insert it
            NSMutableArray *newRow = [[NSMutableArray alloc] initWithCapacity:self.numberOfCols];
            for (int j = 0; j < self.numberOfCols; j++)
                newRow[j] = [NSNull null];
            [_cells insertObject:newRow atIndex:row];
        }
    }
}

- (void)insertCols:(NSInteger)numCols atCol:(NSInteger)col
{
    if (col > self.numberOfCols)
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
            for (int j = 0; j < numCols; j++)
                // Insert empty cell into row
                [_cells[i] insertObject:[NSNull null] atIndex:col];
        }
    }
}



@end
