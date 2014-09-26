//
//  LVSViewController.m
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import "LVSViewController.h"
#import "LVSViewMatrixController.h"

@interface LVSViewController ()

@end

@implementation LVSViewController
{
    LVSViewMatrixController *vmc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.addRowNum.delegate = self;
    self.addColNum.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    if (vmc)
        return;
    
    vmc = [[LVSViewMatrixController alloc] initWithNumRows:3 withNumCols:3];
    vmc.view = self.matrixView;
    
    vmc.rowMargin = 5;
    vmc.colMargin = 5;
    
    // Create labels of random sizes
    for (int i = 1; i <= 9; i++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(arc4random_uniform(vmc.view.frame.size.width - 100), arc4random_uniform(vmc.view.frame.size.height - 100), arc4random_uniform(25)+25, arc4random_uniform(25)+25)];
        label.backgroundColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:1.0];
//        label.backgroundColor = [UIColor colorWithRed:(CGFloat)rand()/RAND_MAX green:(CGFloat)rand()/RAND_MAX blue:(CGFloat)rand()/RAND_MAX alpha:1.0];
        label.text = [NSString stringWithFormat:@"%d", i];
        [vmc.view addSubview:label];
        [vmc setView:label forRow:((i-1) / 3) forCol:((i-1) % 3)];
    }

/*    for (int i = 1; i <= 9; i++)
    {
        UIView *view = [self.view viewWithTag:i];
        [vmc setView:view forRow:((i-1) / 3) forCol:((i-1) % 3)];
    }*/
    
    NSLog(@"%d %d", vmc.numberOfRows, vmc.numberOfCols);
   
//    [vmc layoutCells];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleLayoutCells:(id)sender
{
    [vmc layoutCellsAnimated:YES];
}

- (IBAction)handleAddRow:(id)sender
{
    // Create new row
    NSMutableArray *newRow = [[NSMutableArray alloc] initWithCapacity:vmc.numberOfCols];
    for (int j = 0; j < vmc.numberOfCols; j++)
    {
        // Create cell of random size and color
        UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, arc4random_uniform(25)+25, arc4random_uniform(25)+25)];
        cell.backgroundColor = [UIColor colorWithRed:(CGFloat)rand()/RAND_MAX green:(CGFloat)rand()/RAND_MAX blue:(CGFloat)rand()/RAND_MAX alpha:1.0];
        
        // Insert into row
        [newRow addObject:cell];
    }
    
    LVSRowAlignment align;
    if (self.rowAlignment.selectedSegmentIndex == 0)
        align = LVSRowAlignmentTop;
    else if (self.rowAlignment.selectedSegmentIndex == 1)
        align = LVSRowAlignmentMiddle;
    else
        align = LVSRowAlignmentBottom;
    
    // Insert row into matrix
    [vmc insertRow:newRow
             atRow:[self.addRowNum.text intValue]
        withHeight:-1
     withAlignment:align
          animated:YES];
}

- (IBAction)handleAddCol:(id)sender
{
    // Create new column
    NSMutableArray *newCol = [[NSMutableArray alloc] initWithCapacity:vmc.numberOfRows];
    for (int i = 0; i < vmc.numberOfRows; i++)
    {
        // Create cell of random size and color
        UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, arc4random_uniform(25)+25, arc4random_uniform(25)+25)];
        cell.backgroundColor = [UIColor colorWithRed:(CGFloat)rand()/RAND_MAX green:(CGFloat)rand()/RAND_MAX blue:(CGFloat)rand()/RAND_MAX alpha:1.0];
        
        // Insert into column
        [newCol addObject:cell];
    }
    
    LVSColAlignment align;
    if (self.colAlignment.selectedSegmentIndex == 0)
        align = LVSColAlignmentLeft;
    else if (self.colAlignment.selectedSegmentIndex == 1)
        align = LVSColAlignmentCenter;
    else
        align = LVSColAlignmentRight;
    
    // Insert column into matrix
    [vmc insertCol:newCol
             atCol:[self.addColNum.text intValue]
        withWidth:-1
     withAlignment:align
          animated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
