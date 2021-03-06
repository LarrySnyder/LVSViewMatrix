//
//  LVSViewController.h
//  LVSViewMatrix
//
//  Created by Larry Snyder on 9/12/14.
//  Copyright (c) 2014 Larry Snyder. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LVSViewMatrixController.h"

@interface LVSViewController : UIViewController <UITextFieldDelegate, LVSViewMatrixControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *matrixView;
@property (nonatomic, weak) IBOutlet UITextField *addRowNum;
@property (nonatomic, weak) IBOutlet UITextField *addColNum;
@property (nonatomic, weak) IBOutlet UISegmentedControl *rowAlignment;
@property (nonatomic, weak) IBOutlet UISegmentedControl *colAlignment;

- (IBAction)handleLayoutCells:(id)sender;
- (IBAction)handleAddRow:(id)sender;
- (IBAction)handleAddCol:(id)sender;

@end
